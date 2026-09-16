# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:/home/fayfer/.juliaup/bin:*)
        ;;

    *)
        export PATH=/home/fayfer/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac

# <<< juliaup initialize <<<


# Added by Toolbox App
export PATH="$PATH:/home/fayfer/.local/share/JetBrains/Toolbox/scripts"

. "$HOME/.cargo/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/fayfer/.lmstudio/bin"
# End of LM Studio CLI section



# Added by Antigravity CLI installer
export PATH="/home/fayfer/.local/bin:$PATH"

# === Sway: DPI / Font scaling ===
# NOTA: Con output scale 2.0 (4K HiDPI), NO se necesita GDK_DPI_SCALE ni QT_FONT_DPI adicional.
# Dejarlo en 1.0 evita el doble escalado de fuentes en GTK y Qt.
# GDK_DPI_SCALE=1.13  ← desactivado (causaba fuentes enormes)
# QT_FONT_DPI=108     ← desactivado (causaba fuentes enormes)
