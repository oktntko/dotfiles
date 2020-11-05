# --------------------------------------------------------------------------------
# bindkey
# --------------------------------------------------------------------------------
# confirm : sudo showkey

bindkey "^[[H"    beginning-of-line   # Home
bindkey "^[[F"    end-of-line         # End
bindkey "^[[3~"   delete-char         # Delete
bindkey "^[[1;5D" emacs-backward-word # Ctrl + Left
bindkey "^[[1;5C" emacs-forward-word  # Ctrl + Right
bindkey "^H"      backward-kill-word  # Ctrl + Backspace
