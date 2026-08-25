# gnome-macos-setup.sh
 
Script bash para personalizar o GNOME no Fedora com um visual estilo **macOS
minimalista**: tema escuro, ícones, cursor, dock inferior e uma barra
superior mais limpa.
 
## O que o script faz
 
- Instala e aplica o tema **WhiteSur** (GTK + Shell) na variante escura
- Instala os ícones e o cursor **WhiteSur**
- Instala a fonte **Inter** (alternativa livre à San Francisco da Apple)
- Configura o **Dash to Dock** como um dock inferior com auto-hide, estilo macOS
- Move os botões da janela (fechar/minimizar/maximizar) para a **esquerda**
- Deixa a barra superior mais minimalista com o **Just Perfection**
  (remove o botão "Atividades", o menu do app, zera os cantos arredondados)
- Ativa efeito de **blur** no painel e no dock com o **Blur My Shell**
## Compatibilidade
 
Testado e compatível com:
 
- **Fedora Linux 44**
- **GNOME Shell 50.x**
As extensões (Dash to Dock, Blur My Shell, Just Perfection, User Themes)
são instaladas via `dnf`, usando os pacotes oficiais do repositório do
Fedora — isso evita o erro comum de "No such schema" que acontece quando
extensões são instaladas soltas fora do gerenciador de pacotes.
 
**Aviso conhecido:** existe um bug cosmético em aberto no tema WhiteSur no
GNOME 50 (uma linha branca fina no topo do painel). É só visual e não
afeta o funcionamento do sistema.
 
## Requisitos
 
- Fedora Linux com GNOME Shell (Workstation)
- Usuário com permissão de `sudo`
- Conexão com a internet (o script baixa temas do GitHub e a fonte Inter)
## Como usar
 
```bash
chmod +x gnome-macos-setup.sh
./gnome-macos-setup.sh
```
 
Depois que o script terminar, **faça logout e login novamente** (não use
apenas "Alt+F2 r" — esse atalho só funciona no X11, e a maioria das
instalações atuais do Fedora roda em Wayland). O GNOME só carrega as
extensões novas em uma sessão de shell nova.
 
## O que é instalado
 
| Categoria | Pacote/Fonte |
|---|---|
| Extensões GNOME | `gnome-shell-extension-user-theme`, `gnome-shell-extension-dash-to-dock`, `gnome-shell-extension-blur-my-shell`, `gnome-shell-extension-just-perfection` |
| Ferramentas | `gnome-tweaks`, `gnome-extensions-app`, `dconf-editor`, `gnome-browser-connector` |
| Tema GTK/Shell | [WhiteSur-gtk-theme](https://github.com/vinceliuice/WhiteSur-gtk-theme) |
| Ícones | [WhiteSur-icon-theme](https://github.com/vinceliuice/WhiteSur-icon-theme) |
| Cursor | [WhiteSur-cursors](https://github.com/vinceliuice/WhiteSur-cursors) |
| Fonte | [Inter](https://github.com/rsms/inter) |
 
## Personalização
 
O script já vem com valores prontos, mas alguns pontos podem ser ajustados
diretamente no arquivo antes de rodar:
 
- **Wallpaper**: há duas linhas comentadas no final do script — descomente
  e aponte para o caminho da sua imagem.
- **Cor de acento do tema**: troque `-t all` por uma cor específica do
  WhiteSur (`blue`, `purple`, `pink`, `red`, `orange`, `yellow`, `green`,
  `grey`) no comando de instalação do GTK theme.
- **Tamanho dos ícones do dock**: ajuste o valor de
  `dash-max-icon-size` na seção do Dash to Dock.
## Solução de problemas
 
- **Erro "No such schema" no gsettings**: normalmente indica que a
  extensão correspondente não foi instalada via `dnf` (por exemplo, se
  você instalou manualmente por fora do script). Reinstale via
  `sudo dnf install gnome-shell-extension-<nome>`.
- **Extensão não aparece habilitada**: faça logout/login completo — o
  GNOME só reconhece extensões novas numa sessão de shell nova.
- **Comando do Just Perfection falha com "No such key"**: os nomes das
  chaves podem variar entre versões da extensão. Nesse caso, abra a
  interface gráfica com `gnome-extensions prefs just-perfection-desktop@just-perfection`
  e ajuste manualmente.
- **Linha branca no topo do painel**: bug cosmético conhecido do WhiteSur
  no GNOME 50, sem correção oficial até o momento. Não afeta o
  funcionamento do sistema.
## Desinstalar / reverter
 
```bash
# Remover o tema GTK/Shell WhiteSur
cd ~/.cache/gnome-macos-theme/WhiteSur-gtk-theme && ./install.sh -r
 
# Remover ícones
cd ~/.cache/gnome-macos-theme/WhiteSur-icon-theme && ./install.sh -r
 
# Desabilitar as extensões
gnome-extensions disable dash-to-dock@micxgx.gmail.com
gnome-extensions disable blur-my-shell@aunetx
gnome-extensions disable just-perfection-desktop@just-perfection
gnome-extensions disable user-theme@gnome-shell-extensions.gcampax.github.com
 
# Voltar ao tema padrão do GNOME
gsettings reset org.gnome.desktop.interface gtk-theme
gsettings reset org.gnome.desktop.interface icon-theme
gsettings reset org.gnome.desktop.interface cursor-theme
gsettings reset org.gnome.desktop.wm.preferences button-layout
```
