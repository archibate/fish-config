#!/usr/bin/env fish

if not command -sq fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
end

set -l fisher_plugins jethrokuan/z acomagu/fish-async-prompt jorgebucaran/autopair.fish franciscolourenco/done mattmc3/magic-enter.fish jorgebucaran/fisher budimanjojo/tmux.fish pure-fish/pure patrickf1/fzf.fish jorgebucaran/replay.fish meaningful-ooo/sponge paldepind/projectdo

for plugin in $fisher_plugins
    fisher install $plugin
end

set -U fish_tmux_autostart false
set -U fish_tmux_autoname_session true
set -U fish_tmux_no_alias true
set -U pure_reverse_prompt_symbol_in_vimode true
set -U pure_enable_single_line_prompt true
set -U pure_separate_prompt_on_error true
set -U pure_show_system_time false
