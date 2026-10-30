# Dux Shell (dms)

DMS 2.0 起用户配置目录为 `~/.config/dms`（旧的 `~/.config/DankMaterialShell` 只是兼容软链）。

## 为什么这里没有 settings.json

`settings.json` 由 DMS 自己读写（界面改设置会写它，2.0 迁移时还会整文件重写），
软链过去会被替换成普通文件，所以不再纳管。

需要跨机器版本化的偏好放在 [`config.d/`](config.d/) 里：

- 文件名按字典序生效，后面的覆盖前面的；
- `config.d/*.json` 的优先级**高于** `settings.json`；
- DMS 不会写这些文件，所以可以安全地用软链交给 dotfiles 管理；
- 代价：写进 drop-in 的键等于被"冻结"，在 UI 里改这些键重启后会被 drop-in 覆盖回来。
  所以只放稳定项（跟 dotfiles 里脚本绑定的），bar 布局、主题这类 UI 状态留给 `settings.json`。

改完 drop-in 后执行 `dms restart` 生效。

整份配置的快照/恢复用 `dms backup create` / `dms backup restore`。
