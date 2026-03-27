---
target_spec: (new — no existing spec in openspec/specs/)
change: add-quick-preview-ux
created_at: 2026-03-27T04:50:00+08:00
---

# Delta Spec: 快速預覽 UX 優化

## ADDED

### sdd-peek: tmux popup 快速預覽
**ID**: REQ-011
**Priority**: MUST

使用者執行 `sdd-peek <file.md>`，在 tmux popup 浮動視窗中用 glow 渲染檔案內容，按 `q` 關閉。

**驗收場景**:
- **Scenario: 正常預覽**
  - Given 在 tmux 中且檔案存在
  - When 執行 `sdd-peek spec.md`
  - Then tmux popup 顯示 glow 渲染內容，按 q 關閉 popup

- **Scenario: 非 tmux 環境降級**
  - Given 不在 tmux 中
  - When 執行 `sdd-peek spec.md`
  - Then 直接用 glow pager 模式顯示（降級，不報錯）

- **Scenario: 檔案不存在**
  - Given 指定的檔案不存在
  - When 執行 `sdd-peek nonexistent.md`
  - Then 顯示錯誤訊息

- **Scenario: 無參數**
  - Given 無參數
  - When 執行 `sdd-peek`
  - Then 顯示用法

### sdd-last: 預覽最近修改的 .md
**ID**: REQ-012
**Priority**: MUST

使用者執行 `sdd-last`，自動找到當前目錄下最近修改的 .md 檔案並用 `sdd-peek` 預覽。

**驗收場景**:
- **Scenario: 正常使用**
  - Given 目錄下有多個 .md 且最近修改的是 plan.md
  - When 執行 `sdd-last`
  - Then 用 sdd-peek 預覽 plan.md

- **Scenario: 帶數量參數**
  - Given 目錄下有多個 .md
  - When 執行 `sdd-last 3`
  - Then 用 fzf 列出最近修改的 3 個 .md 供選擇

- **Scenario: 無 .md 檔案**
  - Given 目錄下沒有 .md
  - When 執行 `sdd-last`
  - Then 顯示提示訊息

### tmux keybindings 改用 popup
**ID**: REQ-013
**Priority**: MUST

tmux prefix + R/S/D/T 從 split-window 改為 display-popup，review 完自動消失。W 保持 split（watch 需要持續顯示）。

**驗收場景**:
- **Scenario: popup 模式**
  - Given 在 tmux 中
  - When 按 prefix + R
  - Then 彈出 80%x80% 的 popup 視窗執行 sdd-review，ESC/關閉後 popup 消失

- **Scenario: W 保持 split**
  - Given 在 tmux 中
  - When 按 prefix + W
  - Then 仍然開右側 split pane（因為 watch 需要持續顯示）

### fzf 進階快捷鍵
**ID**: REQ-014
**Priority**: SHOULD

在 sdd-review 的 fzf 中加入更多快捷鍵提升瀏覽效率。

**驗收場景**:
- **Scenario: toggle preview**
  - Given 在 sdd-review 的 fzf 中
  - When 按 Ctrl+/
  - Then preview 視窗顯示/隱藏切換

- **Scenario: popup 預覽**
  - Given 在 sdd-review 的 fzf 中選中一個檔案
  - When 按 Ctrl+P
  - Then 用 sdd-peek 在 popup 中預覽該檔案（fzf 不關閉）
