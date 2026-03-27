# SDD Review Toolkit - Quick Reference

## 核心工作流

```
┌─────────────────────────────────────────────────────────────┐
│  tmux                                                       │
│  ┌──────────────────────┐  ┌─────────────────────────────┐  │
│  │                      │  │                             │  │
│  │   Claude Code        │  │   prefix + R                │  │
│  │   主要工作區         │  │   sdd-review 互動瀏覽       │  │
│  │                      │  │                             │  │
│  │   跑 SDD 流程        │  │   fzf 選檔                  │  │
│  │   產出 spec          │  │   glow 預覽                 │  │
│  │   執行任務           │  │   Ctrl+E → VSCode 修改     │  │
│  │                      │  │                             │  │
│  └──────────────────────┘  └─────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────────┐│
│  │  prefix + W  →  sdd-watch spec.md（自動刷新預覽）       ││
│  └──────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## Shell 指令

| 指令 | 用途 | 範例 |
|------|------|------|
| `sdd-review [dir]` | 互動瀏覽所有 .md | `sdd-review .` |
| `sdd-specs [dir]` | 只看 specs/ 目錄 | `sdd-specs` |
| `sdd-diff [n]` | 近期 git 變動的 .md | `sdd-diff 5` |
| `sdd-watch <file>` | 監控單檔自動刷新 | `sdd-watch specs/api/spec.md` |
| `sdd-multi f1 f2..` | 多 pane 同時開多檔 | `sdd-multi spec.md plan.md` |
| `sdd-tree [dir]` | 樹狀顯示文件結構 | `sdd-tree specs/` |

## fzf 預覽快捷鍵

| 按鍵 | 動作 |
|------|------|
| `ENTER` | glow 全螢幕打開 |
| `Ctrl+E` | VSCode 打開（不離開 fzf） |
| `Ctrl+Y` | 複製路徑到剪貼簿 |
| `Ctrl+D` | 預覽向下翻頁 |
| `Ctrl+U` | 預覽向上翻頁 |

## tmux 快捷鍵 (prefix + )

| 按鍵 | 動作 |
|------|------|
| `R` | 右側開 sdd-review |
| `S` | 右側開 sdd-specs |
| `D` | 右側開 sdd-diff |
| `W` | 下方開 sdd-watch |
| `E` | VSCode 開當前目錄 |
| `T` | 下方顯示文件樹 |

## 安裝

```bash
chmod +x setup.sh
./setup.sh
source ~/.bashrc   # or ~/.zshrc
tmux source-file ~/.tmux.conf
```
