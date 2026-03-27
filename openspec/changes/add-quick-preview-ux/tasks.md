---
change: add-quick-preview-ux
created_at: 2026-03-27T04:50:00+08:00
---

# Tasks: 快速預覽 UX 優化

**Proposal**: proposal.md | **Design**: design.md
**Total**: 8 | **Done**: 0

## Tasks

### Phase 1: 新增 functions

- [x] T-001 [REQ-011] 建立 `bin/sdd-peek.sh` — sdd-peek function：tmux 環境用 `display-popup -w 80% -h 80%` + `glow -p`，非 tmux 降級為 `glow -p`，含 --help、檔案不存在檢查
  (depends on: none)
- [x] T-002 [REQ-012] 建立 `bin/sdd-last.sh` — sdd-last function：`find -printf '%T@ %p\n' | sort -rn` 找最近 .md，n=1 直接 sdd-peek，n>1 用 fzf 選擇，含排除規則
  (depends on: T-001)

### Phase 2: 修改既有功能

- [x] T-003 [P] [REQ-013] 修改 `tmux/.tmux-sdd.conf` — R/S/D/T 從 `split-window` 改為 `display-popup -w 80% -h 80% -d "#{pane_current_path}"`，W 保持 split-window
  **禁止修改**: `bin/`, `tests/`
  (depends on: none)
- [x] T-004 [P] [REQ-014] 修改 `bin/sdd-review.sh` — fzf 加入 `--bind "ctrl-/:toggle-preview"` 和 `--bind "ctrl-p:execute(...)"`
  **禁止修改**: `tmux/`, 其他 `bin/sdd-*.sh`
  (depends on: T-001)

📍 **Checkpoint**: sdd-peek、sdd-last 可用，tmux popup 可用

### Phase 3: 測試

- [x] T-005 [P] 建立 `tests/sdd-peek.bats` — function 存在、--help、檔案不存在、非 tmux 降級、popup 指令組裝
  **禁止修改**: `bin/`, `tmux/`
  (depends on: T-001)
- [x] T-006 [P] 建立 `tests/sdd-last.bats` — function 存在、找到最近 .md、無 .md 提示、帶數量參數
  **禁止修改**: `bin/`, `tmux/`
  (depends on: T-002)
- [x] T-007 [P] 更新 `tests/tmux-keybindings.bats` — R/S/D/T 改用 display-popup、W 保持 split、popup 大小 80%
  **禁止修改**: `bin/`, `tmux/`（除讀取外）
  (depends on: T-003)
- [x] T-008 [P] 更新 `tests/sdd-review.bats` — 新增 ctrl-/ 和 ctrl-p bind 存在的測試
  **禁止修改**: `bin/`, `tmux/`（除讀取外）
  (depends on: T-004)

📍 **Checkpoint**: 所有測試通過（既有 73 + 新增）

## Dependency Graph

```
T-001 → T-002 → T-006
T-001 → T-004 → T-008
T-001 → T-005
T-003 → T-007
```

T-001 和 T-003 可並行（不同檔案）
Phase 3 的 4 個測試 task 全部可並行
