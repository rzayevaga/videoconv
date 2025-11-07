#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'
BOLD='\033[1m'

STEP_DELAY=0.3
SPINNER_DELAY=0.06
BANNER_DELAY=0.01
LOG_FILE="process.log"
SYSTEM_NAME=""
PACKAGE_MANAGER=""
USER_NAME=$(whoami)
HOST_NAME=$(hostname)

cleanup() {
  printf "\n${YELLOW}Dayandırıldı. Təmizlənir...${RESET}\n"
  exit 2
}
trap cleanup INT TERM

log_message() {
  local level="$1"
  local message="$2"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

cecho() {
  color="$1"; shift
  local message="$*"
  printf "%b\n" "${color}$message${RESET}"
  log_message "INFO" "$message"
}

show_progress() {
  local current=$1
  local total=$2
  local message="$3"
  local width=50
  local percentage=$((current * 100 / total))
  local completed=$((current * width / total))
  local remaining=$((width - completed))
  
  printf "\r${CYAN}[${RESET}"
  printf "%*s" $completed | tr ' ' '█'
  printf "%*s" $remaining | tr ' ' '░'
  printf "${CYAN}] ${YELLOW}%3d%%${RESET} ${WHITE}%s${RESET}" $percentage "$message"
}

spinner() {
  local pid=$1
  local message="${2:-Yüklənir...}"
  local delay=${SPINNER_DELAY}
  local spinstr='⣷⣯⣟⡿⢿⣻⣽⣾'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r${CYAN}%s${RESET} ${WHITE}%s${RESET}" "${spinstr:i++%${#spinstr}:1}" "$message"
    sleep "$delay"
  done
  printf "\r\033[K"
}

detect_system() {
  cecho "${MAGENTA}${BOLD}" "🖥️  Sistem analizi başlayır..."
  sleep $STEP_DELAY

  if [[ "$OSTYPE" == "linux-android"* ]]; then
    SYSTEM_NAME="Termux"
    PACKAGE_MANAGER="pkg"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/os-release ]; then
      source /etc/os-release
      SYSTEM_NAME="$NAME"
      case $ID in
        "ubuntu"|"debian") PACKAGE_MANAGER="apt" ;;
        "fedora") PACKAGE_MANAGER="dnf" ;;
        "centos"|"rhel") PACKAGE_MANAGER="yum" ;;
        "arch"|"manjaro") PACKAGE_MANAGER="pacman" ;;
        "alpine") PACKAGE_MANAGER="apk" ;;
        *) PACKAGE_MANAGER="apt" ;;
      esac
    else
      SYSTEM_NAME="Linux"
      PACKAGE_MANAGER="apt"
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    SYSTEM_NAME="macOS"
    PACKAGE_MANAGER="brew"
  else
    SYSTEM_NAME="Windows"
    PACKAGE_MANAGER="choco"
  fi

  cecho "${GREEN}✅ Sistem aşkarlandı: ${WHITE}${SYSTEM_NAME}${RESET}"
  cecho "${BLUE}📦 Paket meneceri: ${WHITE}${PACKAGE_MANAGER}${RESET}"
  cecho "${BLUE}👤 İstifadəçi: ${WHITE}${USER_NAME}${RESET}"
  cecho "${BLUE}🖥️  Host: ${WHITE}${HOST_NAME}${RESET}"
  log_message "SYSTEM" "Detected: $SYSTEM_NAME, Package Manager: $PACKAGE_MANAGER"
}

animate_banner() {
  local banner=(
    "⠀⠀⠀⠀⠀⠀⠀           ⠀⠀⢀⣠⣤⠶⠶⠶⠶⢦⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠛⠁⠀⠀⠀⠀⠀⠀⠈⠙⢷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⢷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡾⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣼⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠸⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⣠⡴⠞⠛⠉⠉⣩⣍⠉⠉⠛⠳⢦⣄⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡀⠀⣴⡿⣧⣀⠀⢀⣠⡴⠋⠙⢷⣄⡀⠀⣀⣼⢿⣦⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⣧⡾⠋⣷⠈⠉⠉⠉⠉⠀⠀⠀⠀⠉⠉⠋⠉⠁⣼⠙⢷⣼⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣇⠀⢻⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⡟⠀⣸⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣹⣆⠀⢻⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡟⠀⣰⣏⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣴⠞⠋⠁⠙⢷⣄⠙⢷⣀⠀⠀⠀⠀⠀⠀⢀⡴⠋⢀⡾⠋⠈⠙⠻⢦⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠋⠀⠀⠀⠀⠀⠀⠹⢦⡀⠙⠳⠶⢤⡤⠶⠞⠋⢀⡴⠟⠀⠀⠀⠀⠀⠀⠙⠻⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠀⣼⠋⠀⠀⢀⣤⣤⣤⣤⣤⣤⣤⣿⣦⣤⣤⣤⣤⣤⣤⣴⣿⣤⣤⣤⣤⣤⣤⣤⡀⠀⠀⠙⣧⠀⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⣸⠏⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⢠⣴⠞⠛⠛⠻⢦⡄⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠸⣇⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⢠⡟⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⣿⣿⢶⣄⣠⡶⣦⣿⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⢻⡄⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⣾⠁⠀⠀⠀⠀⠘⣇⠀⠀⠀⠀⠀⠀⠀⢻⣿⠶⠟⠻⠶⢿⡿⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠈⣿⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⢰⡏⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⢾⣄⣹⣦⣀⣀⣴⢟⣠⡶⠀⠀⠀⠀⠀⠀⣼⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠀⠈⠛⠿⣭⣭⡿⠛⠁⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⠘⣧⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⢿⡀⠀⠀⠀⠀⠀⠀⣀⡴⠞⠋⠙⠳⢦⣀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀⢰⡏⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠈⢿⣄⣀⠀⠀⢀⣤⣼⣧⣤⣤⣤⣤⣤⣿⣭⣤⣤⣤⣤⣤⣤⣭⣿⣤⣤⣤⣤⣤⣼⣿⣤⣄⠀⠀⣀⣠⡾⠁⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠛⠻⢧⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠤⠼⠟⠛⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
    "⣷⣶⣶⣶⣶⣶⣶⣿⣷⣶⣿⣿⣾⣿⣶⣶⣿⣿⣷⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⣷⣷⣿⣷⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶"
    "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣷⣶⣿⣿"
  )

  log_message "INFO" "Banner animasiyası başladı"
  
  for line in "${banner[@]}"; do
    printf "%b\n" "${CYAN}${line}${RESET}"
    sleep $BANNER_DELAY
  done
  
  log_message "INFO" "Banner animasiyası tamamlandı"
}

install_python_pip() {
  local total_steps=6
  local current_step=1
  
  show_progress $current_step $total_steps "Sistem yenilənir..."
  case $PACKAGE_MANAGER in
    "apt") sudo apt update -y >> "$LOG_FILE" 2>&1 ;;
    "pkg") pkg update -y >> "$LOG_FILE" 2>&1 ;;
    "dnf") sudo dnf update -y >> "$LOG_FILE" 2>&1 ;;
    "yum") sudo yum update -y >> "$LOG_FILE" 2>&1 ;;
    "pacman") sudo pacman -Syu --noconfirm >> "$LOG_FILE" 2>&1 ;;
    "brew") brew update >> "$LOG_FILE" 2>&1 ;;
  esac
  ((current_step++))
  
  show_progress $current_step $total_steps "Python quraşdırılır..."
  case $PACKAGE_MANAGER in
    "apt") sudo apt install -y python3 python3-pip python3-venv >> "$LOG_FILE" 2>&1 ;;
    "pkg") pkg install -y python python-pip >> "$LOG_FILE" 2>&1 ;;
    "dnf") sudo dnf install -y python3 python3-pip >> "$LOG_FILE" 2>&1 ;;
    "yum") sudo yum install -y python3 python3-pip >> "$LOG_FILE" 2>&1 ;;
    "pacman") sudo pacman -S --noconfirm python python-pip >> "$LOG_FILE" 2>&1 ;;
    "brew") brew install python3 >> "$LOG_FILE" 2>&1 ;;
  esac
  ((current_step++))
  
  show_progress $current_step $total_steps "Virtual mühit yaradılır..."
  python3 -m venv venv >> "$LOG_FILE" 2>&1
  ((current_step++))
  
  show_progress $current_step $total_steps "Pip yenilənir..."
  source venv/bin/activate
  pip install --upgrade pip >> "$LOG_FILE" 2>&1
  ((current_step++))
  
  show_progress $current_step $total_steps "Kitabxanalar yüklənir..."
  if [ -f requirements.txt ]; then
    pip install -r requirements.txt >> "$LOG_FILE" 2>&1
  else
    pip install requests beautifulsoup4 selenium >> "$LOG_FILE" 2>&1
  fi
  ((current_step++))
  
  show_progress $current_step $total_steps "Quraşdırma tamamlanır..."
  sleep 1
  printf "\n${GREEN}✅ Python və kitabxanalar uğurla quraşdırıldı${RESET}\n"
}

get_system_greeting() {
  case $SYSTEM_NAME in
    "Termux") echo "Termux giriş" ;;
    "Ubuntu"|"Debian") echo "Ubuntu/Debian giriş" ;;
    "Fedora") echo "Fedora giriş" ;;
    "CentOS"|"Red Hat Enterprise Linux") echo "CentOS/RHEL giriş" ;;
    "Arch Linux"|"Manjaro") echo "Arch/Manjaro giriş" ;;
    "macOS") echo "macOS giriş" ;;
    "Windows") echo "Windows giriş" ;;
    *) echo "Sistem giriş" ;;
  esac
}

run_system_check() {
  cecho "${YELLOW}🔍 Sistem yoxlaması aparılır..."
  
  local checks=(
    "Python|python3 --version"
    "Pip|pip --version"
    "Virtual mühit|source venv/bin/activate && python -c 'import sys; print(sys.prefix != sys.base_prefix)'"
  )
  
  for check in "${checks[@]}"; do
    IFS='|' read -r name command <<< "$check"
    printf "${WHITE}   %-20s${RESET}" "$name"
    if eval "$command &>/dev/null"; then
      cecho "${GREEN} ✅${RESET}"
    else
      cecho "${RED} ❌${RESET}"
    fi
    sleep 0.2
  done
}

main() {
  echo "=== AI TEKNOLOJI SETUP PROCESS ===" > "$LOG_FILE"
  echo "Start Time: $(date)" >> "$LOG_FILE"
  echo "User: $USER_NAME" >> "$LOG_FILE"
  echo "Host: $HOST_NAME" >> "$LOG_FILE"
  echo "================================" >> "$LOG_FILE"
  
  cecho "${MAGENTA}${BOLD}" "🚀 AI Teknoloji Platformu başladı..."
  sleep $STEP_DELAY

  detect_system
  
  cecho "${CYAN}" "📈 Quraşdırma prosesi başlayır..."
  sleep $STEP_DELAY
  
  cecho "${CYAN}" "ㅤㅤㅤ1%"
  sleep $STEP_DELAY
  cecho "${CYAN}" "ㅤㅤㅤㅤㅤ10%"
  sleep $STEP_DELAY
  cecho "${CYAN}" "ㅤㅤㅤㅤㅤㅤㅤ20%"
  sleep $STEP_DELAY
  cecho "${CYAN}" "ㅤㅤㅤㅤㅤㅤㅤㅤㅤㅤ30%"
  sleep $STEP_DELAY
  cecho "${CYAN}" "ㅤㅤㅤㅤㅤㅤㅤㅤㅤㅤㅤㅤ40%"
  sleep $STEP_DELAY
  cecho "${YELLOW}" "ㅤㅤㅤㅤㅤㅤㅤㅤㅤㅤㅤㅤㅤㅤㅤ50%"
  sleep $STEP_DELAY

  cecho "${GREEN}" "ㅤㅤ⏳ Səbr elə — yüklənir..."
  sleep $STEP_DELAY

  animate_banner

  sleep $STEP_DELAY
  cecho "${GREEN}" "ㅤㅤ📚 Kitabxanaların yüklənməsi..."

  if ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1; then
    install_python_pip
  else
    cecho "${GREEN}✅ Python artıq quraşdırılıb"
    if ! command -v pip3 >/dev/null 2>&1 && ! command -v pip >/dev/null 2>&1; then
      install_python_pip
    else
      cecho "${GREEN}✅ Pip artıq quraşdırılıb"
      python3 -m venv venv >> "$LOG_FILE" 2>&1 &
      spinner $! "Virtual mühit yaradılır..."
      source venv/bin/activate
      
      if [ -f requirements.txt ]; then
        pip install -r requirements.txt >> "$LOG_FILE" 2>&1 &
        spinner $! "Kitabxanalar quraşdırılır..."
      fi
    fi
  fi

  local greeting=$(get_system_greeting)
  cecho "${YELLOW}" "ㅤㅤ🔄 $greeting"
  cecho "${YELLOW}" "       60%"
  sleep $STEP_DELAY
  cecho "${YELLOW}" "          70%"
  sleep $STEP_DELAY
  cecho "${YELLOW}" "ㅤㅤㅤㅤㅤㅤㅤㅤㅤ80%"
  sleep $STEP_DELAY
  cecho "${YELLOW}" "ㅤㅤ ㅤㅤㅤㅤㅤㅤㅤㅤ 90%"
  sleep $STEP_DELAY
  cecho "${GREEN}" "ㅤㅤㅤ ㅤㅤㅤㅤㅤㅤㅤㅤㅤㅤ100%"
  sleep $STEP_DELAY

  cecho "${GREEN}" "       🗂️  ./root/ai/aiteknoloji/start/"
  sleep 0.4
  
  run_system_check
  
  cecho "${MAGENTA}${BOLD}" "  ✅ Bütün mərhələlər tamamlandı."

  cecho "${CYAN}" "🔑 Zəhmət olmasa API məlumatlarını daxil edin:"
  
  read -rp "API_ID: " API_ID
  while ! [[ "$API_ID" =~ ^[0-9]+$ ]]; do
    cecho "${RED}❌ API_ID yalnız rəqəmlərdən ibarət olmalıdır."
    read -rp "API_ID: " API_ID
  done

  read -rp "API_HASH: " API_HASH
  while [[ -z "$API_HASH" ]]; do
    cecho "${RED}❌ API_HASH boş ola bilməz."
    read -rp "API_HASH: " API_HASH
  done

  read -rp "BOT_TOKEN: " BOT_TOKEN
  while [[ -z "$BOT_TOKEN" ]]; do
    cecho "${RED}❌ BOT_TOKEN boş ola bilməz."
    read -rp "BOT_TOKEN: " BOT_TOKEN
  done

  CONFIG_FILE="config.py"
  cat > "$CONFIG_FILE" <<EOF
from os import getenv

API_ID = int(getenv("API_ID", "$API_ID"))
API_HASH = getenv("API_HASH", "$API_HASH")
BOT_TOKEN = getenv("BOT_TOKEN", "$BOT_TOKEN")
EOF

  cecho "${GREEN}✅ Config faylı uğurla yaradıldı: $CONFIG_FILE"

  if [ -f ./start ]; then
    cecho "${CYAN}" "🎯 Start faylı tapıldı — işə salmaq üçün klaviaturada 'y' toxunun. (y/N)"
    read -r -n 1 -s answer || true
    printf "\n"
    if [[ "$answer" =~ [Yy] ]]; then
      cecho "${GREEN}🚀 Start işə salınır..."
      bash ./start
    else
      cecho "${YELLOW}⏸️  Start işə salınmadı. ./start ilə işlədə bilərsiniz."
    fi
  fi

  echo "================================" >> "$LOG_FILE"
  echo "End Time: $(date)" >> "$LOG_FILE"
  echo "=== SETUP COMPLETED ===" >> "$LOG_FILE"
  
  cecho "${GREEN}${BOLD}" "🎉 Bütün proses uğurla tamamlandı!"
  cecho "${CYAN}" "📝 Detallı log: $LOG_FILE faylına yazıldı"
}

main "$@"
