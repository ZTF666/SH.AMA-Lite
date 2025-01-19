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
required_commands=("awk" "sed" "grep" "cut" "tr")
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

# Determine package manager and count installed packages
if command -v dpkg &> /dev/null; then
  pkgs=$(dpkg --get-selections | wc -l)
elif command -v rpm &> /dev/null; then
  pkgs=$(rpm -qa | wc -l)
elif command -v pacman &> /dev/null; then
  pkgs=$(pacman -Q | wc -l)
elif command -v brew &> /dev/null; then
  pkgs=$(brew list | wc -l)
elif command -v zypper &> /dev/null; then
  pkgs=$(zypper se --installed-only | wc -l)
elif command -v pkg &> /dev/null; then
  pkgs=$(pkg query "%n" | wc -l)
elif command -v port &> /dev/null; then
  pkgs=$(port installed | wc -l)
elif command -v apk &> /dev/null; then
  pkgs=$(apk info | wc -l)
else
  pkgs="N/A"
fi


# Calculate system uptime
up=$(awk '{d=$1/86400; h=($1%86400)/3600; m=($1%3600)/60; printf "%dd, %dh, %dm\n", d, h, m}' /proc/uptime)

# Main function to display info
display_info() {
  echo -e "            ${green}——-${purple}SH${red}.${purple}AMA${green}-——"
  echo -e ""
  echo -e "      ${green}|${purple}■${grey} OS        ${red}: ${grey} ${os^^}"
  echo -e "      ${purple}|${green}■${grey} KERNEL    ${red}: ${grey} ${kernel}"
  echo -e "      ${green}|${purple}■${grey} HOST      ${red}: ${grey} ${host^^}"
  echo -e "      ${purple}|${green}■${grey} UPTIME    ${red}: ${grey} ${up}"
  echo -e "      ${green}|${purple}■${grey} CPU       ${red}: ${grey} ${cpu^^}"
  echo -e "      ${purple}|${green}■${grey} GPU       ${red}: ${grey} ${gpu}"
  echo -e "      ${green}|${purple}■${grey} RAM       ${red}: ${grey} ${ram}MB"
  echo -e "      ${purple}|${green}■${grey} SWAP      ${red}: ${grey} ${swap}MB"
  echo -e "      ${green}|${purple}■${grey} PKGS      ${red}: ${grey} ${pkgs}"
  echo -e "      ${purple}|${green}■${grey} DISK      ${red}: ${grey} ${disk}"
  echo -e "      ${green}|${purple}■${grey} LOAD AVG  ${red}: ${grey} ${loadavg}"
  echo -e "      ${purple}|${green}■${grey} PROCESSES ${red}: ${grey} ${processes}"
  echo -e "      ${green}|${purple}■${grey} DATETIME  ${red}: ${grey} ${datetime}"
  echo -e ""
}

# Display ASCII logo
echo -e ""
echo -e "               |\_/|"
echo -e "               '${yellow}o${transparent}.${yellow}o${transparent}'"
echo -e "               > ^ <"

# Call main function to display information
display_info
