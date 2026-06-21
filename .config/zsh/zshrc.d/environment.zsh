#
#        Title:      environment.zsh
#        Brief:      Configurações de ambiente para o Zsh, incluindo variáveis de ambiente e opções do shell.
#        Path:       /home/jkyon/.config/zsh/zshrc.d/environment.zsh
#        Author:     John Kennedy a.k.a. jKyon
#        Created:    2026-06-20
#        Updated:    2026-06-20
#        Notes:
#


# Editor padrão
export EDITOR=nvim
export SUDO_EDITOR=nvim

# Define compilações em ~/.build
export CARGO_HOME="$HOME/.build/cargo"
export CARGO_TARGET_DIR="/home/jkyon/.build/cargo-target"
export PIP_CACHE_DIR="/home/jkyon/.build/pip-cache"

# Configurações distcc
export DISTCC_HOSTS=" 192.168.5.20/10
                      192.168.15.30/8,lzo
                      100.100.10.10/28,lzo
                      100.100.10.30/8,lzo
                      localhost/5
                    "

# Configurações do ccache
export CCACHE_DIR="$HOME/.build/ccache"
export CCACHE_COMPRESS=1
export CCACHE_MAXSIZE=10G

# Configurações do man pages:
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export PATH="$HOME/.local/bin:$PATH"

export PAY_RESPECTS_REQUIRE_CONFIRMATION="true"  # pay-respect: Pergunta antes de aplicar

setopt EXTENDED_GLOB    # Habilita padrões estendidos
setopt GLOB_DOTS        # Faz globs pegarem arquivos começados com .

setopt INTERACTIVE_COMMENTS  # Permite comentários em comandos interativos

# Garante ZSH como shell padrão no TMUX
[[ -z "$TMUX" ]] && export SHELL=$(which zsh)