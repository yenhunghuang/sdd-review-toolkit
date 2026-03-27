# Proposal: 快速預覽 UX 優化

## Sign-off

| Role | Name | Status | Date |
|------|------|--------|------|
| 業務/PM | ___ | ⬜ 待確認 | ___ |

### Review Notes
<!-- 確認 Tier 1 項目的範圍和優先順序是否正確 -->

---

## 動機

目前在 tmux 中預覽 .md 檔案需要多個步驟：開 split pane → 輸入指令 → 瀏覽 → 手動關閉 pane。對於「快速看一眼某個檔案」的場景，split pane 太重了；對於「看最近 Claude Code 剛產出什麼」的場景，需要手動找路徑。

## 目標

1. 一個指令快速預覽任意 .md，看完自動消失（不留殘餘 pane）
2. 零步驟找到最近修改的 .md 並預覽
3. tmux keybindings 從 split pane 升級為 popup 浮動視窗
4. fzf 瀏覽體驗更順暢（toggle preview、更多快捷鍵）

## 範圍

### 會做
- 新增 `sdd-peek <file>` — tmux popup 中 glow 預覽，按 q 關閉
- 新增 `sdd-last` — 自動找最近修改的 .md 並用 sdd-peek 預覽
- tmux keybindings 改用 `display-popup`（R/S/D/T），W 保持 split（watch 需要持續顯示）
- fzf 加入 `Ctrl+/` toggle preview、`Ctrl+P` popup 預覽選中檔案

### 不做
- 不做檔案編輯功能
- 不做 Claude Code hooks 整合（待驗證可行性，留給未來 change）
- 不做書籤/歷史系統
- 不做 SDD 階段分組顯示（Tier 2，留給下一個 change）

## 影響分析

- **使用者影響**: 新增 2 個指令（sdd-peek, sdd-last）；tmux 快捷鍵行為從 split 改為 popup（更輕量）
- **技術影響**: 新增 `bin/sdd-peek.sh`、`bin/sdd-last.sh`；修改 `tmux/.tmux-sdd.conf`、`bin/sdd-review.sh`
- **風險**: tmux popup 需要 tmux 3.3+（使用者已有 3.4，無風險）

## 成功標準

- `sdd-peek spec.md` 在 popup 中顯示渲染內容，按 q 自動關閉，< 1 秒啟動
- `sdd-last` 不帶參數即可預覽最近修改的 .md
- `Ctrl+B → R` 改用 popup 後，review 完自動消失不留 pane
- 所有既有測試仍通過 + 新功能有對應測試
