# Enterprise GA4 Tracking System Skill

团队共享的 Codex Skill，用于维护 GA4 App 埋点六表体系、KPI、事件、参数、页面、链路和 KPI 驱动漏斗。

## 仓库结构

```text
skill/enterprise_ga4_tracking_system/  Skill 正文与 references
skill/enterprise-ga4-skill-manager/    给同事使用的安装与更新管理器
scripts/install.sh                     安装当前仓库版本
scripts/update.sh                      拉取 Git 更新并重新安装
scripts/version.sh                     查看或设置版本号
scripts/validate.sh                    校验发布结构与脚本
scripts/package.sh                     生成版本化 ZIP
VERSION                                当前版本号
CHANGELOG.md                           发布记录
```

## 首次安装

克隆仓库后执行：

```bash
./scripts/install.sh
```

默认安装到 `${CODEX_HOME:-$HOME/.codex}/skills/enterprise_ga4_tracking_system`。也可以指定其他技能目录：

```bash
./scripts/install.sh --target /path/to/skills
```

安装脚本不会直接删除旧版本；已有安装会先移动到带时间戳的备份目录，再安装新版本。

## 获取团队更新

```bash
./scripts/update.sh
```

该命令执行 `git pull --ff-only`、校验仓库并重新安装。它不会自动定时运行；同事需要主动执行，或由团队设备管理系统定期调用。

## 版本管理

```bash
./scripts/version.sh show
./scripts/version.sh set 1.1.0
```

设置版本后同步维护 `CHANGELOG.md`，提交并创建 Git Tag：

```bash
git add VERSION CHANGELOG.md skill
git commit -m "release: v1.1.0"
git tag v1.1.0
git push origin main --tags
```

## 校验与打包

```bash
./scripts/validate.sh
./scripts/package.sh
```

发布包生成在 `dist/enterprise_ga4_tracking_system-v<version>.zip`。

## 给同事使用 Skill 管理器

同事首次安装 `enterprise-ga4-skill-manager` 后，可以直接在 Codex 中要求安装、检查版本、更新或回退企业 GA4 埋点 Skill。

管理器从本仓库最新 GitHub Release 下载受管 Skill，校验 SHA-256，并在替换前备份旧版本。仓库公开后，安装和更新均不需要 GitHub 登录或仓库权限。

## 协作约定

- 仓库版本是团队唯一发布源，不直接修改同事机器上的已安装副本。
- 修改 `skill/enterprise_ga4_tracking_system` 后先校验，再提升版本和更新 Changelog。
- 生产分享使用 Git Tag 或版本化 ZIP，避免使用无版本文件名。
- `update.sh` 只接受可快进更新；出现本地改动或分叉时会停止，不会覆盖同事修改。
