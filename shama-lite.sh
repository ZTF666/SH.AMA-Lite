#!/bin/bash

# A simple script to fetch basic system information
# Tested on Kali, ubuntu, and arch may need adjustments for other distributions.

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

# OS
os=$(awk -F= '/^PRETTY_NAME=/{print $2}' /etc/os-release | tr -d '"')

# CPU info
cpu=$(awk -F: '/model name/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}' /proc/cpuinfo)

# RAM info
ram_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
ram=$((ram_kb / 1024)) # Convert from kB to MB

# Hostname
host=$(cat /proc/sys/kernel/hostname)

# Number of packages installed
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

# Uptime
up=$(awk '{d=$1/86400; h=($1%86400)/3600; m=($1%3600)/60; printf "%dd, %dh, %dm\n", d, h, m}' /proc/uptime)

# Current date and time
datetime=$(date '+%Y-%m-%d %H:%M:%S')

# Main function to display info
display_info() {
  echo -e "            ${green}——-${purple}SH${red}.${purple}AMA${green}-——"   
  echo -e ""    
  echo -e "      ${green}|${purple}■${grey} OS       ${red}: ${grey} ${os^^}"
  echo -e "      ${green}|${purple}■${grey} DATETIME ${red}: ${grey} ${datetime}"
  echo -e "      ${purple}|${green}■${grey} UPTIME   ${red}: ${grey} ${up}"
  echo -e "      ${green}|${purple}■${grey} CPU      ${red}: ${grey} ${cpu^^}"
  echo -e "      ${green}|${purple}■${grey} GPU      ${red}: ${grey} ${gpu}"
  echo -e "      ${purple}|${green}■${grey} RAM      ${red}: ${grey} ${ram}MB"
  echo -e "      ${green}|${purple}■${grey} HOST     ${red}: ${grey} ${host^^}"
  echo -e "      ${purple}|${green}■${grey} PKGS     ${red}: ${grey} ${pkgs}"
  echo -e ""
}

# Logo
echo -e ""
echo -e "               |\_/|"
echo -e "               '${yellow}o${transparent}.${yellow}o${transparent}'"  
echo -e "               > ^ <"

# Main function init
display_info
