// Global script: runs for every profile.
// Prepends the direct-connection rules migrated from Clash Nyanpasu
// (originally "Custom Rules", applied to the 空气糖果 subscription only).
function main(config, profileName) {
  const prependRules = [
    // Tailscale：控制面(login/controlplane)走代理（国内直连被墙），其余流量（P2P/DERP）直连
    "DOMAIN-SUFFIX,tailscale.com,🚀 节点选择",
    "DOMAIN-SUFFIX,tailscale.io,🚀 节点选择",
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

  // Tailscale 相关域名走真实 DNS（不套 fake-ip），否则 tailscaled 直连假 IP 会卡死
  if (config.dns) {
    const extra = ["+.tailscale.com", "+.tailscale.io", "controlplane.tailscale.com", "login.tailscale.com"];
    const cur = config.dns["fake-ip-filter"] || [];
    config.dns["fake-ip-filter"] = cur.concat(extra.filter(d => !cur.includes(d)));
  }

  config.rules = prependRules.concat(config.rules || []);
  return config;
}
