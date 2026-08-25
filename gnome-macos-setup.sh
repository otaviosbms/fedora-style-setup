#!/usr/bin/env bash
###############################################################################
# gnome-macos-setup.sh (v2 - revisado)
#
# Personaliza o GNOME no Fedora para um visual estilo macOS minimalista:
#   - Tema GTK/Shell escuro (WhiteSur)
#   - Ícones estilo macOS (WhiteSur)
#   - Cursor estilo macOS (WhiteSur)
#   - Fonte "Inter" (alternativa livre à San Francisco)
#   - Dock inferior com auto-hide (Dash to Dock)
#   - Botões da janela à esquerda (fechar/minimizar/maximizar)
#   - Topbar minimalista (Just Perfection)
#   - Blur em painel/dock (Blur My Shell)
#
# Uso:
#   chmod +x gnome-macos-setup.sh
#   ./gnome-macos-setup.sh
#
# IMPORTANTE: depois de rodar, faça LOGOUT/LOGIN completo (não basta
# "Alt+F2 r", isso só existe no X11 e a maioria das instalações Fedora
# hoje roda em Wayland). O GNOME só carrega as extensões novas numa
# sessão de shell nova.
#
# COMPATIBILIDADE (checada em ago/2026):
#   - Fedora 44 (GNOME Shell 50.x): Dash to Dock, Blur My Shell, Just
#     Perfection e User Themes têm build publicado com suporte a GNOME 50
#     nos repositórios oficiais do Fedora — confirmado em uso real.
#   - WhiteSur GTK theme: o suporte ao GNOME 50 só foi adicionado
#     oficialmente no upstream a partir do release de 2026-08-08 (PR
#     "Gnome50 compat"). Como este script clona o branch master via
#     --depth=1, ele pega automaticamente essa versão ou mais nova.
#     Ainda assim há um bug cosmético conhecido e em aberto (linha branca
#     fina no topo do painel) reportado no GNOME 50 — é só visual, não
#     quebra o tema. Sem correção oficial até o momento desta revisão.
#   - Ícones e cursor WhiteSur são só assets estáticos, não dependem da
#     versão do GNOME Shell.
#   - Em GNOME 50, o gerenciamento de extensões saiu do GNOME Tweaks: ao
#     abrir o Tweaks pela primeira vez você verá um aviso "Extensions Has
#     Moved". Isso é esperado, não é erro do script. Este script já
#     habilita as extensões via linha de comando (gnome-extensions), sem
#     depender da interface do Tweaks.
###############################################################################

set -euo pipefail

log() { echo -e "\n\033[1;36m==> $1\033[0m"; }

if [ "$(id -u)" -eq 0 ]; then
  echo "Não execute este script como root. Rode como usuário normal (ele usa sudo quando precisa)."
  exit 1
fi

# -----------------------------------------------------------------------------
# 1. Dependências e extensões via dnf
# -----------------------------------------------------------------------------
# Por que via dnf e não via extensions.gnome.org / gnome-shell-extension-installer:
# extensões instaladas "soltas" em ~/.local/share/gnome-shell/extensions/ não
# registram o schema do gsettings no sistema, então comandos como
# `gsettings set org.gnome.shell.extensions.dash-to-dock ...` costumam falhar
# com "No such schema". Instalando via dnf, o pacote RPM registra o schema em
# /usr/share/glib-2.0/schemas e o gsettings funciona de verdade.
log "Instalando dependências e extensões (via pacotes oficiais do Fedora)"
sudo dnf install -y \
  gnome-tweaks \
  gnome-extensions-app \
  dconf-editor \
  gnome-shell-extension-user-theme \
  gnome-shell-extension-dash-to-dock \
  gnome-shell-extension-blur-my-shell \
  gnome-shell-extension-just-perfection \
  gnome-browser-connector \
  git curl unzip

log "Habilitando extensões"
gnome-extensions enable dash-to-dock@micxgx.gmail.com || true
gnome-extensions enable blur-my-shell@aunetx || true
gnome-extensions enable just-perfection-desktop@just-perfection || true
gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com || true
echo "Se algum 'enable' acima falhar, é normal em sessão recém-instalada:"
echo "faça logout/login e rode de novo só a parte de 'enable' + gsettings."

# -----------------------------------------------------------------------------
# 2. Temas GTK / Shell / Ícones / Cursor estilo macOS (WhiteSur)
# -----------------------------------------------------------------------------
log "Baixando e instalando temas WhiteSur (GTK, ícones, cursor)"
WORKDIR="$HOME/.cache/gnome-macos-theme"
mkdir -p "$WORKDIR" && cd "$WORKDIR"

if [ ! -d WhiteSur-gtk-theme ]; then
  git clone --depth=1 https://github.com/vinceliuice/WhiteSur-gtk-theme.git
fi
# -c espera minúsculo ("dark"/"light") no install.sh principal.
# -N glassy = estilo do Nautilus; -t all = instala todos os acentos de cor.
(cd WhiteSur-gtk-theme && ./install.sh -c dark -t all -N glassy)

if [ ! -d WhiteSur-icon-theme ]; then
  git clone --depth=1 https://github.com/vinceliuice/WhiteSur-icon-theme.git
fi
# -a = ícones alternativos para software center/gerenciador de arquivos
(cd WhiteSur-icon-theme && ./install.sh -a)

if [ ! -d WhiteSur-cursors ]; then
  git clone --depth=1 https://github.com/vinceliuice/WhiteSur-cursors.git
fi
# Este install.sh não tem opções: só copia dist/ pronto para ~/.local/share/icons/
(cd WhiteSur-cursors && ./install.sh)

cd "$HOME"

# -----------------------------------------------------------------------------
# 3. Fonte estilo macOS (Inter é a alternativa livre mais próxima da San Francisco)
# -----------------------------------------------------------------------------
log "Instalando a fonte Inter"
mkdir -p "$HOME/.local/share/fonts"
curl -sL -o /tmp/inter.zip \
  https://github.com/rsms/inter/releases/latest/download/Inter-4.1.zip
unzip -qo /tmp/inter.zip -d /tmp/inter
find /tmp/inter -iname "*.otf" -path "*Desktop*" -exec cp {} "$HOME/.local/share/fonts/" \;
fc-cache -f "$HOME/.local/share/fonts" >/dev/null

# -----------------------------------------------------------------------------
# 4. Aplicando temas e fontes
# -----------------------------------------------------------------------------
log "Aplicando tema, ícones, cursor e fonte"
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark"
gsettings set org.gnome.desktop.wm.preferences theme "WhiteSur-Dark"
gsettings set org.gnome.shell.extensions.user-theme name "WhiteSur-Dark"
gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-dark"
gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface font-name "Inter 11"
gsettings set org.gnome.desktop.interface document-font-name "Inter 11"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "Inter Bold 11"

# -----------------------------------------------------------------------------
# 5. Dock estilo macOS (Dash to Dock)
# -----------------------------------------------------------------------------
log "Configurando o dock"
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
gsettings set org.gnome.shell.extensions.dash-to-dock icon-size-fixed false
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
gsettings set org.gnome.shell.extensions.dash-to-dock show-mounts false
gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize'
gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style 'DOTS'
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.6

# -----------------------------------------------------------------------------
# 6. Botões da janela à esquerda, estilo macOS
# -----------------------------------------------------------------------------
log "Movendo botões de janela para a esquerda (fechar/minimizar/maximizar)"
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

# -----------------------------------------------------------------------------
# 7. Topbar minimalista (Just Perfection)
# -----------------------------------------------------------------------------
log "Deixando a barra superior mais minimalista"
gsettings set org.gnome.shell.extensions.just-perfection activities-button false
gsettings set org.gnome.shell.extensions.just-perfection app-menu false
gsettings set org.gnome.shell.extensions.just-perfection panel-corner-size 0
gsettings set org.gnome.shell.extensions.just-perfection animation 2

# -----------------------------------------------------------------------------
# 8. Blur no painel e no dock (Blur My Shell)
# -----------------------------------------------------------------------------
log "Ativando efeito de blur (painel e dock)"
gsettings set org.gnome.shell.extensions.blur-my-shell.panel blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.appfolder blur true

# -----------------------------------------------------------------------------
# 9. Wallpaper (opcional) — descomente e ajuste o caminho se quiser definir já
# -----------------------------------------------------------------------------
# gsettings set org.gnome.desktop.background picture-uri "file:///caminho/para/wallpaper.jpg"
# gsettings set org.gnome.desktop.background picture-uri-dark "file:///caminho/para/wallpaper.jpg"

log "Concluído! Faça LOGOUT/LOGIN (não só reiniciar o Shell) para tudo aplicar."
