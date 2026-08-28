# fedora-style-setup

Repositório com um único script, `gnome-style-setup.sh`, que aplica um
visual estilo macOS no GNOME do Fedora (dock, ícones de área de trabalho,
fonte, botões de janela, blur, hot corner, transparência do terminal). O
`README.md` documenta esse comportamento para o usuário final.

## Regra: manter o README sincronizado com o script

Sempre que `gnome-style-setup.sh` for alterado (nova seção, gsettings
adicionado/removido, mudança de comportamento, mudança na função
`uninstall()`), atualize `README.md` na mesma tarefa/commit para refletir
exatamente o que o script faz. Isso inclui:

- **"O que o script faz"**: cada seção numerada do script (`# N. ...`) deve
  ter um bullet correspondente.
- **"Desinstalar / reverter"**: a lista de comandos manuais deve
  espelhar exatamente o que a função `uninstall()` do script reseta/desabilita.
  Se o script passa a configurar algo novo, `uninstall()` deve desfazer esse
  algo, e o README deve documentar o comando manual equivalente.
- **"O que é instalado"**: só pacotes/dependências realmente instalados via
  `dnf`/build (não configurações de gsettings em software que já vem no
  sistema, como o Ptyxis).
- **Compatibilidade/Requisitos**: atualize se o script passar a exigir algo
  novo (outro pacote, outra sessão, outra permissão).

Não deixe o header-comentário no topo do próprio script (linhas 1-36)
dessincronizar da lista do README — os dois devem contar a mesma história.

Ao terminar uma alteração no script, releia o README de ponta a ponta e
confirme frase por frase que ainda é verdade antes de considerar a tarefa
concluída.
