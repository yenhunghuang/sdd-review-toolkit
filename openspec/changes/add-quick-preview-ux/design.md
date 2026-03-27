---
change: add-quick-preview-ux
created_at: 2026-03-27T04:50:00+08:00
---

# 技術設計: 快速預覽 UX 優化

## 方案概述

新增 `sdd-peek` 和 `sdd-last` 兩個 shell function，修改 tmux keybindings 從 split-window 改為 display-popup，並在 sdd-review 的 fzf 中加入進階快捷鍵。

## 影響範圍分析

| 模組/檔案 | 影響類型 | 說明 |
|-----------|---------|------|
| `bin/sdd-peek.sh` | 新增 | tmux popup 快速預覽 function |
| `bin/sdd-last.sh` | 新增 | 最近修改 .md 預覽 function |
| `bin/sdd-review.sh` | 修改 | fzf 加入 Ctrl+/ toggle preview、Ctrl+P popup 預覽 |
| `tmux/.tmux-sdd.conf` | 修改 | R/S/D/T 改用 display-popup |
| `tests/sdd-peek.bats` | 新增 | sdd-peek 測試 |
| `tests/sdd-last.bats` | 新增 | sdd-last 測試 |
| `tests/sdd-review.bats` | 修改 | 新增 fzf 快捷鍵相關測試 |
| `tests/tmux-keybindings.bats` | 修改 | popup 相關斷言更新 |

## 實作方案

### sdd-peek

```bash
sdd-peek() {
    local file="$1"
    # 驗證參數和檔案存在
    # tmux 環境：tmux display-popup -w 80% -h 80% "glow -p <file>"
    # 非 tmux：glow -p <file>（降級）
}
```

關鍵點：
- `display-popup` 的 `-w 80% -h 80%` 設定 popup 大小
- glow 用 `-p` pager 模式，使用者按 `q` 退出 → popup 自動關閉
- 非 tmux 環境直接用 `glow -p` 一樣能用

### sdd-last

```bash
sdd-last() {
    local n="${1:-1}"
    # find .md 按修改時間排序，取最近 n 個
    # n=1：直接 sdd-peek
    # n>1：fzf 選擇後 sdd-peek
}
```

關鍵點：
- 用 `find -name '*.md' -printf '%T@ %p\n' | sort -rn` 按時間排序
- 複用同樣的排除規則（.git, node_modules, bats-* 等）

### tmux popup 改造

```
# 從 split-window 改為 display-popup
bind-key R display-popup -w 80% -h 80% -d "#{pane_current_path}" "bash -ic 'sdd-review'"
```

關鍵點：
- `-d` 設定工作目錄（對應原本的 `-c`）
- popup 內的程式結束後自動關閉，不需要 `exec bash`
- W（sdd-watch）保持 split-window，因為需要持續顯示

### fzf 進階快捷鍵

在 sdd-review 的 fzf 呼叫中加入：
```
--bind "ctrl-/:toggle-preview"
--bind "ctrl-p:execute(tmux display-popup -w 80% -h 80% 'glow -p {}')"
```

### 關鍵決策

| 決策 | 選擇 | 替代方案 | 原因 |
|------|------|---------|------|
| popup 大小 | 80%x80% | 90%x90% | 80% 留邊距，視覺更好且能看到背景 pane |
| sdd-peek 非 tmux | glow -p 降級 | 報錯 | 保持零配置即可用原則 |
| sdd-last 排序 | find -printf + sort | stat + sort | -printf 效能更好，GNU find 支援 |
| W 保持 split | split-window | popup | watch 需要持續顯示在旁邊，popup 不適合 |

## 測試策略

- sdd-peek：function 存在、--help、檔案不存在報錯、非 tmux 降級邏輯、tmux popup 指令組裝
- sdd-last：function 存在、找到最近檔案、無 .md 提示、帶數量參數
- tmux config：R/S/D/T 改用 display-popup、W 保持 split-window、popup 大小正確
- sdd-review：新增 bind 存在（ctrl-/、ctrl-p）

## 向後相容性

- tmux keybinding 行為從 split 改為 popup — 使用者需要 `tmux source-file` 重新載入
- 不影響 shell function 的 CLI 用法
- 不影響 sdd-watch 的 split 行為
