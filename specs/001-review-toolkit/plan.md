---
source: spec.md
source_hash: 7326a2f840111cc37ab30ea02cfcb738e524fa0fc12e4ca07ec78140f35d3705
status: current
generated_at: 2026-03-27T00:00:00+08:00
---

# SDD Review Toolkit - Technical Plan

## 方向摘要

我們打算這樣做：
- 用 **shell functions + fzf + glow** 組合出一套 terminal 內的 markdown review 工具，不寫任何自定義 binary
- 所有功能拆成獨立 shell functions（`sdd-review`、`sdd-specs`、`sdd-watch` 等），各自可單獨使用；tmux keybindings 是加速層，不是必要條件
- `setup.sh` 一鍵安裝，冪等設計（重跑不壞），自動檢查依賴並提示安裝
- tmux 設定獨立為 `.tmux-sdd.conf`，用 `source-file` 載入，**不覆寫**使用者的 `.tmux.conf`

**需要業務確認的決策**：
1. **shell functions 載入方式**：我們選擇把所有 functions 寫在一個 `sdd-functions.sh`，由 `setup.sh` 加一行 `source` 到 `.bashrc`/`.zshrc`。這樣使用者 `source ~/.bashrc` 就能用。你 OK 嗎？
2. **sign-off 格式**：US-8 的 `sdd-approve` 會用 `sed` 替換 `⬜` 為 `✅ 已確認 (日期)`。這表示文件中需要有固定的 sign-off 格式。目前 spec 範例是 `⬜ 待確認` → `✅ 已確認 (2026-03-27)`，確認這個格式？

---
（以下為技術細節）

## Technical Context

**Language/Version**: Bash (POSIX-compatible where possible, bash/zsh 雙支援)
**Primary Dependencies**: glow (markdown renderer), fzf (fuzzy finder)
**Optional Dependencies**: inotify-tools (file watch), tree (directory tree), bat (syntax highlight fallback)
**Storage**: N/A（無持久化需求）
**Testing**: bats-core (Bash Automated Testing System)
**Target Platform**: Linux (native + WSL2)
**Project Type**: single
**Performance Goals**: 啟動到可互動 < 3 秒；file watch 更新 < 2 秒
**Constraints**: 不引入需編譯的 binary；不做 GUI/web UI

## Constitution Check

| Principle | Plan Alignment | Status |
|-----------|---------------|--------|
| Terminal-first, IDE as escape hatch | 所有功能在 terminal 完成，Ctrl+E 開 VS Code 作為 escape hatch | ✅ |
| 零配置即可用，漸進式增強 | `setup.sh` 安裝後直接可用；tmux keybindings 是可選增強 | ✅ |
| 組合現有工具，不造輪子 | 核心邏輯是 fzf + glow + inotifywait + tree 的膠水層 | ✅ |
| 感知 SDD 目錄結構 | `_sdd_detect_type()` 自動偵測 .specify/ / openspec/ / specs/ | ✅ |

## Project Structure

```
sdd-review-toolkit/
├── .specify/
│   └── constitution.md
├── specs/
│   └── 001-review-toolkit/
│       ├── spec.md
│       └── plan.md              ← 本文件
├── bin/
│   └── sdd-functions.sh         ← 所有 shell functions（source 載入）
├── tmux/
│   └── .tmux-sdd.conf           ← tmux keybindings（source-file 載入）
├── setup.sh                     ← 冪等安裝腳本
├── tests/
│   ├── test_helper/
│   │   └── common-setup.bash    ← bats 共用 setup
│   ├── sdd-review.bats
│   ├── sdd-specs.bats
│   ├── sdd-watch.bats
│   ├── sdd-diff.bats
│   ├── sdd-tree.bats
│   ├── sdd-multi.bats
│   ├── sdd-approve.bats
│   └── setup.bats
└── README.md
```

**Decision**: 所有 functions 集中在單一 `sdd-functions.sh`，而非拆成多個檔案。理由：
- 使用者只需 `source` 一個檔案
- Functions 之間共用 helper（`_sdd_detect_type`、`_sdd_check_dep`），拆開反而需要處理載入順序
- 總量預估 < 500 行，單檔可維護

## Architecture Decisions

### AD-001: Functions vs Standalone Scripts

**Context**: shell functions（`source` 載入）和獨立 scripts（放 `$PATH`）兩種做法都可以
**Decision**: Shell functions，集中在 `bin/sdd-functions.sh`
**Alternatives Rejected**:
- 獨立 scripts 放 `~/.local/bin/`：需要管理 PATH、每個 script 獨立載入 helpers 較麻煩
- 混合模式：增加安裝複雜度，對使用者無明顯好處

### AD-002: Dependency Check 策略

**Context**: 必要依賴（glow, fzf）缺少時，function 完全無法運作；可選依賴（inotifywait, tree, bat）缺少時應降級
**Decision**:
- `setup.sh` 安裝時檢查並嘗試安裝必要依賴（apt/brew）
- 每個 function 執行時只檢查自己需要的依賴（lazy check），失敗時給出安裝指令
- 可選依賴缺少時自動 fallback + 一次性提示
**Alternatives Rejected**:
- 啟動時全部檢查：拖慢 shell 啟動速度，因為 `source` 發生在每次開 terminal

### AD-003: tmux Keybindings 隔離

**Context**: 直接寫入 `.tmux.conf` 有覆寫使用者設定的風險
**Decision**: 獨立 `tmux/.tmux-sdd.conf`，`setup.sh` 在 `.tmux.conf` 加一行 `source-file`（冪等，檢查已存在則跳過）
**Alternatives Rejected**:
- 直接 append 到 `.tmux.conf`：不冪等，重跑會重複
- tmux plugin manager (tpm)：增加額外依賴

### AD-004: Testing Framework

**Context**: Shell scripts 測試選項有限
**Decision**: bats-core — Bash 生態最成熟的測試框架，語法直覺
**Alternatives Rejected**:
- shunit2：API 較笨重
- 純手動測試：不符合 TDD 原則

### AD-005: 剪貼簿操作（Ctrl+Y 複製路徑）

**Context**: WSL2 和 native Linux 的剪貼簿工具不同
**Decision**: 優先用 `xclip`，fallback `xsel`，WSL2 環境用 `clip.exe`
**Alternatives Rejected**:
- 只支援一種：降低跨平台相容性

## Function 設計概覽

| Function | 依賴（必要） | 依賴（可選） | 對應 US |
|----------|-------------|-------------|---------|
| `sdd-review` | fzf, glow | bat | US-1 |
| `sdd-specs` | fzf, glow | — | US-2 |
| `sdd-watch` | glow | inotify-tools | US-3 |
| `sdd-diff` | fzf, glow | git | US-5 |
| `sdd-tree` | — | tree | US-6 |
| `sdd-multi` | tmux, glow | — | US-7 |
| `sdd-approve` | — | — | US-8 |
| _tmux bindings_ | tmux | — | US-4 |

### Shared Helpers（internal，以 `_sdd_` prefix）

| Helper | 用途 |
|--------|------|
| `_sdd_detect_type` | 偵測 SDD 目錄類型（speckit / openspec / unknown），回傳對應路徑 |
| `_sdd_check_dep` | 檢查指定指令是否存在，不存在時印出安裝提示 |
| `_sdd_clipboard` | 跨平台剪貼簿寫入（xclip / xsel / clip.exe） |
| `_sdd_glow_render` | 統一的 glow 渲染呼叫（處理寬度、style 等參數） |

## Complexity Tracking

| Metric | Value | Threshold | Status |
|--------|-------|-----------|--------|
| Dependencies (必要) | 2 (glow, fzf) | ≤ 8 | ✅ |
| Dependencies (可選) | 4 (inotify-tools, tree, bat, git) | ≤ 8 | ✅ |
| Shell functions (public) | 7 | ≤ 12 | ✅ |
| Shell helpers (internal) | 4 | ≤ 6 | ✅ |
| External integrations | 1 (VS Code via `code` CLI) | ≤ 3 | ✅ |
| Config files | 2 (sdd-functions.sh, .tmux-sdd.conf) | ≤ 4 | ✅ |
