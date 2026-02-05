if status is-interactive

    if status is-login
        set -x LANG C.UTF-8
    end

    if command -sq direnv
        direnv hook fish | source
    end
    if command -sq atuin
        atuin init fish --disable-up-arrow | source
    end

    function fish_greeting
        echo "
$(set_color red) 88888$(set_color yellow)888b oo          $(set_color green)dP       
$(set_color red) 88                    $(set_color cyan)88       
$(set_color red)a88$(set_color yellow)aaaa    $(set_color green)dP .d8888b$(set_color cyan). 8$(set_color blue)8d888$(set_color magenta)b. 
$(set_color red) 88        $(set_color green)88 Y$(set_color cyan)8ooooo. $(set_color blue)88'  $(set_color magenta)`88 
$(set_color red) 8$(set_color yellow)8        $(set_color green)8$(set_color cyan)8       8$(set_color blue)8 88    $(set_color magenta)88 
$(set_color yellow) dP        $(set_color cyan)dP `88888$(set_color blue)P' dP    $(set_color magenta)dP $(set_color normal)
        "
        echo "       $(set_color green)$(date +%Y/%m/%d)$(set_color normal) $(set_color yellow)$(date +%H:%M)$(set_color normal)"
        echo
    end

    fish_vi_key_bindings
    fzf_key_bindings
    if false
        fish_default_key_bindings -M insert
    else
        bind -M insert \cp up-or-search
        bind -M insert \cn down-or-search
        bind -M insert \ca beginning-of-line
        bind -M insert \ce end-of-line
        bind -M insert \e\[H beginning-of-line
        bind -M insert \e\[F end-of-line
        bind -M insert \cf forward-bigword forward-single-char
        bind -M insert \cb backward-bigword
        bind -M visual \ca beginning-of-line
        bind -M visual \ce end-of-line
        bind -M visual \e\[H beginning-of-line
        bind -M visual \e\[F end-of-line
        bind -M visual \cf forward-bigword forward-single-char
        bind -M visual \cb backward-bigword
        bind -M default \ce end-of-line
        bind -M default \e\[H beginning-of-line
        bind -M default \e\[F end-of-line
        bind -M default \cf forward-bigword forward-single-char
        bind -M default \cb backward-bigword
        bind -M insert \ct transpose-words
        bind -M insert \eu upcase-word
        bind -M insert \ec capitalize-word
        bind -M default \cr redo
    end

    source $__fish_config_dir/env.fish
    source $__fish_config_dir/alias.fish

end
