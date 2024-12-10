
# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"
export TERM="xterm-256color"

# Debug: Check if Oh My Zsh exists
if [ -d "$ZSH" ]; then
    echo "Oh My Zsh directory exists at $ZSH"
else
    echo "Oh My Zsh directory not found at $ZSH"
fi

# Set theme
ZSH_THEME="bira"

# Basic plugins
plugins=(git)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Array of mystical/nature emojis
EMOJIS=(🔮 ✨ 💫 🍄 🌙 🪴 🐖 🦋 🕊️ 🌸 🎭 🌊 🔱 🪞 🎇)

# Function to get a random emoji
function random_emoji {
    echo ${EMOJIS[$RANDOM % ${#EMOJIS[@]} + 1]}
}

# Modify the prompt to include random emoji
PROMPT='${debian_chroot:+($debian_chroot)─}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))─}%B%F{142}%n%F{white}@%F{130}%m%b%F{white}:%F{107}%B%~%b%F{white}
    $(random_emoji) '