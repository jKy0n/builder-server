#
#        Title:      git.zsh
#        Brief:
#        Path:       /home/jkyon/.config/zsh/zshrc.d/functions/git/git.zsh
#        Author:     John Kennedy a.k.a. jKyon
#        Created:    2026-06-20
#        Updated:    2026-06-20
#        Notes:
#


#------------------------------------------------------------------------------
# git-cp: Realiza 'git commit' e 'git push' em um único comando.
#------------------------------------------------------------------------------
git-cp() {
    # 1. Validação: Verifica se uma mensagem de commit foi fornecida.
    if [[ -z "$1" ]]; then
        print -P "%F{red}❌ Erro:%f Faltou a mensagem de commit."
        print "Uso correto: git-cp \"sua mensagem\""
        return 1 # Retorna um código de erro
    fi

    # 2. Execução: Se a validação passar, executa os comandos.
    # O '&&' garante que o 'git push' só roda se o 'commit' for bem-sucedido.
    git commit -am "$*" && git push
}