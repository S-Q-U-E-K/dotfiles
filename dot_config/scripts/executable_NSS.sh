#!/usr/bin/env sh

read -p "Which Year:" year
sleep 0.1
read -p "Which Semester:" semester
sleep 0.1
read -p "Which Subject:" subject
sleep 0.1
read -p "Name of screenshot:" filename
sleep 0.1
grim -g "$(slurp)" "/home/zekea/Vault/Uni/Year $year/Semester $semester/$subject/Pictures/$filename.jpg"
echo "Screenshot saved to ~/Vault/Uni/Year $year/Semester $semester/$subject/Pictures/$filename.jpg"
echo !\[$filename\]\(Pictures/$filename.jpg\) >>/tmp/notescopy.txt
tail -n 1 /tmp/notescopy.txt | wl-copy
