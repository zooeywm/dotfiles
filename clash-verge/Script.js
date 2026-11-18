// Global script: runs for every profile.
//
// 功能：
//   1) 规则集（rule-providers）统一由 dotfiles 注入：type=http 链接导入，mihomo 按
//      interval 自动拉取更新，不依赖订阅是否自带、也不需要把规则集静态存进仓库。
//   2) 内网/私网永远直连（TUN 模式下所有流量都进 mihomo，必须显式放行）。
//   3) 从 Clash Nyanpasu 迁移的直连白名单（微软下载、tailscale、rustdesk 等）。
//   4) 规则集路由：AI / Google / gfw / 国际媒体 / 内地媒体 / 测速 / 国内 IP。
//      目标组按当前订阅实际存在的组自动选择（机场有 🤖/📺/📽️，自建订阅只有 🚀 节点选择）。

function main(config, profileName) {
  // 规则集缓存目录（mihomo 会把下载结果写在这里，重启时先用缓存）
  const RULES_DIR = "/home/zooeywm/.local/share/io.github.clash-verge-rev.clash-verge-rev/rules";

  // 上游规则集（全部用官方源；mihomo 每天自动更新一次）
  const RULESETS = {
    "ai":           { behavior: "classical", url: "https://ruleset-mirror.skk.moe/Clash/non_ip/ai.txt" },
    "google":       { behavior: "classical", url: "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/Google/Google_No_Resolve.yaml" },
    "gfw":          { behavior: "domain",    url: "https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/gfw.txt" },
    "global-media": { behavior: "classical", url: "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/GlobalMedia/GlobalMedia_Classical_No_Resolve.yaml" },
    "asian-media":  { behavior: "classical", url: "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/AsianMedia/AsianMedia_No_Resolve.yaml" },
    "speedtest":    { behavior: "classical", url: "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/Speedtest/Speedtest_No_Resolve.yaml" },
    "cncidr":       { behavior: "ipcidr",    url: "https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Clash/ChinaIPs/ChinaIPs_IP.yaml" },
    "private":      { behavior: "domain",    url: "https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/private.txt" },
    "lancidr":      { behavior: "ipcidr",    url: "https://raw.githubusercontent.com/Loyalsoldier/clash-rules/release/lancidr.txt" },
  };

  // 目标组自适应
  const groups = (config["proxy-groups"] || []).map(g => g.name);
  const firstSelect = (config["proxy-groups"] || []).find(g => g.type === "select");
  const pick = (candidates, fallback) => candidates.find(n => groups.includes(n)) || fallback;
  const MAIN = pick(
    ["🚀 节点选择", "PROXY", "Proxy", "代理", "节点选择"],
    firstSelect ? firstSelect.name : "DIRECT",
  );
  const AI_GROUP = pick(["🤖 AI服务"], MAIN);
  const GLOBAL_MEDIA_GROUP = pick(["📺 国际影视"], MAIN);
  const ASIAN_MEDIA_GROUP = pick(["📽️ 内地影视"], "DIRECT");

  // 注入 rule-providers（http 链接 + 每日更新；走主代理组下载，避免 GitHub 直连不稳）
  const providers = {};
  for (const [name, meta] of Object.entries(RULESETS)) {
    providers[`dotfiles-${name}`] = {
      type: "http",
      behavior: meta.behavior,
      url: meta.url,
      path: `${RULES_DIR}/dotfiles-${name}.yaml`,
      interval: 86400,
      proxy: MAIN,
    };
  }
  config["rule-providers"] = Object.assign({}, config["rule-providers"] || {}, providers);

  // 内网 / 私网：永远直连（规则集 + 字面兜底，规则集未命中或未下载成功时也安全）
  const lanRules = [
    "RULE-SET,dotfiles-lancidr,DIRECT,no-resolve",
    "RULE-SET,dotfiles-private,DIRECT",
    "IP-CIDR,10.0.0.0/8,DIRECT,no-resolve",
    "IP-CIDR,172.16.0.0/12,DIRECT,no-resolve",
    "IP-CIDR,192.168.0.0/16,DIRECT,no-resolve",
    "IP-CIDR,100.64.0.0/10,DIRECT,no-resolve",
    "IP-CIDR,169.254.0.0/16,DIRECT,no-resolve",
  ];

  const prependRules = [
    // 微软官方下载/更新：直连（ISO、Windows Update、下载页 API），不消耗机场流量
    "DOMAIN-SUFFIX,microsoft.com,DIRECT",
    "DOMAIN-SUFFIX,windowsupdate.com,DIRECT",
    "DOMAIN-SUFFIX,windows.com,DIRECT",
    "DOMAIN-SUFFIX,microsoftonline.com,DIRECT",
    // Tailscale：控制面(login/controlplane)走代理（国内直连被墙），其余流量（P2P/DERP）直连
    `DOMAIN-SUFFIX,tailscale.com,${MAIN}`,
    `DOMAIN-SUFFIX,tailscale.io,${MAIN}`,
    "PROCESS-NAME,tailscaled,DIRECT",
    "PROCESS-NAME,tailscale,DIRECT",
    "IP-CIDR,49.7.241.10/32,DIRECT,no-resolve",
    "DOMAIN-KEYWORD,ghfast,DIRECT",
    "DOMAIN-REGEX,rustdesk,DIRECT",
    "DOMAIN,invite.linuxdo.org,DIRECT",
    "DOMAIN,git.flam.dev,DIRECT",
    "DOMAIN-KEYWORD,ngrok,DIRECT",
    "DOMAIN-SUFFIX,daocloud.vip,DIRECT",
    "DOMAIN-SUFFIX,daocloud.io,DIRECT",
    "DOMAIN-SUFFIX,1panel.live,DIRECT",
    "DOMAIN-SUFFIX,1ms.run,DIRECT",
    "DOMAIN-SUFFIX,dockerpull.org,DIRECT",
    "DOMAIN-SUFFIX,dockerproxy.net,DIRECT",
    "DOMAIN-SUFFIX,hub.rat.dev,DIRECT",
  ];

  // 规则集路由
  const rulesetRules = [
    `RULE-SET,dotfiles-ai,${AI_GROUP}`,
    `RULE-SET,dotfiles-google,${MAIN}`,
    `RULE-SET,dotfiles-gfw,${MAIN}`,
    `RULE-SET,dotfiles-global-media,${GLOBAL_MEDIA_GROUP}`,
    `RULE-SET,dotfiles-asian-media,${ASIAN_MEDIA_GROUP}`,
    "RULE-SET,dotfiles-speedtest,DIRECT",
    "RULE-SET,dotfiles-cncidr,DIRECT,no-resolve",
  ];

  // Tailscale 相关域名走真实 DNS（不套 fake-ip），否则 tailscaled 直连假 IP 会卡死
  if (config.dns) {
    const extra = ["+.tailscale.com", "+.tailscale.io", "controlplane.tailscale.com", "login.tailscale.com"];
    const cur = config.dns["fake-ip-filter"] || [];
    config.dns["fake-ip-filter"] = cur.concat(extra.filter(d => !cur.includes(d)));
  }

  config.rules = lanRules.concat(prependRules, rulesetRules, config.rules || []);
  return config;
}
