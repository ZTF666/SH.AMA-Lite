#!/bin/bash

# Hello ! 
# This is a simple/minimal script 
# To fetch some basic information about your system
# I made this for my own personal use 
# It is limited as you can see
# It's my own take on neofetch but less flashy and less fancy lol
# I understand that my code isn't 5* quality ,so yeah ...
# I only tested it on Kali and Ubuntu 
# On other distros some commands won't work
# So please feel free to change whatever command
# Does not work with the appropriate one for your system .

#Colors
grey="\033[0;37m"
purple="\033[0;35m"
red="\033[1;31m"
green="\033[1;32m"
yellow="\033[1;33m"
transparent="\e[0m"

#Commands & variables

#OS 
osTemp="$(cat /etc/os-release | grep "ID" | head -1)"
readarray -d = -t strarr <<< $osTemp
#removing trailing spaces
os="$(echo -e "${strarr[1]}" | sed -e 's/[[:space:]]*$//')"

#CPU info
cpuTemp="$(cat /proc/cpuinfo | grep 'model name' |uniq)"
readarray -d : -t strarrcpu <<< $cpuTemp
cpu="$(echo -e "${strarrcpu[1]}"  | tr -d '[:space:]')"

#RAM info
ramTemp="$(cat /proc/meminfo | grep 'MemTotal')"
readarray -d : -t strarrram <<< $ramTemp
#trim white spaces and removes the kB at the end so it can be displayed as Mb afterwards
ramx="$(echo -e "${strarrram[1]}"  | tr -d '[:space:]' | sed 's/..$//' )"
ram=$((ramx / 1000))

#Hostname
host="$(cat /proc/sys/kernel/hostname)"

#Number of packages installed (everything included)
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

#Uptime
up="$(uptime | awk -F'( |,|:)+' '{d=h=m=0; if ($7=="min") m=$6; else {if ($7~/^day/) {d=$6;h=$8;m=$9} else {h=$6;m=$7}}} {print d+0,"d,",h+0,"h,",m+0,"m."}')"


# Main function
Shama(){
while true;
do
        #echo ""
        echo -e "            "$green"——-"$purple"SH"$red"."$purple"AMA"$green"-——"   
        echo -e ""    
        echo -e "      "$green"|"$purple"■"$grey" OS     "  $red":" $grey" ${os^^}    "
        echo -e "      "$purple"|"$green"■"$grey" UP     "  $red":" $grey" ${up}     "
        echo -e "      "$green"|"$purple"■"$grey" CPU    "  $red":" $grey" ${cpu^^}     "
        echo -e "      "$purple"|"$green"■"$grey" RAM    "  $red":" $grey" ${ram}Mb    "
        echo -e "      "$green"|"$purple"■"$grey" HOST   "  $red":" $grey" ${host^^}     "
        echo -e "      "$purple"|"$green"■"$grey" PKGS   "  $red":" $grey" ${pkgs}     "
        echo ""

 break;
done
echo 
}

#Logo
echo -e ""
echo -e "               |\_/|"
echo -e "               '"$yellow"o"$transparent"."$yellow"o"$transparent"'"  
echo -e "               > ^ <"

# Main function init
Shama;
