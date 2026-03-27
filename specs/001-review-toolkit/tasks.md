---
source: spec.md + plan.md
spec_hash: 7326a2f840111cc37ab30ea02cfcb738e524fa0fc12e4ca07ec78140f35d3705
plan_hash: 24b96ec121e746bb55cb65d7098f5f4de4a287f58f132a8c2d6db3d0c225065f
status: completed
generated_at: 2026-03-27T00:00:00+08:00
---

# Tasks: SDD Review Toolkit

**Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md) | **Generated**: 2026-03-27
**Total Tasks**: 28 | **Phases**: 10 | **Waves**: 10

## Format: `[ID] [P?] [Story?] Description`
- **[P]**: Can run in parallel (different files, no shared state)
- **[USn]**: Which user story this belongs to

---

## Phase 1: Setup

- [x] T-001 建立專案目錄結構：`bin/`, `tmux/`, `tests/test_helper/`
- [x] T-002 [P] 初始化 bats-core 測試框架，建立 `tests/test_helper/common-setup.bash` — 含 source sdd-functions.sh 的共用 setup
- [x] T-003 [P] 建立 `bin/sdd-functions.sh` 骨架 — shebang、guard（防止重複 source）、空 function stubs

📍 **Checkpoint**: 專案結構就緒，`source bin/sdd-functions.sh` 不報錯

---

## Phase 2: Foundational — Shared Helpers

⚠️ **BLOCKS all user stories** — helpers 被所有 function 共用

- [x] T-004 實作 `_sdd_check_dep()` in `bin/sdd-functions.sh` — 參數：command name, install hint；不存在時印提示並回傳 1
- [x] T-005 [P] 實作 `_sdd_detect_type()` in `bin/sdd-functions.sh` — 偵測 .specify/ → speckit, openspec/ → openspec, 都沒有 → unknown；回傳對應目錄路徑
  **禁止修改**: `tmux/`, `tests/`（除自己的單元測試外）
- [x] T-006 [P] 實作 `_sdd_clipboard()` in `bin/sdd-functions.sh` — 優先 xclip, fallback xsel, WSL2 用 clip.exe
  **禁止修改**: `tmux/`, `tests/`（除自己的單元測試外）
- [x] T-007 [P] 實作 `_sdd_glow_render()` in `bin/sdd-functions.sh` — 統一 glow 呼叫，處理 terminal 寬度、style 參數
  **禁止修改**: `tmux/`, `tests/`（除自己的單元測試外）
- [x] T-008 撰寫 helpers 測試 in `tests/helpers.bats` — 涵蓋 _sdd_detect_type 三種情境、_sdd_check_dep 存在/不存在
  (depends on T-004, T-005, T-006, T-007)

📍 **Checkpoint**: `bats tests/helpers.bats` 全部通過

---

## Phase 3: User Story 1 — 互動式文件瀏覽 (P1) 🎯 MVP

**Goal**: 在 terminal 中用 fzf + glow 模糊搜尋並預覽 .md 檔案
**Independent Test**: 在含 .md 的目錄執行 `sdd-review`，能看到 fzf 列表、glow 預覽、ENTER 全螢幕、Ctrl+E 開 VS Code、Ctrl+Y 複製路徑

### Implementation

- [x] T-009 [US1] 實作 `sdd-review` in `bin/sdd-functions.sh` — fzf 列出 .md、右側 glow preview、ENTER 全螢幕 glow、Ctrl+E 開 VS Code（`code` CLI）、Ctrl+Y 呼叫 `_sdd_clipboard`
  (depends on T-004, T-006, T-007)
- [x] T-010 [US1] 撰寫測試 in `tests/sdd-review.bats` — 驗證：無參數列出 .md、fzf 預覽指令正確、無 .md 時顯示提示
  (depends on T-009)

📍 **Checkpoint**: US1 可用 — 在含 .md 目錄跑 `sdd-review` 完成所有 acceptance scenarios

---

## Phase 4: User Story 2 — SDD 目錄自動偵測 (P1) 🎯 MVP

**Goal**: `sdd-specs` 自動偵測 SDD 結構並列出對應目錄的文件
**Independent Test**: 在有 `.specify/` 的專案跑 `sdd-specs` 自動定位到 `specs/`；有 `openspec/` 則定位到 `openspec/`

### Implementation

- [x] T-011 [US2] 實作 `sdd-specs` in `bin/sdd-functions.sh` — 呼叫 `_sdd_detect_type` 取得目錄，將結果餵給 fzf + glow（複用 sdd-review 的 preview 邏輯）；支援帶參數覆寫目錄
  (depends on T-005, T-009)
- [x] T-012 [US2] 撰寫測試 in `tests/sdd-specs.bats` — 驗證：speckit 目錄偵測、openspec 偵測、fallback 到當前目錄、手動指定路徑
  (depends on T-011)

📍 **Checkpoint**: US2 可用 — `sdd-specs` 在不同 SDD 專案中正確偵測

---

## Phase 5: User Story 3 — 檔案監控自動刷新 (P1) 🎯 MVP

**Goal**: `sdd-watch spec.md` 在檔案被修改時自動重新渲染
**Independent Test**: 兩個 tmux pane，一個 watch、一個修改，watch pane 1-2 秒內刷新

### Implementation

- [x] T-013 [US3] 實作 `sdd-watch` in `bin/sdd-functions.sh` — 優先 inotifywait 事件驅動（`inotifywait -m -e modify`），fallback polling（`sleep 1` + checksum 比對）；Ctrl+C 乾淨退出（trap SIGINT）
  (depends on T-004, T-007)
- [x] T-014 [US3] 撰寫測試 in `tests/sdd-watch.bats` — 驗證：有 inotifywait 時使用事件驅動、無 inotifywait 時 fallback polling、無參數顯示用法
  (depends on T-013)

📍 **Checkpoint**: US3 可用 — 修改檔案後 watch pane 自動刷新

---

## Phase 6: User Story 4 — tmux 快捷鍵整合 (P1) 🎯 MVP

**Goal**: prefix + R/S/D/W/T/E 一鍵開出 review pane
**Independent Test**: tmux 中按 prefix + R，右側開出 sdd-review pane

### Implementation

- [x] T-015 [US4] 建立 `tmux/.tmux-sdd.conf` — 定義 6 個 keybindings：R→sdd-review（split-window -h -p 55）、S→sdd-specs、D→sdd-diff、W→sdd-watch（split-window -v -p 40 + 提示輸入檔名）、T→sdd-tree（split-window -v -p 30）、E→code .
  (depends on T-009, T-011, T-013)
- [x] T-016 [US4] 撰寫測試 in `tests/tmux-keybindings.bats` — 驗證：.tmux-sdd.conf 語法正確（`tmux source-file` 不報錯）、所有 6 個 binding 存在
  (depends on T-015)

📍 **Checkpoint**: US4 可用 — tmux 中所有 keybindings 觸發正確的 function

---

## Phase 7: User Story 5 — 近期變動文件瀏覽 (P2)

**Goal**: `sdd-diff` 列出最近被修改的 .md 檔案
**Independent Test**: git repo 中修改幾個 .md 後執行 `sdd-diff`，只列出有變動的檔案

### Implementation

- [x] T-017 [US5] 實作 `sdd-diff` in `bin/sdd-functions.sh` — git 環境：`git diff --name-only HEAD~N -- '*.md'`（預設 N=5，可帶參數）；非 git：`find -mtime -1 -name '*.md'`；結果餵 fzf + glow preview
  (depends on T-004, T-007)
- [x] T-018 [US5] 撰寫測試 in `tests/sdd-diff.bats` — 驗證：git repo 中正確列出變動 .md、非 git fallback、無變動時提示、自訂 commit 數量
  (depends on T-017)

📍 **Checkpoint**: US5 可用 — `sdd-diff` 在 git/non-git 環境都正確

---

## Phase 8: User Story 6 + 7 — 文件結構總覽 & 多檔 Review (P2)

### US-6: 文件結構總覽

**Goal**: `sdd-tree` 以樹狀結構顯示 SDD 文件架構
**Independent Test**: 多層 specs 目錄跑 `sdd-tree` 顯示正確層級

- [x] T-019 [P] [US6] 實作 `sdd-tree` in `bin/sdd-functions.sh` — 優先 `tree -P '*.md'`，fallback `find + awk` 自製樹狀輸出；超過 50 個檔案時截斷並顯示總數
  (depends on T-004)
  **禁止修改**: `tmux/`, 其他 function 的邏輯區塊
- [x] T-020 [P] [US6] 撰寫測試 in `tests/sdd-tree.bats` — 驗證：有 tree 時用 tree、無 tree 時 fallback、超過 50 個截斷
  (depends on T-019)
  **禁止修改**: `bin/sdd-functions.sh`（除閱讀外）, `tmux/`

### US-7: 多檔同時 Review

- [x] T-021 [P] [US7] 實作 `sdd-multi` in `bin/sdd-functions.sh` — 檢查 tmux 環境、接受多個檔名參數、為每個檔案 split-pane + glow render；無參數顯示用法；不在 tmux 則報錯
  (depends on T-007)
  **禁止修改**: `tmux/`, 其他 function 的邏輯區塊
- [x] T-022 [P] [US7] 撰寫測試 in `tests/sdd-multi.bats` — 驗證：無參數顯示用法、非 tmux 報錯、正確拆分參數
  (depends on T-021)
  **禁止修改**: `bin/sdd-functions.sh`（除閱讀外）, `tmux/`

📍 **Checkpoint**: US6 + US7 可用

---

## Phase 9: User Story 8 — Review Sign-off (P3)

**Goal**: `sdd-approve spec.md` 更新文件中的 sign-off 標記
**Independent Test**: 執行後 `⬜ 待確認` 變成 `✅ 已確認 (2026-03-27)`

### Implementation

- [x] T-023 [US8] 實作 `sdd-approve` in `bin/sdd-functions.sh` — sed 替換 `⬜` 行為 `✅ 已確認 ($(date +%Y-%m-%d))`；無 sign-off 區塊時提示；已 ✅ 時提示已 approved
  (depends on 無)
- [x] T-024 [US8] 撰寫測試 in `tests/sdd-approve.bats` — 驗證：正常替換、無 sign-off 區塊提示、重複 approve 提示
  (depends on T-023)

📍 **Checkpoint**: US8 可用

---

## Phase 10: Setup Script & Polish

- [x] T-025 實作 `setup.sh` — 冪等安裝腳本：檢查/安裝 glow + fzf（apt/brew）、建議安裝 inotify-tools + tree + bat、在 .bashrc/.zshrc 加 `source` 行（檢查已存在則跳過）、在 .tmux.conf 加 `source-file`（檢查已存在則跳過）
  (depends on T-015)
- [x] T-026 [P] 撰寫測試 in `tests/setup.bats` — 驗證：冪等性（跑兩次不重複）、已安裝依賴時跳過、source 行正確加入
  (depends on T-025)
  **禁止修改**: `bin/`, `tmux/`
- [x] T-027 [P] 所有 functions 加 `--help` 支援 — 無參數或 `--help` 時顯示用法摘要
  (depends on T-009 ~ T-023)
  **禁止修改**: `setup.sh`, `tmux/`, `tests/`
- [x] T-028 [P] 建立 `README.md` — 安裝步驟、功能列表、依賴需求、tmux keybindings 表
  **禁止修改**: `bin/`, `tmux/`, `tests/`, `setup.sh`

📍 **Checkpoint**: `setup.sh` 在乾淨 WSL2 Ubuntu 上一鍵安裝成功

---

## Dependency Graph

### Phase Flow
```
Phase 1 (Setup) → Phase 2 (Helpers) → Phase 3~6 (P1 Stories) → Phase 7~9 (P2/P3 Stories) → Phase 10 (Polish)
```

### Task Dependencies
```
T-001 → T-002, T-003
T-003 → T-004, T-005, T-006, T-007
T-004~T-007 → T-008

T-004, T-006, T-007 → T-009 → T-010
T-005, T-009 → T-011 → T-012
T-004, T-007 → T-013 → T-014
T-009, T-011, T-013 → T-015 → T-016

T-004, T-007 → T-017 → T-018
T-004 → T-019 → T-020
T-007 → T-021 → T-022
(無依賴) → T-023 → T-024

T-015 → T-025 → T-026
T-009~T-023 → T-027
```

### Cross-Story Dependencies
- US-2（sdd-specs）depends on US-1（sdd-review）的 fzf+glow preview 邏輯
- US-4（tmux bindings）depends on US-1, US-2, US-3 的 function 存在
- 其餘 stories 互相獨立

---

## Wave Execution Plan

| Wave | Tasks | Rationale |
|------|-------|-----------|
| 1 | T-001 | 專案結構 |
| 2 | T-002, T-003 | [P] bats setup + function 骨架 |
| 3 | T-004, T-005, T-006, T-007 | [P] 四個 shared helpers（互不依賴） |
| 4 | T-008, T-009, T-023 | helpers 測試 + sdd-review + sdd-approve（互不依賴） |
| 5 | T-010, T-011, T-013, T-017, T-019, T-021, T-024 | [P] US1 測試 + US2/3/5/6/7 實作 + US8 測試 |
| 6 | T-012, T-014, T-018, T-020, T-022 | [P] US2/3/5/6/7 測試 |
| 7 | T-015 | tmux keybindings（需要 US1/2/3 function 存在） |
| 8 | T-016 | tmux 測試 |
| 9 | T-025 | setup.sh |
| 10 | T-026, T-027, T-028 | [P] setup 測試 + --help + README |

**Solo developer**: 按 wave 順序，同 wave 內的 [P] tasks 任意順序
**AI agents**: wave 3（4 helpers 並行）和 wave 5/6（多 story 並行）可最大化加速

---

## Self-Validation

| Check | Pass? |
|-------|-------|
| Every user story from spec has tasks? | ✅ US1~US8 全部覆蓋 |
| Every task has exact file path? | ✅ 全部指定到檔案層級 |
| Every task has [USn] label (except setup/foundational/polish)? | ✅ |
| No [P] tasks in same wave modify same file? | ✅ |
| Every [P] task has 禁止修改 constraint listed? | ✅ |
| 共用資源（bin/sdd-functions.sh）有唯一擁有者？ | ✅ 同 wave 的 [P] tasks 分別負責不同 function |
| P1 story completable without P2/P3? | ✅ Phase 3~6 不依賴 Phase 7~9 |
| No circular dependencies? | ✅ |
| Waves respect all dependency arrows? | ✅ |
| Checkpoint after each user story? | ✅ |
