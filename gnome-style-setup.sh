#!/usr/bin/env bash
###############################################################################
# gnome-style-setup.sh (v3 - soft)
#
# Aplica só as mudanças mais importantes de um visual estilo macOS no GNOME
# do Fedora, sem mexer em tema GTK, ícones de app ou cursor:
#   - Dock inferior com auto-hide (Dash to Dock), com clique no ícone do app
#     minimizando/restaurando a janela (como no Ubuntu)
#   - Ícones na área de trabalho (Desktop Icons NG - DING)
#   - Fonte "Inter" (alternativa livre à San Francisco)
#   - Botões de minimizar/maximizar na barra de título (como no Ubuntu)
#   - Blur no painel e no dock (Blur My Shell)
#
# Uso:
#   chmod +x gnome-style-setup.sh
#   ./gnome-style-setup.sh              # instala e aplica
#   ./gnome-style-setup.sh --uninstall  # desfaz as configurações aplicadas
#
# IMPORTANTE: depois de rodar, faça LOGOUT/LOGIN completo (não basta
# "Alt+F2 r", isso só existe no X11 e a maioria das instalações Fedora
# hoje roda em Wayland). O GNOME só carrega as extensões novas numa
# sessão de shell nova.
#
# COMPATIBILIDADE (checada em ago/2026):
#   - Fedora 44 (GNOME Shell 50.x): Dash to Dock e Blur My Shell têm build
#     publicado com suporte a GNOME 50 nos repositórios oficiais do Fedora
#     — confirmado em uso real.
#   - Desktop Icons NG (DING) não tem pacote no repositório do Fedora, então
#     este script compila e instala a extensão a partir do código-fonte
#     oficial (branch master, com suporte a GNOME 50 desde jan/2026).
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

if [[ "${XDG_CURRENT_DESKTOP:-}" != *GNOME* ]]; then
  echo "Este script configura gsettings e extensões do GNOME Shell."
  echo "Sessão atual: '${XDG_CURRENT_DESKTOP:-desconhecida}' (esperado: algo com 'GNOME')."
  echo "Rode numa sessão GNOME (Fedora Workstation) para evitar configurar o desktop errado."
  exit 1
fi

# -----------------------------------------------------------------------------
# Desinstalação: desfaz tudo que este script aplica (não remove os pacotes
# dnf, só desabilita extensões e reseta os gsettings/arquivos que este
# script criou).
# -----------------------------------------------------------------------------
uninstall() {
  log "Desabilitando extensões"
  gnome-extensions disable dash-to-dock@micxgx.gmail.com || true
  gnome-extensions disable blur-my-shell@aunetx || true
  gnome-extensions disable ding@rastersoft.com || true

  log "Removendo a extensão de ícones da área de trabalho (DING)"
  rm -rf "$HOME/.local/share/gnome-shell/extensions/ding@rastersoft.com"

  log "Restaurando fonte e botões de janela ao padrão do GNOME"
  gsettings reset org.gnome.desktop.interface font-name
  gsettings reset org.gnome.desktop.interface document-font-name
  gsettings reset org.gnome.desktop.wm.preferences titlebar-font
  gsettings reset org.gnome.desktop.wm.preferences button-layout

  log "Restaurando configurações do dock e do blur"
  gsettings reset-recursively org.gnome.shell.extensions.dash-to-dock || true
  gsettings reset org.gnome.shell.extensions.blur-my-shell.panel blur || true
  gsettings reset org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur || true

  log "Concluído! Faça LOGOUT/LOGIN para tudo voltar ao padrão."
}

case "${1:-}" in
  --uninstall)
    uninstall
    exit 0
    ;;
  "") ;;
  *)
    echo "Uso: $0 [--uninstall]"
    exit 1
    ;;
esac

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
  gnome-shell-extension-dash-to-dock \
  gnome-shell-extension-blur-my-shell \
  git curl unzip \
  meson ninja-build gettext

log "Habilitando extensões"
gnome-extensions enable dash-to-dock@micxgx.gmail.com || true
gnome-extensions enable blur-my-shell@aunetx || true
echo "Se algum 'enable' acima falhar, é normal em sessão recém-instalada:"
echo "faça logout/login e rode de novo só a parte de 'enable' + gsettings."

# -----------------------------------------------------------------------------
# 2. Ícones na área de trabalho (Desktop Icons NG - DING)
# -----------------------------------------------------------------------------
# Sem pacote no Fedora, então compila a partir do código-fonte oficial. O
# próprio script local_install.sh do projeto cuida do build (meson/ninja) e
# da instalação em ~/.local/share/gnome-shell/extensions/.
log "Instalando extensão de ícones na área de trabalho (DING)"
WORKDIR="$HOME/.cache/gnome-style-setup"
mkdir -p "$WORKDIR" && cd "$WORKDIR"

if [ ! -d desktop-icons-ng ]; then
  git clone --depth=1 https://gitlab.com/rastersoft/desktop-icons-ng.git
else
  (cd desktop-icons-ng && git pull --ff-only)
fi

# ATENÇÃO: a linha abaixo executa o instalador oficial do projeto
# (local_install.sh) com as permissões do seu usuário (não root). É código
# de terceiros baixado em tempo de execução — se quiser auditar antes,
# o arquivo fica em "$WORKDIR/desktop-icons-ng/local_install.sh".
(cd desktop-icons-ng && ./local_install.sh)

cd "$HOME"
gnome-extensions enable ding@rastersoft.com || true

# -----------------------------------------------------------------------------
# 3. Fonte estilo macOS (Inter é a alternativa livre mais próxima da San Francisco)
# -----------------------------------------------------------------------------
log "Instalando a fonte Inter"
mkdir -p "$HOME/.local/share/fonts"
# Descobre a URL do release mais recente via API do GitHub em vez de fixar
# um número de versão no nome do arquivo (ex: "Inter-4.1.zip"), que muda a
# cada lançamento e quebraria o link direto no futuro.
INTER_URL=$(curl -sL https://api.github.com/repos/rsms/inter/releases/latest \
  | grep -oP '"browser_download_url":\s*"\K[^"]*/Inter-[0-9][^"]*\.zip' \
  | head -n1) || true
if [ -z "$INTER_URL" ]; then
  echo "Não foi possível encontrar o .zip da fonte Inter no último release do GitHub." >&2
  exit 1
fi
curl -sL -o /tmp/inter.zip "$INTER_URL"
unzip -qo /tmp/inter.zip -d /tmp/inter
find /tmp/inter -iname "*.otf" -path "*Desktop*" -exec cp {} "$HOME/.local/share/fonts/" \;
fc-cache -f "$HOME/.local/share/fonts" >/dev/null

log "Aplicando a fonte"
gsettings set org.gnome.desktop.interface font-name "Inter 11"
gsettings set org.gnome.desktop.interface document-font-name "Inter 11"
gsettings set org.gnome.desktop.wm.preferences titlebar-font "Inter Bold 11"

# -----------------------------------------------------------------------------
# 4. Botões de minimizar/maximizar na janela, estilo Ubuntu
# -----------------------------------------------------------------------------
log "Adicionando botões de minimizar/maximizar na barra de título"
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'

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
# 6. Blur no painel e no dock (Blur My Shell)
# -----------------------------------------------------------------------------
log "Ativando efeito de blur (painel e dock)"
gsettings set org.gnome.shell.extensions.blur-my-shell.panel blur true
gsettings set org.gnome.shell.extensions.blur-my-shell.dash-to-dock blur true

# -----------------------------------------------------------------------------
# 7. Wallpaper (opcional) — descomente e ajuste o caminho se quiser definir já
# -----------------------------------------------------------------------------
# gsettings set org.gnome.desktop.background picture-uri "file:///caminho/para/wallpaper.jpg"
# gsettings set org.gnome.desktop.background picture-uri-dark "file:///caminho/para/wallpaper.jpg"

log "Concluído! Faça LOGOUT/LOGIN (não só reiniciar o Shell) para tudo aplicar."
