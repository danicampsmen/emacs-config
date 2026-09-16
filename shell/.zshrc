# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# Desactivado para dar paso a Starship (arranque instantáneo)
ZSH_THEME=""

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    z
    sudo
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# Si estamos dentro de Emacs vterm, usa un prompt más simple
if [[ -n "$INSIDE_EMACS" ]]; then
    PROMPT='%F{cyan}%~%f %F{green}➜%f '
fi
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -lsah --color=auto'  # Un atajo útil

# --- INICIO CONFIGURACIÓN VISUAL ---

# 1. Iniciar Starship (El prompt bonito)
eval "$(starship init zsh)"

# --- ALIAS PARA EZA (ls moderno) ---
# ls básico con iconos
alias ls='eza --icons --group-directories-first'

# ll: Listado largo con detalles, git y tamaño (reemplaza tu ls -lsa)
alias ll='eza --icons --group-directories-first -l --git --header --total-size'

# la: Igual que ll pero muestra ocultos (archivos con punto)
alias la='eza --icons --group-directories-first -la --git --header --total-size'

# tree: Muestra estructura de árbol (muy útil)
alias tree='eza --icons --tree'
# ls en cuadrícula (grid) incluyendo ocultos
alias l='eza --icons --group-directories-first -a --grid'

# --- NAVEGACIÓN RÁPIDA & WORKFLOW ---
alias brain='cd ~/Documentos/06_Notas_SegundoCerebro/Segundo-Cerebro'
alias biblio='cd ~/Documentos/01_Biblioteca'
alias emacsconf='cd ~/.emacs.d'

# --- COMPILACIÓN LATEX & LIMPIEZA ---
alias lmk='latexmk -pdflua -shell-escape -interaction=nonstopmode'
alias lmkc='latexmk -c'
alias texclean='find . -type f \( -name "*.aux" -o -name "*.log" -o -name "*.fls" -o -name "*.fdb_latexmk" -o -name "*.synctex.gz" -o -name "*.toc" -o -name "*.bcf" \) -delete'

# --- SINCRONIZACIÓN GOOGLE DRIVE & LOGS ---
alias gsync='rclone sync /home/fayfer/Documentos GoogleDrive-Documentos_Ubuntu_Fayfer:Documentos-Ubuntu-Fayfer --filter-from ~/.config/rclone/rclone-filters.txt --fast-list -v'
alias agy='agy-logs'

# --- BÚSQUEDA INTELIGENTE EN HISTORIAL CON FLECHAS ---
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[OA' history-beginning-search-backward
bindkey '^[OB' history-beginning-search-forward
# --- COLORES PERSONALIZADOS (MODUS VIVENDI DEUTERANOPIA) ---
export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=1;33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#595959"
export EZA_CONFIG_DIR="$HOME/.config/eza"
export EZA_COLORS="da=37:ur=37:uw=37:ux=32:ue=32:gr=37:gw=37:gx=32:tr=37:tw=37:tx=32"

if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
    vterm_printf() {
        if [ -n "$TMUX" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ]); then
            # Tell tmux to pass the escape sequences through
            printf "\ePtmux;\e\e]%s\007\e\\" "$1"
        elif [ "${TERM%%-*}" = "screen" ]; then
            # GNU screen (screen, screen-256color, screen-256color-bce)
            printf "\eP\e]%s\007\e\\" "$1"
        else
            printf "\e]%s\e\\" "$1"
        fi
    }
    # Directory tracking
    autoload -U add-zsh-hook
    add-zsh-hook -Uz chpwd (){ vterm_printf "51;A$(pwd)" }
fi

# Created by `pipx` on 2026-05-03 11:40:19
export PATH="$PATH:/home/fayfer/.local/bin"
# TeX Live 2026
export PATH="/usr/local/texlive/2026/bin/x86_64-linux:$PATH"
export MANPATH="/usr/local/texlive/2026/texmf-dist/doc/man:$MANPATH"
export INFOPATH="/usr/local/texlive/2026/texmf-dist/doc/info:$INFOPATH"

# >>> Added by Spyder >>>
alias spyder=/home/fayfer/.local/spyder-6/envs/spyder-runtime/bin/spyder
alias uninstall-spyder=/home/fayfer/.local/spyder-6/uninstall-spyder.sh
# <<< Added by Spyder <<<

export DEEPSEEK_API_KEY="your_deepseek_api_key_here"

# Configuración del SDK nativo de Android
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin


# Added by Antigravity CLI installer
export PATH="/home/fayfer/.local/bin:$PATH"
export DISPLAY=
