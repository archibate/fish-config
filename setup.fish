#!/usr/bin/env fish

if not command -sq fisher
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
end

set -l fisher_plugins jethrokuan/z acomagu/fish-async-prompt jorgebucaran/autopair.fish franciscolourenco/done mattmc3/magic-enter.fish jorgebucaran/fisher budimanjojo/tmux.fish pure-fish/pure patrickf1/fzf.fish jorgebucaran/replay.fish meaningful-ooo/sponge paldepind/projectdo

for plugin in $fisher_plugins
    fisher install $plugin
end
