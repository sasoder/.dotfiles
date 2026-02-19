# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"
export TERM="xterm-256color"

# a pretty welcome message
# echo "🔮 🍄 🌙 🪴 🐖 🕊️ 🌸 🌊 🪞"

# Theme palette colors (no OS detection; palette adapts with your terminal theme)
: ${DOT_PRIMARY:=blue}
: ${DOT_ACCENT:=magenta}
: ${DOT_NEUTRAL_INDEX:=8}

PRIMARY_COLOR="$DOT_PRIMARY"
ACCENT_COLOR="$DOT_ACCENT"
NEUTRAL_COLOR_INDEX="$DOT_NEUTRAL_INDEX"

print -P "%F{$NEUTRAL_COLOR_INDEX}"

# print date, time, and day of the week
cat << EOF
    $(date +%A) $(date +%d) $(date +%B) $(date +%Y) $(date +%H:%M)
EOF

print -P "%F{$DOT_NEUTRAL_INDEX}"
cat << 'EOF'
           __,---.__
        ,-'         `-.__
      &/           `._\ _\
      /               ''._
      |   ,             (")
      |__,'`-..--|__|--''

             __,---.__
        __,-'         `-.
       /_ /_,'           \&
       _,''               \
      (")            .    |
        ``--|__|--..-'`.__|

EOF

print -P "%F{reset}"
# Set theme
ZSH_THEME="robbyrussell"

# Basic plugins
plugins=(git)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Set default directory
# Initialize default directory only on first launch
if [ "$PWD" = "$HOME" ]; then
    cd ~/Documents/Github
fi



# Array of mystical/nature emojis
EMOJIS=(🔮 🍄 🐖 🌸 🦕 🌍)

# Function to get a random emoji
function random_emoji {
    print -nr -- ${EMOJIS[$RANDOM % ${#EMOJIS[@]} + 1]}
}

# enable command substitution in prompt and set custom prompt
setopt prompt_subst
PROMPT='%B%F{${NEUTRAL_COLOR_INDEX}}%/%f $(git_prompt_info)%b
%F{${ACCENT_COLOR}}$(random_emoji)%f '

# my beloved fzf
source <(fzf --zsh)

# Customize fzf history search options
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' 
  --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'
"
# bun completions
[ -s "/Users/evidence/.bun/_bun" ] && source "/Users/evidence/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export PATH=$PATH:/Users/evidence/.spicetify
export PATH="/Applications/Spotify.app/Contents/MacOS:$PATH"

alias hehe="source .venv/bin/activate"
ghub() {
    cd ~/Documents/GitHub/ && ls
}

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# opencode
export PATH=/Users/evidence/.opencode/bin:$PATH

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# zsh-syntax-highlighting: make valid commands white, unknown tokens red
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'
ZSH_HIGHLIGHT_STYLES[command]='fg=white'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=white'
ZSH_HIGHLIGHT_STYLES[function]='fg=white'
ZSH_HIGHLIGHT_STYLES[alias]='fg=white'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=white'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=white'
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=white'
export TMPDIR="$HOME/tmp"

# Added by Antigravity
export PATH="/Users/evidence/.antigravity/antigravity/bin:$PATH"
export CIVITAI_TOKEN="REDACTED"
export PATH="$HOME/.local/bin:$PATH"
