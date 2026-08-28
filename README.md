# gnome-style-setup.sh

Script bash para aplicar um visual **soft** estilo macOS no GNOME do Fedora,
com só as mudanças mais importantes: dock, ícones na área de trabalho, fonte
e um leve blur. Sem trocar tema GTK, ícones de app ou cursor.

## O que o script faz

- Atualiza o sistema (`dnf upgrade --refresh`)
- Configura o **Dash to Dock** como um dock inferior com auto-hide; clicar no
  ícone de um app aberto minimiza/restaura a janela (como no Ubuntu)
- Instala e habilita **ícones na área de trabalho** (Desktop Icons NG - DING)
- Instala e aplica a fonte **Inter** (alternativa livre à San Francisco da Apple)
- Adiciona os botões de **minimizar/maximizar** na barra de título das janelas
  (como no Ubuntu; o Fedora por padrão só mostra o botão de fechar)
- Desativa o **hot corner** (mover o cursor pro canto superior esquerdo não
  abre mais a lista de apps/Activities)
- Ativa um leve efeito de **blur no painel** com o **Blur My Shell**. O dock
  fica só com a transparência nativa do Dash to Dock (sem blur) — os dois
  módulos brigam pelo mesmo fundo quando ativados juntos, causando cantos
  desencontrados e um visual quadrado
- Deixa o terminal **Ptyxis** (padrão do Fedora/GNOME) com uma leve
  transparência nativa (opacidade 85%)

## Compatibilidade

Testado e compatível com:

- **Fedora Linux 44**
- **GNOME Shell 50.x**

As extensões Dash to Dock e Blur My Shell são instaladas via `dnf`, usando
os pacotes oficiais do repositório do Fedora — isso evita o erro comum de
"No such schema" que acontece quando extensões são instaladas soltas fora
do gerenciador de pacotes.

A extensão de ícones na área de trabalho (DING) não tem pacote no Fedora,
então o script a compila a partir do código-fonte oficial (branch master,
com suporte a GNOME 50 desde jan/2026).

## Requisitos

- Fedora Linux com GNOME Shell (Workstation), numa **sessão GNOME já
  logada** — o script confere `$XDG_CURRENT_DESKTOP` e recusa rodar fora
  dela
- Usuário com permissão de `sudo`
- Conexão com a internet (o script consulta a API do GitHub para achar o
  release mais recente da fonte Inter, baixa a extensão DING do GitLab e
  baixa a fonte do GitHub)

## Como usar

```bash
chmod +x gnome-style-setup.sh
./gnome-style-setup.sh              # instala e aplica
./gnome-style-setup.sh --uninstall  # desfaz as configurações aplicadas
```

Depois que o script terminar, **faça logout e login novamente** (não use
apenas "Alt+F2 r" — esse atalho só funciona no X11, e a maioria das
instalações atuais do Fedora roda em Wayland). O GNOME só carrega as
extensões novas em uma sessão de shell nova.

> A extensão DING é instalada rodando o `local_install.sh` oficial do
> projeto (código de terceiros, baixado do GitLab em tempo de execução,
> com as permissões do seu usuário — nunca root). Se quiser auditar antes
> de rodar, o script fica em `~/.cache/gnome-style-setup/desktop-icons-ng/local_install.sh`
> depois do `git clone`.

## O que é instalado

| Categoria | Pacote/Fonte |
|---|---|
| Extensões GNOME (via dnf) | `gnome-shell-extension-dash-to-dock`, `gnome-shell-extension-blur-my-shell` |
| Extensão GNOME (compilada) | [Desktop Icons NG (DING)](https://gitlab.com/rastersoft/desktop-icons-ng) |
| Ferramentas | `gnome-tweaks`, `gnome-extensions-app`, `dconf-editor` |
| Build (para a DING) | `meson`, `ninja-build`, `gettext` |
| Fonte | [Inter](https://github.com/rsms/inter) |

## Personalização

O script já vem com valores prontos, mas alguns pontos podem ser ajustados
diretamente no arquivo antes de rodar:

- **Wallpaper**: há duas linhas comentadas no final do script — descomente
  e aponte para o caminho da sua imagem.
- **Tamanho dos ícones do dock**: ajuste o valor de
  `dash-max-icon-size` na seção do Dash to Dock.
- **Opções da área de trabalho** (tamanho dos ícones, mostrar/ocultar
  volumes, lixeira etc.): abra `gnome-extensions prefs ding@rastersoft.com`
  depois de rodar o script.

## Solução de problemas

- **Erro "No such schema" no gsettings**: normalmente indica que a
  extensão correspondente não foi instalada via `dnf` (por exemplo, se
  você instalou manualmente por fora do script). Reinstale via
  `sudo dnf install gnome-shell-extension-<nome>`.
- **Extensão não aparece habilitada**: faça logout/login completo — o
  GNOME só reconhece extensões novas numa sessão de shell nova.
- **Ícones não aparecem na área de trabalho**: confirme que a extensão foi
  habilitada com `gnome-extensions enable ding@rastersoft.com` e faça
  logout/login.
- **Script recusa rodar com mensagem sobre sessão GNOME**: confirme que
  você está numa sessão gráfica GNOME de verdade (não SSH, não TTY, não
  outro desktop). O script checa a variável `$XDG_CURRENT_DESKTOP`.

## Desinstalar / reverter

```bash
./gnome-style-setup.sh --uninstall
```

Isso desabilita as extensões (Dash to Dock, Blur My Shell, DING), remove os
arquivos da DING, e reseta fonte, botões de janela, hot corner, dock, blur e
a transparência do terminal para o padrão do GNOME. Não remove os pacotes
instalados via `dnf` (são só desabilitados/resetados, não desinstalados do
sistema). Também não reverte a atualização do sistema (`dnf upgrade`).

Se preferir fazer isso manualmente:

```bash
# Desabilitar as extensões
gnome-extensions disable dash-to-dock@micxgx.gmail.com
gnome-extensions disable blur-my-shell@aunetx
gnome-extensions disable ding@rastersoft.com

# Remover a extensão de ícones da área de trabalho
rm -rf ~/.local/share/gnome-shell/extensions/ding@rastersoft.com

# Voltar à fonte e aos botões de janela padrão do GNOME
gsettings reset org.gnome.desktop.interface font-name
gsettings reset org.gnome.desktop.interface document-font-name
gsettings reset org.gnome.desktop.wm.preferences titlebar-font
gsettings reset org.gnome.desktop.wm.preferences button-layout

# Voltar o hot corner ao padrão
gsettings reset org.gnome.desktop.interface enable-hot-corners

# Voltar o dock e o blur ao padrão
gsettings reset-recursively org.gnome.shell.extensions.dash-to-dock
gsettings reset org.gnome.shell.extensions.blur-my-shell.panel blur
gsettings reset org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur

# Voltar a transparência do terminal Ptyxis ao padrão (troque o UUID pelo
# valor de `gsettings get org.gnome.Ptyxis default-profile-uuid`)
gsettings reset "org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/<uuid>/" opacity
```
