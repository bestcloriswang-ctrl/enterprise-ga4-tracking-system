---
name: enterprise-ga4-skill-manager
description: Install, check, update, or roll back the enterprise_ga4_tracking_system Codex skill from the public bestcloriswang-ctrl GitHub releases. Use when a colleague asks to install the enterprise GA4 skill, check its version, update it, or restore the previous installation.
---

# Enterprise GA4 Skill Manager

Manage `enterprise_ga4_tracking_system` through the bundled `scripts/manage.sh` command. The release source is fixed to the public repository `bestcloriswang-ctrl/enterprise-ga4-tracking-system`.

## Intent Routing

- Install for the first time: run `scripts/manage.sh install`.
- Check installed and latest versions: run `scripts/manage.sh status`.
- Update to the latest release: run `scripts/manage.sh update`.
- Restore the newest local backup: run `scripts/manage.sh rollback`.

Run the script from this Skill directory or use its absolute path. Do not manually reconstruct the download URL, overwrite the target directory, or delete backups.

## Safety and Reporting

- `status` is read-only.
- `install` and `update` download a versioned release, verify its SHA-256 checksum, validate `SKILL.md`, and move the current installation to a timestamped backup before replacement.
- `rollback` preserves the current installation as a timestamped pre-rollback copy before restoring the newest backup.
- If download, checksum, archive, or validation fails, stop and report the error; the current installation must remain unchanged.
- After a successful install, update, or rollback, tell the user to restart Codex so the Skill catalog reloads.
- Report the installed version, latest version, target path, and backup path when the script provides them.

Do not modify the managed Skill's content from this manager. Product changes belong in the source repository and must be published as a new version.
