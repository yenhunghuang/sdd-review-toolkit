# SDD Review Toolkit

Terminal-native 的 SDD（Spec-Driven Development）文件 review 工具。在 tmux + Claude Code 工作流中快速瀏覽、監控、審閱 `.md` 文件，減少切換 IDE 的 context switch。

## 安裝

```bash
bash setup.sh
source ~/.bashrc
```

### 依賴

| 工具 | 必要性 | 安裝 |
|------|--------|------|
| glow | 必要 | `sudo apt install glow` / `brew install glow` |
| fzf | 必要 | `sudo apt install fzf` / `brew install fzf` |
| inotify-tools | 建議 | `sudo apt install inotify-tools`（sdd-watch 事件驅動） |
| tree | 建議 | `sudo apt install tree`（sdd-tree 樹狀顯示） |
| bat | 選用 | `sudo apt install bat`（語法高亮 fallback） |

## Shell 指令

| 指令 | 說明 |
|------|------|
| `sdd-review [dir]` | 互動式 .md 瀏覽（fzf + glow preview） |
| `sdd-specs [dir]` | 自動偵測 SDD 結構並瀏覽 specs |
| `sdd-watch <file>` | 監控檔案變動，自動重新渲染 |
| `sdd-diff [N]` | 瀏覽最近 N 個 commits 變動的 .md |
| `sdd-tree [dir]` | 樹狀顯示 .md 文件結構 |
| `sdd-multi f1 f2 ...` | 多個 tmux pane 同時 review |
| `sdd-approve <file>` | 更新文件 sign-off 標記 |

所有指令支援 `--help`。

## fzf 快捷鍵

| 鍵 | 功能 |
|----|------|
| ENTER | glow 全螢幕閱讀 |
| Ctrl+E | VS Code 開啟（不關閉 fzf） |
| Ctrl+Y | 複製檔案路徑到剪貼簿 |

## tmux 快捷鍵

安裝後在 tmux 中使用 `prefix +`：

| 鍵 | 功能 | Pane |
|----|------|------|
| R | sdd-review | 右側 55% |
| S | sdd-specs | 右側 55% |
| D | sdd-diff | 右側 55% |
| W | sdd-watch（提示輸入檔名） | 下方 40% |
| T | sdd-tree | 下方 30% |
| E | VS Code 開啟當前目錄 | — |

## SDD 結構自動偵測

`sdd-specs` 自動偵測專案類型：

| 目錄 | 偵測結果 | 瀏覽目錄 |
|------|---------|----------|
| `.specify/` 存在 | SpecKit | `specs/` |
| `openspec/` 存在 | OpenSpec | `openspec/` |
| 都沒有 | fallback | 當前目錄 |

## 測試

```bash
./tests/test_helper/bats-core/bin/bats tests/*.bats
```

## 授權

MIT
