#
#        Title:      zshrc-arch.zsh
#        Brief:      Configuração específica para Arch Linux
#        Path:       /home/jkyon/.config/zsh/zshrc.d/zshrc-arch.zsh
#        Author:     John Kennedy a.k.a. jKyon
#        Created:    2026-06-20
#        Updated:    2026-06-20
#        Notes:
#


# set -x  # Debugging tool
# Define o diretório onde os módulos estão localizados
ZSHRC_D="$HOME/.config/zsh/zshrc.d"
# Define o caminho para o diretório de funções para manter o código limpo.
ZSH_FUNCTIONS_D="$ZSHRC_D/functions"


# Carrega chaves API (mantido seguro e criptografado)
# if    [ -r "$ZSHRC_D/zsh-secrets/api_keys" ]; then
#     source "$ZSHRC_D/zsh-secrets/api_keys"
# fi

# Carrega todos os arquivos *.zsh no diretório de módulos
[ -r "$ZSHRC_D/theme.zsh" ] && source "$ZSHRC_D/theme.zsh"

# Detecta a distribuição e carrega o módulo correspondente
[ -r "$ZSHRC_D/plugins-arch.zsh" ] && source "$ZSHRC_D/plugins-arch.zsh"

# Adicione aqui qualquer configuração que você prefira manter no arquivo principal
[ -r "$ZSHRC_D/environment.zsh" ] && source "$ZSHRC_D/environment.zsh"

# Carrega o módulo de histórico
[ -r "$ZSHRC_D/history.zsh" ] && source "$ZSHRC_D/history.zsh"

# Carrega o módulo de keybinds
[ -r "$ZSHRC_D/keybinds.zsh" ] && source "$ZSHRC_D/keybinds.zsh"

# Carrega o módulo de zsh-agent
[ -r "$ZSHRC_D/ssh-agent.zsh" ] && source "$ZSHRC_D/ssh-agent.zsh"

# Carrega o módulo do pay-respects
[ -r "$ZSHRC_D/pay-respects.zsh" ] && source "$ZSHRC_D/pay-respects.zsh"

# Carrega o módulo de assistente de linha de comando Assis
# [ -r "$ZSHRC_D/assis.zsh" ] && source "$ZSHRC_D/assis.zsh"

# Carrega a lista de aliases
[ -r "$ZSHRC_D/aliases.zsh" ] && source "$ZSHRC_D/aliases.zsh"


# Verifica se o diretório de funções realmente existe.
if [ -d "$ZSH_FUNCTIONS_D" ]; then
    # Se existir, faz um loop por cada arquivo .zsh dentro dele.
    for module in "$ZSH_FUNCTIONS_D"/*/*.zsh(N); do
        # Carrega (source) cada módulo encontrado.
        [ -r "$module" ] && source "$module"
    done
fi