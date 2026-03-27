# SDD Review Toolkit - Feature Spec

## US-1: 互動式文件瀏覽（P1 - MVP）

使用者在 terminal 中執行 `sdd-review`，透過 fzf 模糊搜尋選擇 .md 檔案，右側即時預覽 glow 渲染結果，按 ENTER 全螢幕閱讀。

**Why P1**: 這是整個 toolkit 的核心 — 不用離開 terminal 就能快速找到並閱讀 SDD 文件。

**Independent Test**: 在任何含有 .md 檔案的目錄執行 `sdd-review`，能看到 fzf 列表、右側 glow 預覽、ENTER 全螢幕、Ctrl+E 開 VS Code、Ctrl+Y 複製路徑。

**Acceptance Scenarios**:
- Given 一個含有 10 個 .md 的專案目錄，When 執行 `sdd-review`，Then fzf 列出所有 .md 且右側顯示 glow 預覽
- Given fzf 選中一個檔案，When 按 ENTER，Then glow 全螢幕顯示該檔案
- Given fzf 選中一個檔案，When 按 Ctrl+E，Then VS Code 開啟該檔案，fzf 不關閉
- Given fzf 選中一個檔案，When 按 Ctrl+Y，Then 檔案路徑複製到剪貼簿

## US-2: SDD 目錄自動偵測（P1 - MVP）

使用者執行 `sdd-review` 或 `sdd-specs` 時，工具自動偵測當前專案使用的 SDD 結構（SpecKit `.specify/` + `specs/` 或 OpenSpec `openspec/`），並優先顯示對應目錄的文件。

**Why P1**: SDD 工作流必然有 `.specify/` 或 `openspec/` 目錄，手動指定路徑是不必要的摩擦。

**Independent Test**: 在有 `.specify/` 的專案跑 `sdd-specs`，自動定位到 `specs/`；在有 `openspec/` 的專案跑 `sdd-specs`，自動定位到 `openspec/`。

**Acceptance Scenarios**:
- Given 專案有 `.specify/` 和 `specs/` 目錄，When 執行 `sdd-specs`，Then 列出 `specs/` 下的 .md
- Given 專案有 `openspec/` 目錄，When 執行 `sdd-specs`，Then 列出 `openspec/` 下的 .md
- Given 專案兩者都沒有，When 執行 `sdd-specs`，Then 顯示提示訊息並 fallback 到當前目錄
- Given 使用者帶參數 `sdd-specs custom-dir/`，When 執行，Then 以使用者指定的路徑為優先

## US-3: 檔案監控自動刷新（P1 - MVP）

使用者執行 `sdd-watch spec.md`，當 Claude Code 在另一個 pane 產出或修改該檔案時，監控 pane 自動重新渲染最新內容。

**Why P1**: SDD 流程中 Claude Code 持續產出文件，即時看到最新內容是核心 review 體驗。

**Independent Test**: 開兩個 tmux pane，一個跑 `sdd-watch test.md`，另一個修改 test.md，watch pane 在 1-2 秒內自動刷新。

**Acceptance Scenarios**:
- Given `sdd-watch spec.md` 執行中，When 另一個 pane 修改了 spec.md，Then watch pane 自動重新渲染
- Given 系統有 `inotifywait`，When 執行 sdd-watch，Then 使用事件驅動（不 polling）
- Given 系統沒有 `inotifywait`，When 執行 sdd-watch，Then fallback 到 polling（sleep 1）並提示安裝建議
- Given 使用者按 Ctrl+C，When watch 執行中，Then 乾淨退出

## US-4: tmux 快捷鍵整合（P1 - MVP）

使用者在 tmux 中按 prefix + R/S/D/W/T，快速在新 pane 中開啟對應的 review 工具，不打斷 Claude Code 工作 pane。

**Why P1**: 減少手動輸入指令的步驟，一鍵就能進入 review 模式。

**Independent Test**: 在 tmux session 中按 prefix + R，右側開出 sdd-review pane。

**Acceptance Scenarios**:
- Given 在 tmux 中，When 按 prefix + R，Then 右側 55% 開出 sdd-review
- Given 在 tmux 中，When 按 prefix + S，Then 右側開出 sdd-specs（自動偵測 SDD 目錄）
- Given 在 tmux 中，When 按 prefix + D，Then 右側開出 sdd-diff
- Given 在 tmux 中，When 按 prefix + W，Then 下方 40% 開出 sdd-watch（提示輸入檔名）
- Given 在 tmux 中，When 按 prefix + T，Then 下方 30% 開出 sdd-tree
- Given 在 tmux 中，When 按 prefix + E，Then VS Code 開啟當前 pane 目錄

## US-5: 近期變動文件瀏覽（P2）

使用者執行 `sdd-diff`，快速看到最近被 Claude Code 或自己修改過的 .md 檔案，聚焦在需要 review 的內容。

**Why P2**: 比 `sdd-review` 更精準 — SDD 流程中通常只需要看最近產出的文件，不是全部。

**Independent Test**: 在 git repo 中修改幾個 .md 後執行 `sdd-diff`，只列出有變動的檔案。

**Acceptance Scenarios**:
- Given 一個 git repo，When 執行 `sdd-diff 5`，Then 列出近 5 個 commits 中變動的 .md
- Given 不是 git repo，When 執行 `sdd-diff`，Then fallback 到最近 1 天內修改的 .md
- Given 沒有任何變動的 .md，When 執行 `sdd-diff`，Then 顯示提示訊息

## US-6: 文件結構總覽（P2）

使用者執行 `sdd-tree`，以正確的樹狀結構顯示 SDD 文件架構，快速了解目前的 spec 組織。

**Why P2**: 文件多了之後需要鳥瞰全貌，但不是每次 review 都需要。

**Independent Test**: 在有多層 specs 目錄的專案跑 `sdd-tree`，顯示正確的層級縮排。

**Acceptance Scenarios**:
- Given 專案有 `specs/001-feature/spec.md` 等多層結構，When 執行 `sdd-tree`，Then 顯示正確樹狀結構
- Given 系統有 `tree` 指令，When 執行 `sdd-tree`，Then 使用 `tree` 並過濾只顯示 .md
- Given 系統沒有 `tree` 指令，When 執行 `sdd-tree`，Then 使用 find + awk fallback
- Given 文件超過 50 個，When 執行 `sdd-tree`，Then 截斷並顯示總數

## US-7: 多檔同時 Review（P2）

使用者執行 `sdd-multi spec.md plan.md tasks.md`，在多個 tmux pane 中同時開啟多個文件，方便交叉對照。

**Why P2**: SDD 常需要同時看 spec + plan + tasks 確認一致性，但不是每次都需要。

**Independent Test**: 在 tmux 中執行 `sdd-multi a.md b.md c.md`，開出 3 個 tiled pane 各顯示一個檔案。

**Acceptance Scenarios**:
- Given 在 tmux 中，When 執行 `sdd-multi spec.md plan.md`，Then 開出 2 個 pane 各顯示一個檔案
- Given 不在 tmux 中，When 執行 `sdd-multi`，Then 顯示錯誤提示需要 tmux
- Given 無參數，When 執行 `sdd-multi`，Then 顯示用法說明

## US-8: Review Sign-off 機制（P3）

使用者執行 `sdd-approve spec.md`，在文件中加入 sign-off 標記（日期 + reviewer），紀錄 review 完成狀態。

**Why P3**: 減少為了標記 sign-off 而切到 VS Code 的理由，但可以先手動完成。

**Independent Test**: 執行 `sdd-approve specs/001/spec.md`，檔案中的 `⬜ 待確認` 被更新為 `✅ 已確認 (2026-03-27)`。

**Acceptance Scenarios**:
- Given spec.md 有 sign-off 區塊，When 執行 `sdd-approve spec.md`，Then ⬜ 更新為 ✅ + 日期
- Given spec.md 沒有 sign-off 區塊，When 執行 `sdd-approve spec.md`，Then 顯示「此文件無 sign-off 區塊」
- Given 已經 ✅ 的 sign-off，When 再次執行 `sdd-approve`，Then 提示已經 approved

---

## Requirements

### Functional Requirements

| ID | 需求 | 優先級 |
|----|------|--------|
| FR-001 | setup.sh MUST 冪等 — 重跑不破壞已有設定 | MUST |
| FR-002 | setup.sh MUST 檢查並安裝 glow、fzf 依賴 | MUST |
| FR-003 | setup.sh SHOULD 檢查並建議安裝 inotify-tools、tree、bat | SHOULD |
| FR-004 | shell functions MUST 在 bash 和 zsh 下都能用 | MUST |
| FR-005 | 所有 functions 無參數時 MUST 顯示用法或合理預設行為 | MUST |
| FR-006 | sdd-watch MUST 優先使用 inotifywait，無則 fallback polling | MUST |
| FR-007 | sdd-specs MUST 自動偵測 `.specify/`、`openspec/`、`specs/` 目錄 | MUST |
| FR-008 | sdd-tree SHOULD 優先使用 `tree` 指令，無則 fallback find+awk | SHOULD |
| FR-009 | tmux keybindings MUST 獨立為 `.tmux-sdd.conf`，不覆蓋使用者現有設定 | MUST |
| FR-010 | sdd-diff MUST 正確處理 git / non-git 兩種環境 | MUST |

### Key Entities

| Entity | 說明 | 關鍵屬性 |
|--------|------|----------|
| SDD Project | 被 review 的專案目錄 | SDD type（speckit / openspec / unknown）、root path |
| MD Document | 單一 .md 文件 | 路徑、最後修改時間、所屬 SDD 階段 |
| Review Session | 一次 sdd-review 的互動 | 選中的文件、操作（view / edit / copy） |

---

## Success Criteria

| 指標 | 目標 |
|------|------|
| 從 Claude Code 產出文件到開始 review 的時間 | < 3 秒（一個 tmux keybinding） |
| 需要切到 VS Code 的場景佔比 | 從 ~100% 降到 < 20%（僅深度編輯） |
| setup.sh 安裝成功率（WSL2 Ubuntu） | 100% |
| 支援不在 tmux 的降級使用 | shell functions 全部可獨立使用 |
