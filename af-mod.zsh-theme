# af-mod.zsh-theme
#
# the ship of thesius, as a zsh theme

local dash_color=%F{091}
local dash_color8=%F{magenta}

local env_color=%F{097}
local env_color8=%f

local path_color=%F{141}
local path_color8=%f

local prompt_color=%F{195}
local prompt_color8=%F{cyan}

local error_color=%F{red}
local success_color=%F{green}

local suggest_color="fg=#b099cc"
local suggest_color8="fg=5"

local reset_color=%f

local new_error_symbol="$emoji[x]%{ %}"  # ZSH and emoji are Not!!! Friends!!! but I'm making them play
local old_error_symbol=$'\xA5'' '

local new_success_symbol=$emoji[green_circle]
local old_success_symbol=$'\xA5'

local caret1=$'\xC8' # MacRoman
local caret2=$'\xC2\xBB'  # UTF-8

case $TERM in
  xterm-256color)
    local success_sym=$new_success_symbol
    local error_sym=$new_error_symbol
    local caret=$caret2
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=$suggest_color
    ;;

  # note that this depends on macssh being installed in the terminfo database
  # if it doesn't exist, you can create it from 'linux' using infocmp and tic
  macssh)
    local success_sym=$old_success_symbol
    local error_sym=$old_error_symbol
    local caret=$caret1
    local dash_color=$dash_color8
    local env_color=$env_color8
    local path_color=$path_color8
    local prompt_color=$prompt_color8
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=$suggest_color8
    ;;

  linux)
    local success_sym="*"
    local error_sym="* "
    local caret=$caret2
    local dash_color=$dash_color8
    local env_color=$env_color8
    local path_color=$path_color8
    local prompt_color=$prompt_color8
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=$suggest_color8
    ;;

  *)
    local success_sym=$new_success_symbol
    local error_sym=$new_error_symbol
    local caret=$caret2
    ;;
esac

# Git status. None of this is used, but maybe it will be if I have to keep scrolling past it
ZSH_THEME_GIT_PROMPT_ADDED="+"
ZSH_THEME_GIT_PROMPT_DELETED="-"
ZSH_THEME_GIT_PROMPT_MODIFIED="*"
ZSH_THEME_GIT_PROMPT_RENAMED=">"
ZSH_THEME_GIT_PROMPT_UNMERGED="="
ZSH_THEME_GIT_PROMPT_UNTRACKED="?"

# Git sha.
ZSH_THEME_GIT_PROMPT_SHA_BEFORE="["
ZSH_THEME_GIT_PROMPT_SHA_AFTER="]"

function realstrlen {
        local str=$1
    local zero='%([BSUbfksu]|([FK]|){*})'
        local len=${#${(S%%)str//$~zero/}}
        echo $len
}

#Sometimes grabs (fetch) and i'm not sure why, regex is hard y'all
function gitStatusF() {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    user=$(git remote -v | grep "origin.*fetch" | cut -d'/' -f 4) || return
    repo=$(git remote -v | grep "origin.*fetch" | cut -d'/' -f 5 | cut -d'.' -f 1) || return
    echo "%{$env_color%}[${user}/${repo}][${ref#refs/heads/}]%{$env_color%}$(git_prompt_short_sha)"
}

# dashed separator size
function afmagic_dashes {

    local leftlen=$(realstrlen $1)
        local rightlen=$(realstrlen $2)

    echo $(( $COLUMNS - $leftlen - $rightlen ))
}

function chpwd {
        DIRLIST=1
}

function precmd {

        local left=$(gitStatusF)

        if [[ -z $left ]]
        then
                left="$dash_color----$prompt_color//"
        fi

        local right=$env_color\[$USER@$HOST\]%{$reset_color%}

        local dashcount=$(afmagic_dashes $left $right)

        print -rPn $left

        print -rPn '$dash_color${(l:$dashcount::-:)}'

        print -P $right

        if [[ -n $DIRLIST ]]
        then
                ll
                unset DIRLIST
        fi
}

setopt prompt_subst

# left prompt: path
nl=$'\n'
PROMPT="%{$path_color%}%~ %{$prompt_color%}%(!.#.$caret)%{$reset_color%} "

PS2="\ "

# right prompt: return code
RPROMPT='%(?.%{$success_color%}$success_sym%{$reset_color%}.%{$error_color%}$error_sym%?%{$reset_color%})'
