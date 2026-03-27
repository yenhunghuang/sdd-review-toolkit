# SDD Review Toolkit - Constitution

## Project Purpose

提供 SDD（Spec-Driven Development）開發者一套 terminal-native 的文件 review 工具，讓在 tmux + Claude Code 工作流中能快速瀏覽、監控、審閱大量 .md 文件，減少切換 IDE 的 context switch 成本。

## Core Principles

| # | 原則 | 為什麼 |
|---|------|--------|
| 1 | **Terminal-first, IDE as escape hatch** | 使用者的主要工作環境是 tmux，解法必須在 terminal 內完成 80% review 需求 |
| 2 | **零配置即可用，漸進式增強** | 安裝後 `sdd-review` 就能用；tmux keybindings 是加分不是必要 |
| 3 | **組合現有工具，不造輪子** | glow、fzf、tmux、inotifywait 都是成熟工具，本專案是膠水層 |
| 4 | **感知 SDD 目錄結構** | 自動偵測 `.specify/`、`openspec/`、`specs/` 等 SDD 慣例目錄 |

## Technical Boundaries

| Do | Don't |
|----|-------|
| Shell functions + tmux config | 不做 GUI 或 web UI |
| 支援 WSL2 + native Linux | 不直接支援 Windows（可透過 WSL 使用） |
| 依賴 glow、fzf 等可 apt/brew 安裝的工具 | 不引入需要編譯的自定義 binary |
| 提供 VS Code escape hatch（Ctrl+E） | 不取代 VS Code 的編輯功能 |

## Quality Standards

- setup.sh 一鍵安裝，冪等（重跑不壞）
- 所有 shell functions 有 `--help` 或無參數時顯示用法
- 在 tmux 外也能降級使用（少 tmux keybindings，functions 仍可用）
