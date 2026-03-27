#!/usr/bin/env bash
# SDD Review Toolkit - Main Loader
# Source this file in .bashrc/.zshrc to load all SDD review functions.

# Guard against multiple sourcing
[[ -n "$_SDD_REVIEW_LOADED" ]] && return 0
export _SDD_REVIEW_LOADED=1

_SDD_TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Source shared helpers first
source "$_SDD_TOOLKIT_DIR/_sdd-helpers.sh"

# Source all function modules
for _sdd_mod in "$_SDD_TOOLKIT_DIR"/sdd-*.sh; do
    [[ -f "$_sdd_mod" ]] && source "$_sdd_mod"
done
unset _sdd_mod
