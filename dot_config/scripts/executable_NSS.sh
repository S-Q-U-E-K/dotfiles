#!/usr/bin/env sh

read -p "Which Year:" year
read -p "Which Semester:" semester
read -p "Which Subject:" subject
read -p "Name of screenshot:" filename
grim -g "$(slurp)" "/home/zekea/Vault/Uni/Year $year/Semester $semester/$subject/Pictures/$filename.jpg"
echo "Screenshot saved to ~/Vault/Uni/Year $year/Semester $semester/$subject/Pictures/$filename.jpg"
echo !\[$filename\]\(Pictures/$filename.jpg\) >>/tmp/notescopy.txt
tail -n 1 /tmp/notescopy.txt | wl-copy
