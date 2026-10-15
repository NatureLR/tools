# ==== p10k instant prompt ====
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
# HIST_STAMPS="yyyy-mm-dd"
HISTSIZE=1000000
SAVEHIST=100000
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt re_match_pcre
ZVM_LINE_INIT_MODE=$ZVM_MODE_NORMAL
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
bindkey -M vicmd "H" vi-beginning-of-line
bindkey -M vicmd "L" vi-end-of-line

fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}

if [ "$TERM" = "linux" ]; then
	printf %b '\e[40m' '\e[8]' # set default background to color 0 'dracula-bg'
	printf %b '\e[37m' '\e[8]' # set default foreground to color 7 'dracula-fg'
	printf %b '\e]P0282a36'    # redefine 'black'          as 'dracula-bg'
	printf %b '\e]P86272a4'    # redefine 'bright-black'   as 'dracula-comment'
	printf %b '\e]P1ff5555'    # redefine 'red'            as 'dracula-red'
	printf %b '\e]P9ff7777'    # redefine 'bright-red'     as '#ff7777'
	printf %b '\e]P250fa7b'    # redefine 'green'          as 'dracula-green'
	printf %b '\e]PA70fa9b'    # redefine 'bright-green'   as '#70fa9b'
	printf %b '\e]P3f1fa8c'    # redefine 'brown'          as 'dracula-yellow'
	printf %b '\e]PBffb86c'    # redefine 'bright-brown'   as 'dracula-orange'
	printf %b '\e]P4bd93f9'    # redefine 'blue'           as 'dracula-purple'
	printf %b '\e]PCcfa9ff'    # redefine 'bright-blue'    as '#cfa9ff'
	printf %b '\e]P5ff79c6'    # redefine 'magenta'        as 'dracula-pink'
	printf %b '\e]PDff88e8'    # redefine 'bright-magenta' as '#ff88e8'
	printf %b '\e]P68be9fd'    # redefine 'cyan'           as 'dracula-cyan'
	printf %b '\e]PE97e2ff'    # redefine 'bright-cyan'    as '#97e2ff'
	printf %b '\e]P7f8f8f2'    # redefine 'white'          as 'dracula-fg'
	printf %b '\e]PFffffff'    # redefine 'bright-white'   as '#ffffff'
	clear
fi


### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
# autoload +X zman
# autoload -Uz zcalc zmv zargs
# autoload -Uz _zinit
# (( ${+_comps} )) && _comps[zinit]=_zinit
# Load a few important annexes, without Turbo
# (this is currently required for annexes)
#
#

# == zsh-zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_AUTOSUGGEST_COMPLETION_IGNORE='( |man |pikaur -S )*'
ZSH_AUTOSUGGEST_HISTORY_IGNORE='?(#c50,)'

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=103'

GENCOMP_DIR=$XDG_CONFIG_HOME/zsh/completions

zstyle ':zce:*' keys 'asdghklqwertyuiopzxcvbnmfj;23456789'


zstyle ':fzf-tab:complete:_zlua:*' query-string input
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-preview 'ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:kill:argument-rest' fzf-flags '--preview-window=down:3:wrap'
zstyle ':fzf-tab:complete:kill:*' popup-pad 0 3
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0
# zstyle ":fzf-tab:*" fzf-flags --color=bg+:23
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ":completion:*:git-checkout:*" sort false
zstyle ':completion:*' file-sort modification
zstyle ':completion:*:exa' sort false
zstyle ':completion:files' sort false
zstyle ':fzf-tab:complete:*' fzf-preview 'echo $realpath | ~/scripts/fzf_preview.py'

zinit wait="0" lucid light-mode for \
    hlissner/zsh-autopair \
    jeffreytse/zsh-vi-mode \
    Aloxaf/gencomp \
    ellie/atuin \
    # Aloxaf/zsh-sqlite \
    # cloneopts="--branch zsqlite" Aloxaf/zsh-histdb 
# zinit ice wait="0" lucid atload="zshz >/dev/null"
# zinit light agkozak/zsh-z


zinit light-mode for \
    blockf \
        zsh-users/zsh-completions \
    # as="program" atclone="rm -f ^(rgg|agv)" \
    #     lilydjwg/search-and-view \
    # atclone="dircolors -b LS_COLORS > c.zsh" atpull='%atclone' pick='c.zsh' \
    #     trapd00r/LS_COLORS \
    # src="etc/git-extras-completion.zsh" \
    #     tj/git-extras

zinit wait="1" lucid for \
    OMZL::clipboard.zsh \
    OMZP::systemd/systemd.plugin.zsh \
    OMZP::sudo/sudo.plugin.zsh \
    OMZP::kubectl/kubectl.plugin.zsh \
    OMZP::kubectx/kubectx.plugin.zsh \
    #OMZL::git.zsh \
    #OMZP::git/git.plugin.zsh

zinit svn for \
    OMZP::extract \
    OMZP::pip

zinit light Aloxaf/fzf-tab

zinit ice as="completion" for \
    OMZP::docker/_docker \
    OMZP::rust/_rust \
    OMZP::fd/_fd

zpcompinit; zpcdreplay
eval "$(zoxide init zsh)"
set_fast_theme() {
    FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}alias]='fg=blue'
    FAST_HIGHLIGHT_STYLES[${FAST_THEME_NAME}function]='fg=blue'
    # 对 man 的高亮会卡住上下翻历史的动作
    # FAST_HIGHLIGHT[chroma-man]=
}
zinit light-mode for \
    atload="set_fast_theme" \
        zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-autosuggestions

# zinit light jeffreytse/zsh-vi-mode

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
zinit ice depth=1
zinit light romkatv/powerlevel10k
# source ~/.zinit/plugins/joshskidmore---zsh-fzf-history-search/zsh-fzf-history-search.zsh
#
if [ "$(command -v fnm)" ]; then
  eval "$(fnm env --use-on-cd)"
fi
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/mambaforge/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/mambaforge/etc/profile.d/conda.sh" ]; then
        . "/opt/mambaforge/etc/profile.d/conda.sh"
    else
        export PATH="/opt/mambaforge/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

