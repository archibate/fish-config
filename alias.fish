set -q PAGER; or set -l PAGER less
set -q EDITOR; or set -l EDITOR nvim

abbr -a s 'ls'
abbr -a l 'ls -lAtr'

abbr -a gs 'git status'
abbr -a ga 'git add --all'
abbr -a gad 'git add'
abbr -a gc 'git commit -m'
abbr -a gco 'git checkout'
abbr -a gcm 'git commit'
abbr -a gca 'git commit --amend'
abbr -a gq 'git pull'
abbr -a gk 'git reset'
abbr -a gkh 'git reset --hard'
abbr -a gkha 'git reset --hard HEAD^'
abbr -a gp 'git push'
abbr -a gg 'git switch'
abbr -a ggo 'git switch -c'
abbr -a grs 'git restore --staged'
abbr -a grc 'git rm --cached'
abbr -a gr 'git restore'
abbr -a gd 'git diff'
abbr -a gdc 'git diff --cached'
abbr -a gda 'git diff HEAD^'
abbr -a gm 'git merge'
abbr -a gl 'git log'
abbr -a gll 'git log --graph --oneline --decorate'
abbr -a gt 'git stash'
abbr -a gtp 'git stash pop'
abbr -a gcl 'git clone'
abbr -a gcl1 'git clone --depth=1'
abbr -a gsmu 'git submodule update --init --recursive'
abbr -a gw 'git workspace'
abbr -a gwa 'git workspace add'
abbr -a gwl 'git workspace list'
abbr -a gwrm 'git workspace remove'
abbr -a g0 'cd (git rev-parse --show-toplevel)'

abbr -a g 'git'
abbr -a p 'python'
abbr -a b "$EDITOR"
abbr -a v "$PAGER"
abbr -a j z

abbr -a fishconf "$EDITOR $__fish_config_dir/config.fish && source $__fish_config_dir/config.fish"

abbr -a t 'projectdo test'
abbr -a r 'projectdo run'
abbr -a m 'projectdo build'

if command -sq opencode
    function opencode
        set -lx SHELL (which bash)
        command opencode $argv
    end
end

function tmux_session_picker
    ~/.config/tmux/scripts/tmux_session_picker.sh
end

function tmux_pager_view
    tmux capture-pane -pS - | $PAGER
end

abbr -a ta 'tmux attach'
abbr -a tl 'tmux ls'
abbr -a tu --function tmux_session_picker
abbr -a tv --function tmux_pager_view
abbr -a tmuxconf "$EDITOR $fish_tmux_config"
