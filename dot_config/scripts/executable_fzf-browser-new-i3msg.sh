#!/bin/bash
IFS=$'\n'

SCRIPTNAME=$(basename $0)
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [[ -n $THEME ]]; then
    fzf_color="--color=$THEME"
fi

rm_field_codes() {
    str=$1
    str=${str//\%f/}
    str=${str//\%F/}
    str=${str//\%u/}
    str=${str//\%U/}
    str=${str//\%d/}
    str=${str//\%D/}
    str=${str//\%n/}
    str=${str//\%N/}
    str=${str//\%i/}
    str=${str//\%c/}
    str=${str//\%k/}
    str=${str//\%v/}
    str=${str//\%m/}
}

# $THEME env variable set via sway config.

# check for env variable, if exists we are the
# forked shell, get the waiting string from the fifo
# and call fzf and sway from there.
prompt="Qutebrowser> "
header="View which tab?"
if [[ -n $SMD_FIFO ]]; then
    rm -rf $SMD_FIFO

    # Build fzf string
    tab_name=""
    declare -A name_to_focus
    for p in $(wmctrl -l| grep qutebrowser | awk '{$3=""; $2=""; $1=""; print $0}' | awk '{gsub(/ - qutebrowser/, "")}1' | awk '{gsub(/ /, "¬")}1' | awk '{gsub(/¬¬¬/, "")}1'); do
        tab_name=$p
        tab_name=${tab_name##*/}
        tabs="$tabs $tab_name\n"
        tabs=$(echo $tabs | awk '{gsub(/¬/, " ")}1')
    done
    # get current desktop
    current_desktop=$(i3-msg -t get_workspaces | jq '.[] | select(.focused).num')



    selection=$(echo $tabs | awk '{gsub(/¬/, " ")}1' | printf $tabs | fzf --header=$header  --prompt="$prompt" $fzf_color)
    selection=$(echo $selection | xargs echo -n)
    selection=${selection% :*}
    if [[ -z $selection ]]; then
        exit
    fi
    tab_name=$selection
    tab_name=$(echo $tab_name | awk '{gsub(/¬/, " ")}1' | awk '{print $0" - qutebrowser"}' | awk '{print "\""$0"\""}')
    focus_tab=$(echo $tab_name | awk '{print "/usr/bin/wmctrl -R " $0}')
    setsid --fork bash -c $focus_tab &> /dev/null
    exit
fi

lines=20c
columns=$((columns+"${#header}"+20)c)
if [[ columns -gt 100 ]];
then
    columns=100
fi

fifo=/tmp/std-$(date +%s)
mkfifo $fifo
SMD_FIFO=$fifo $SHELL -c "kitty \
    -o initial_window_width=$columns \
    -o initial_window_height=$lines \
    -o window_padding_width=20 \
    --title "fzf-switcher" \
    -e $SCRIPTPATH/$SCRIPTNAME"&
