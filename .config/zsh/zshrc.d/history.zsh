# Histórico
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=/home/jkyon/.config/zsh/zshrc.d/zsh-secrets/zsh_history

# Opções
setopt append_history       # Anexa ao invés de sobrescrever
setopt share_history        # Histórico compartilhado entre sessões
setopt hist_ignore_all_dups # Ignora duplicatas
setopt hist_ignore_space    # Ignora comandos com espaço inicial
setopt inc_append_history   # Salva histórico imediatamente