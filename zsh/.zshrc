# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"
export TERM="xterm-256color"

# a pretty welcome message
# echo "🔮 ✨ 💫 🍄 🌙 🪴 🐖 🦋 🕊️ 🌸 🎭 🌊 🔱 🪞"

print -P "%F{white}"

print -P "%F{210}"

# print date, time, and day of the week, in a pretty format with a crystal ball emoji
cat << EOF
    $(date +%A) $(date +%d) $(date +%B) $(date +%Y) $(date +%H:%M)
EOF

print -P "%F{217}"
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
ZSH_THEME="bira"

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
EMOJIS=(🔮 ✨ 🌕 🍄 🌙 🐖 🌸 🌊 🌋 🦕 ☄️ 🌍 🪐)

# Function to get a random emoji
function random_emoji {
    echo ${EMOJIS[$RANDOM % ${#EMOJIS[@]} + 1]}
}

# Modify the prompt to include random emoji
PROMPT='${debian_chroot:+($debian_chroot)─}%F{white}[%*]%f %B%F{white}%n@%m%b%F{white}:%F{blue}%B%~%b%F{white}
$(random_emoji) '

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
