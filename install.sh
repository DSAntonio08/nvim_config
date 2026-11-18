#!/usr/bin/env bash
# Sets up everything this nvim config needs (outside of nvim itself).
#
#   git clone https://github.com/DSAntonio08/nvim_config.git ~/.config/nvim
#   ~/.config/nvim/install.sh
#
# Supports macOS (Homebrew), Debian/Ubuntu (apt), Fedora (dnf), Arch (pacman).
# Safe to run again; already installed stuff is skipped.
#
#   --dry-run   only print what would run
#   --no-font   skip the Nerd Font
set -euo pipefail

NVIM_MIN="0.11.0"
# language servers / formatters that come from Mason when not already on PATH
# (mason package : binary it provides)
MASON_PKGS=(
  "lua-language-server:lua-language-server"
  "pyright:pyright-langserver"
  "typescript-language-server:typescript-language-server"
  "rust-analyzer:rust-analyzer"
  "stylua:stylua"
  "black:black"
  "prettier:prettier"
  "tree-sitter-cli:tree-sitter" # nvim-treesitter (main branch) builds parsers with it
)

DRY_RUN=0
WANT_FONT=1
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --no-font) WANT_FONT=0 ;;
    -h | --help) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

# --- helpers -----------------------------------------------------------------

if [ -t 1 ]; then B=$'\e[1m' G=$'\e[32m' Y=$'\e[33m' R=$'\e[31m' N=$'\e[0m'; else B= G= Y= R= N=; fi
step() { printf '\n%s==> %s%s\n' "$B" "$*" "$N"; }
ok()   { printf '%s  ok%s %s\n' "$G" "$N" "$*"; }
warn() { printf '%s  !!%s %s\n' "$Y" "$N" "$*"; }
die()  { printf '%serror:%s %s\n' "$R" "$N" "$*" >&2; exit 1; }
has()  { command -v "$1" >/dev/null 2>&1; }

run() {
  if [ "$DRY_RUN" = 1 ]; then printf '  [dry-run] %s\n' "$*"; else "$@"; fi
}

SUDO=""
if [ "$(id -u)" -ne 0 ]; then SUDO="sudo"; fi

# version_ge 0.11.2 0.11.0 -> true
version_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }

nvim_version() { nvim --version 2>/dev/null | head -1 | sed 's/^NVIM v//; s/-.*//'; }

LOCAL_BIN="$HOME/.local/bin"
MASON_BIN="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/bin"
ORIG_PATH="$PATH"
mkdir -p "$LOCAL_BIN"
export PATH="$LOCAL_BIN:$PATH"

# --- sanity checks -------------------------------------------------------------

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
if [ "$SCRIPT_DIR" != "$(cd "$CONFIG_DIR" 2>/dev/null && pwd -P)" ]; then
  die "this repo has to live in $CONFIG_DIR (it's in $SCRIPT_DIR).
       git clone <repo> $CONFIG_DIR"
fi

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64 | amd64) ARCH=x86_64 ;;
  arm64 | aarch64) ARCH=arm64 ;;
  *) warn "untested CPU architecture: $ARCH" ;;
esac

# --- detect OS -------------------------------------------------------------------

OS="$(uname -s)"
if [ "$OS" = Darwin ]; then
  PM=brew
elif [ "$OS" = Linux ] && [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  case " ${ID:-} ${ID_LIKE:-} " in
    *" arch "*) PM=pacman ;;
    *" fedora "* | *" rhel "*) PM=dnf ;;
    *" debian "* | *" ubuntu "*) PM=apt ;;
    *) die "unsupported distro: ${PRETTY_NAME:-$ID}. Install by hand: neovim >= $NVIM_MIN, git, curl, unzip, a C compiler, ripgrep, fd, lazygit, node+npm, python3 (+venv), clangd, clang-format" ;;
  esac
else
  die "unsupported OS: $OS"
fi
step "Detected: ${PRETTY_NAME:-macOS $(sw_vers -productVersion 2>/dev/null)} ($ARCH), using $PM"

# --- system packages ----------------------------------------------------------------

step "Installing system packages"
case "$PM" in
  brew)
    has brew || die "Homebrew is missing. Install it first: https://brew.sh"
    xcode-select -p >/dev/null 2>&1 || {
      run xcode-select --install
      die "installing the Xcode command line tools (C compiler + clangd); run this script again when that's done"
    }
    # clangd comes with the Xcode command line tools
    run brew install neovim git ripgrep fd lazygit node python clang-format
    ;;
  apt)
    run $SUDO apt-get update
    run $SUDO apt-get install -y git curl unzip tar gzip xz-utils build-essential \
      ripgrep fd-find nodejs npm python3 python3-venv clangd clang-format fontconfig
    # debian calls it fdfind
    if ! has fd && has fdfind; then run ln -sf "$(command -v fdfind)" "$LOCAL_BIN/fd"; fi
    # lazygit is only packaged in newer releases
    run $SUDO apt-get install -y lazygit 2>/dev/null || warn "no lazygit package, grabbing it from GitHub below"
    ;;
  dnf)
    run $SUDO dnf install -y git curl unzip tar gzip xz gcc gcc-c++ make \
      ripgrep fd-find nodejs npm python3 clang-tools-extra fontconfig neovim
    run $SUDO dnf install -y lazygit 2>/dev/null || warn "no lazygit package, grabbing it from GitHub below"
    ;;
  pacman)
    run $SUDO pacman -Syu --needed --noconfirm git curl unzip tar gzip xz base-devel \
      ripgrep fd lazygit nodejs npm python clang fontconfig neovim
    ;;
esac

# --- neovim (distro packages are often too old) ---------------------------------------

step "Checking neovim >= $NVIM_MIN"
if has nvim && version_ge "$(nvim_version)" "$NVIM_MIN"; then
  ok "nvim $(nvim_version)"
else
  [ "$OS" = Linux ] || die "nvim is too old/missing, try: brew upgrade neovim"
  warn "nvim $(nvim_version || true) missing or too old, installing the latest release to ~/.local"
  url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$ARCH.tar.gz"
  run mkdir -p "$HOME/.local/opt"
  run rm -rf "$HOME/.local/opt/nvim-linux-$ARCH"
  if [ "$DRY_RUN" = 1 ]; then
    run "curl -fsSL $url | tar -xz -C ~/.local/opt"
  else
    curl -fsSL "$url" | tar -xz -C "$HOME/.local/opt"
  fi
  run ln -sf "$HOME/.local/opt/nvim-linux-$ARCH/bin/nvim" "$LOCAL_BIN/nvim"
  [ "$DRY_RUN" = 1 ] || ok "nvim $(nvim_version)"
fi

# --- lazygit fallback ---------------------------------------------------------------

if ! has lazygit; then
  step "Installing lazygit from GitHub"
  if [ "$DRY_RUN" = 1 ]; then
    run "download latest lazygit_<ver>_Linux_$ARCH.tar.gz to ~/.local/bin"
  else
    ver="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')"
    [ -n "$ver" ] || die "couldn't look up the latest lazygit version"
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v$ver/lazygit_${ver}_Linux_$ARCH.tar.gz" |
      tar -xz -C "$LOCAL_BIN" lazygit
    ok "lazygit $ver"
  fi
fi

# --- nerd font (icons) ----------------------------------------------------------------

if [ "$WANT_FONT" = 1 ]; then
  step "Nerd Font (JetBrainsMono)"
  if [ "$PM" = brew ]; then
    if brew list --cask font-jetbrains-mono-nerd-font >/dev/null 2>&1; then
      ok "already installed"
    else
      run brew install --cask font-jetbrains-mono-nerd-font
    fi
  elif fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
    ok "already installed"
  else
    font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerd"
    run mkdir -p "$font_dir"
    if [ "$DRY_RUN" = 1 ]; then
      run "curl JetBrainsMono.tar.xz from nerd-fonts releases | tar -xJ -C $font_dir"
    else
      curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz |
        tar -xJ -C "$font_dir"
    fi
    run fc-cache -f "$font_dir"
  fi
  warn "set your terminal font to \"JetBrainsMono Nerd Font\" (Ghostty already has the icons built in)"
fi

# --- plugins ----------------------------------------------------------------------------

step "Installing plugins (versions from lazy-lock.json)"
run nvim --headless "+Lazy! restore" +qa

step "Building the theme cache"
run nvim --headless "+lua require('base46').load_all_highlights()" +qa

# --- language servers / formatters --------------------------------------------------------

step "Language servers + formatters"
missing=()
for entry in "${MASON_PKGS[@]}"; do
  pkg="${entry%%:*}" bin="${entry##*:}"
  if has "$bin"; then ok "$bin (already on PATH)"
  elif [ -x "$MASON_BIN/$bin" ]; then ok "$bin (already in Mason)"
  else missing+=("$pkg"); fi
done
if [ "${#missing[@]}" -gt 0 ]; then
  echo "  installing with Mason: ${missing[*]}"
  run nvim --headless "+MasonInstall ${missing[*]}" +qa
fi

# --- done ---------------------------------------------------------------------------------

step "Done"
has rustfmt || warn "rustfmt missing (only for formatting rust): install rustup, https://rustup.rs"
has pio || warn "pio missing (only for PlatformIO projects): brew install platformio / pipx install platformio"
case ":$ORIG_PATH:" in
  *":$LOCAL_BIN:"*) ;;
  *) warn "add ~/.local/bin to your PATH" ;;
esac
echo "  open nvim; treesitter parsers finish installing on the first start."
