#!/usr/bin/env bash

# A simple script to fetch basic system information
# Tested on Kali, Ubuntu, and Arch; may need adjustments for other distributions.

# Colors
grey="\033[0;37m"
purple="\033[0;35m"
red="\033[1;31m"
green="\033[1;32m"
yellow="\033[1;33m"
transparent="\e[0m"

# Check dependencies
required_commands=("awk" "sed" "grep" "cut" "tr" "df" "uname" "uptime" "ps" "date" "ip")
missing_commands=()

for cmd in "${required_commands[@]}"; do
  if ! command -v $cmd &> /dev/null; then
    missing_commands+=($cmd)
  fi
done

if [ ${#missing_commands[@]} -ne 0 ]; then
  echo "Error: The following required commands are not installed: ${missing_commands[*]}" >&2
  exit 1
fi

# Check for lspci separately
if ! command -v lspci &> /dev/null; then
  echo "Warning: lspci is not installed. GPU information will not be displayed." >&2
  gpu="N/A"
else
  gpu=$(lspci | grep VGA | cut -d ':' -f 3 | cut -d '[' -f 1 | sed 's/^ *//')
fi

# Fetching system information
os=$(awk -F= '/^PRETTY_NAME=/{print $2}' /etc/os-release | tr -d '"')
cpu=$(awk -F: '/model name/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}' /proc/cpuinfo)
cpu_cores=$(awk '/^cpu cores/ {print $4; exit}' /proc/cpuinfo)
cpu_threads=$(awk '/^processor/ {count++} END {print count}' /proc/cpuinfo)
ram_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
ram=$((ram_kb / 1024)) # Convert from kB to MB
swap_kb=$(awk '/SwapTotal/ {print $2}' /proc/meminfo)
swap=$((swap_kb / 1024)) # Convert from kB to MB
host=$(cat /proc/sys/kernel/hostname)
kernel=$(uname -r)
disk=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')
loadavg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//')
processes=$(ps aux | wc -l)
datetime=$(date '+%Y-%m-%d %H:%M:%S')
battery_status=$(upower -i $(upower -e | grep BAT) | grep --color=never -E "state|to\ full|percentage")

# Determine package manager and count installed packages
if command -v dpkg &> /dev/null; then
  pkgs=$(dpkg --get-selections | wc -l)
elif command -v rpm &> /dev/null; then
  pkgs=$(rpm -qa | wc -l)
elif command -v pacman &> /dev/null; then
  pkgs=$(pacman -Q | wc -l)
elif command -v brew &> /dev/null; then
  pkgs=$(brew list | wc -l)
else
  pkgs="N/A"
fi
# Function to check for missing dependencies
check_dependencies() {
    required_commands=("awk" "sed" "grep" "cut" "tr" "df" "uname" "uptime" "ps" "date" "ip")
    missing_commands=()

    for cmd in "${required_commands[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            missing_commands+=($cmd)
        fi
    done

    if [ ${#missing_commands[@]} -ne 0 ]; then
        echo "Error: The following required commands are not installed: ${missing_commands[*]}" >&2
        exit 1
    fi

    if ! command -v lspci &> /dev/null; then
        echo "Warning: lspci is not installed. GPU information will not be displayed." >&2
        gpu="N/A"
    else
        gpu=$(lspci | grep VGA | cut -d ':' -f 3 | cut -d '[' -f 1 | sed 's/^ *//')
    fi
}

# Function to fetch system information
fetch_system_info() {
    os=$(awk -F= '/^PRETTY_NAME=/{print $2}' /etc/os-release | tr -d '"')
    cpu=$(awk -F: '/model name/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}' /proc/cpuinfo)
    cpu_cores=$(awk '/^cpu cores/ {print $4; exit}' /proc/cpuinfo)
    cpu_threads=$(awk '/^processor/ {count++} END {print count}' /proc/cpuinfo)
    ram_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    ram=$((ram_kb / 1024)) # Convert from kB to MB
    swap_kb=$(awk '/SwapTotal/ {print $2}' /proc/meminfo)
    swap=$((swap_kb / 1024)) # Convert from kB to MB
    host=$(cat /proc/sys/kernel/hostname)
    kernel=$(uname -r)
    disk=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')
    loadavg=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//')
    processes=$(ps aux | wc -l)
    datetime=$(date '+%Y-%m-%d %H:%M:%S')
    battery_status=$(upower -i $(upower -e | grep BAT) | grep --color=never -E "state|to\ full|percentage")

    if command -v dpkg &> /dev/null; then
        pkgs=$(dpkg --get-selections | wc -l)
    elif command -v rpm &> /dev/null; then
        pkgs=$(rpm -qa | wc -l)
    elif command -v pacman &> /dev/null; then
        pkgs=$(pacman -Q | wc -l)
    elif command -v brew &> /dev/null; then
        pkgs=$(brew list | wc -l)
    else
        pkgs="N/A"
    fi

    up=$(awk '{d=$1/86400; h=($1%86400)/3600; m=($1%3600)/60; printf "%dd, %dh, %dm\n", d, h, m}' /proc/uptime)
}

# Calculate system uptime
up=$(awk '{d=$1/86400; h=($1%86400)/3600; m=($1%3600)/60; printf "%dd, %dh, %dm\n", d, h, m}' /proc/uptime)

# Main function to display info
display_info() {
  echo -e "            ${green}——-${purple}SH${red}.${purple}AMA${green}-——"
  echo -e ""
  echo -e "      ${green}|${purple}■${grey} OS        ${red}: ${grey} ${os^^}"
  echo -e "      ${green}|${purple}■${grey} KERNEL    ${red}: ${grey} ${kernel}"
  echo -e "      ${green}|${purple}■${grey} HOST      ${red}: ${grey} ${host^^}"
  echo -e "      ${purple}|${green}■${grey} UPTIME    ${red}: ${grey} ${up}"
  echo -e "      ${green}|${purple}■${grey} CPU       ${red}: ${grey} ${cpu^^} (${cpu_cores} cores, ${cpu_threads} threads)"
  echo -e "      ${green}|${purple}■${grey} GPU       ${red}: ${grey} ${gpu}"
  echo -e "      ${purple}|${green}■${grey} RAM       ${red}: ${grey} ${ram}MB"
  echo -e "      ${green}|${purple}■${grey} SWAP      ${red}: ${grey} ${swap}MB"
  echo -e "      ${purple}|${green}■${grey} PKGS      ${red}: ${grey} ${pkgs}"
  echo -e "      ${purple}|${green}■${grey} DISK      ${red}: ${grey} ${disk}"
  echo -e "      ${purple}|${green}■${grey} LOAD AVG  ${red}: ${grey} ${loadavg}"
  echo -e "      ${purple}|${green}■${grey} PROCESSES ${red}: ${grey} ${processes}"
  echo -e "      ${green}|${purple}■${grey} DATETIME  ${red}: ${grey} ${datetime}"
  if [ -n "$battery_status" ]; then
    echo -e "      ${green}|${purple}■${grey} BATTERY   ${red}: ${grey} ${battery_status}"
  fi
  echo -e ""

  echo -e "      ${purple}|${green}■${grey} DISK USAGE:"

  # Display detailed disk usage in a table-like format
  printf "      %-30s %-10s %-10s %-10s\n" "Filesystem" "Size" "Used" "Use%"
  df -h | awk 'NR>1 {printf "      %-30s %-10s %-10s %-10s\n", $1, $2, $3, $5}'
}

# Display ASCII logo
echo -e ""
echo -e "               |\_/|"
echo -e "               '${yellow}o${transparent}.${yellow}o${transparent}'"
echo -e "               > ^ <"

# Call main function to display information
display_info












