#!/bin/zsh

#############################################################################
#                                                                           #
#                    KALI-LIKE THEME for Oh-My-Zsh                          #
#                                                                           #
#############################################################################
#                                                                           #
#  For better "kali-like" experience, use FiraCode font for your terminal   #
#  and install zsh-syntax-highlighting and zsh-autosuggestions packages     #
#                                                                           #
#############################################################################
#                                                                           #
# CREDITS :                                                                 #
# Some parts of this code was directly ripped from Kali Linux .zshrc        #
#                                                                           #
#############################################################################
# (C) 2023 Cyril LAMY under the MIT License                                 #
#############################################################################

#####   OPTIONS     #####

USE_SYNTAX_HIGHLIGHTING=yes
AUTO_DOWNLOAD_SYNTAX_HIGHLIGHTING_PLUGIN=no

USE_ZSH_AUTOSUGGESTIONS=yes
AUTO_DOWNLOAD_ZSH_AUTOSUGGESTIONS_PLUGIN=no

PROMPT_ALTERNATIVE=twoline
NEWLINE_BEFORE_PROMPT=yes

#### END OF OPTIONS #####

setopt autocd              # change directory just by typing its name
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt
setopt share_history       # all sessions share the same history files

WORDCHARS=${WORDCHARS//\/} # Don't consider certain characters part of the word

# hide EOL sign ('%')
PROMPT_EOL_MARK=""

# configure key keybindings
bindkey -e                                        # emacs key bindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^U' backward-kill-line                   # ctrl + U
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action

setopt hist_verify            # show command with history expansion to user before running it

# force zsh to show the complete history
alias history="history 0"

# configure `time` format
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

configure_prompt() {
    ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[067]%}["
    ZSH_THEME_GIT_PROMPT_SUFFIX="] %{$reset_color%}"


    if [[ $UID == 0 || $EUID == 0 ]]; then
        FGPROMPT="$FG[196]"
        CYANPROMPT="$FG[027]"
    else
        CYANPROMPT="$FG[073]"
        FGPROMPT="$FG[027]"
    fi
    case "$PROMPT_ALTERNATIVE" in
        twoline)
            PROMPT=$'$CYANPROMPT┌───\(%B$FGPROMPT%n@%m%b$CYANPROMPT)-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b$CYANPROMPT]$(git_prompt_info)\n└─%B%(#.%F{red}#.$FGPROMPT$)%b%F{reset} '
            RPROMPT=
            ;;
        oneline)
            PROMPT=$'%B$FGPROMPT%n@%m%b%F{reset}:%B$CYANPROMPT%~%b$(git_prompt_info)%F{reset}%(#.#.$) '
            RPROMPT=
            ;;
    esac
}

configure_prompt

toggle_oneline_prompt(){
    if [ "$PROMPT_ALTERNATIVE" = oneline ]; then
        PROMPT_ALTERNATIVE=twoline
    else
        PROMPT_ALTERNATIVE=oneline
    fi
    configure_prompt
    zle reset-prompt
}
zle -N toggle_oneline_prompt
bindkey ^P toggle_oneline_prompt

# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions

    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    alias pacman='pacman --color=auto' 
    
    export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
    export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
    export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
    export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
    export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
    export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
    export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

    # Take advantage of $LS_COLORS for completion as well
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
fi

# enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi
