#!/bin/bash
SCREENNUM=`ps -e | grep -c screen`
count=1
TMUXNUM=`ps -e | grep -c tmux`
Reloadtime=500
clear
f=3 b=4
for j in f b; do
  for i in {0..7}; do
    printf -v $j$i %b "\e[${!j}${i}m"
  done
done
rst=$'\e[0m'
bld=$'\e[1m'
echo -e "\e[100m                                   Launcher Script                             \e[00;37;40m"
echo -e "\e[01;34m                                    By TE(1)Egamer                               \e[00;37;40m"
echo ""
sleep 0.5
cat << EOF
 $f1██████████ ██████████ ██████████    ███████   ██████████$rst
 $f1    ██     ██      ██ ██       █  ██       ██     ██$rst
 $f1    ██     ██      ██ ██       █  ██              ██$rst
 $f1    ██     ██      ██ ██████████  ██              ██$rst
 $f1    ██     ██████████ ██       █  ██              ██$rst
 $f1    ██     ██      ██ ██       █  ██       ██     ██$rst
 $f1    ██     ██      ██ ██████████    ███████   ██████████$rst
EOF
sleep 2
echo ""
echo ""
cat << EOF
 $f1  ▀▄   ▄▀     $f2 ▄▄▄████▄▄▄    $f3  ▄██▄     $f4  ▀▄   ▄▀     $f5 ▄▄▄████▄▄▄    $f6  ▄██▄  $rst
 $f1 ▄█▀███▀█▄    $f2███▀▀██▀▀███   $f3▄█▀██▀█▄   $f4 ▄█▀███▀█▄    $f5███▀▀██▀▀███   $f6▄█▀██▀█▄$rst
 $f1█▀███████▀█   $f2▀▀███▀▀███▀▀   $f3▀█▀██▀█▀   $f4█▀███████▀█   $f5▀▀███▀▀███▀▀   $f6▀█▀██▀█▀$rst
 $f1▀ ▀▄▄ ▄▄▀ ▀   $f2 ▀█▄ ▀▀ ▄█▀    $f3▀▄    ▄▀   $f4▀ ▀▄▄ ▄▄▀ ▀   $f5 ▀█▄ ▀▀ ▄█▀    $f6▀▄    ▄▀$rst
EOF
sleep 1.5
    echo -e "\e[01;34m Script Reload In Every $Reloadtime Seconds\e[00;37;40m"
    echo -e "\e[01;34m Number Of Screens Running : $SCREENNUM\e[00;37;40m"
    echo -e "\e[01;34m Number Of Tmux Running : $TMUXNUM\e[00;37;40m"
sleep 3.5
cat << EOF
 $bld$f1▄ ▀▄   ▄▀ ▄   $f2 ▄▄▄████▄▄▄    $f3  ▄██▄     $f4▄ ▀▄   ▄▀ ▄   $f5 ▄▄▄████▄▄▄    $f6  ▄██▄  $rst
 $bld$f1█▄█▀███▀█▄█   $f2███▀▀██▀▀███   $f3▄█▀██▀█▄   $f4█▄█▀███▀█▄█   $f5███▀▀██▀▀███   $f6▄█▀██▀█▄$rst
 $bld$f1▀█████████▀   $f2▀▀▀██▀▀██▀▀▀   $f3▀▀█▀▀█▀▀   $f4▀█████████▀   $f5▀▀▀██▀▀██▀▀▀   $f6▀▀█▀▀█▀▀$rst
 $bld$f1 ▄▀     ▀▄    $f2▄▄▀▀ ▀▀ ▀▀▄▄   $f3▄▀▄▀▀▄▀▄   $f4 ▄▀     ▀▄    $f5▄▄▀▀ ▀▀ ▀▀▄▄   $f6▄▀▄▀▀▄▀▄$rst
EOF
echo "Try To Checking Tabchi Folder"
ls ../ | grep tabchi 2>/dev/null >/dev/null
if [ $? != 0 ]; then
  echo -e "$f1 ERROR: Tabchi: Tabchi Folder NOT FOUND IN YOUR HOME DIRECTORY$rst"
  echo -e "$f1 ERROR: Try To Change Tabchi Folder Name To tabchi$rst"
  sleep 4
  exit 1
fi
echo -e "$f2 Tabchi Folder FOUND IN YOUR HOME DIRECTORY$rst"
ls ./ | grep tabchi.license 2>/dev/null >/dev/null
if [ $? != 0 ]; then
  echo -e "$f1 ERROR: Tabchi: This Auto Launcher Can Be Used Just For Our Source$rst"
  echo -e "$bld$f2 Github : https://github.com/tabchis/tabchi $rst"
  sleep 4
  exit 1
fi
sleep 1.5
while true ; do
  for entr in tabchi-*.sh ; do
    entry="${entr/.sh/}"
    tmux kill-session -t $entry
    tmux new-session -d -s $entry "./$entr"
    tmux detach -s $entry
  done
  echo -e ""
  echo -e "$bld$f2 BOT Reloaded$rst"
  echo -e "$bld$f2 Bot Source : Tabchi $rst"
  sleep 0.5
  echo -e "$bld$f2 Github : https://github.com/tabchis/tabchi $rst"
  sleep 0.5
  echo -e "$bld$f2 Telegram  : T.ME/Te1egamer $rst"
  sleep 0.5
  echo -e "$bld$f2 Times Reloaded : $count $rst"
  sleep $Reloadtime
   let count=count+1
	if [ "$count" == 2400 ]; then
		sync
		sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
	fi
done
