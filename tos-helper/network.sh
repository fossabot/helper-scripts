#!/bin/bash
function help {
        subname="network"
        printf "${ORANGE} $name $subname ${NC}OPTIONS: metric | restart | connect | list | help\n\n" 
        printf "${ORANGE}USAGE:${NC}\n"
        printf "$name $subname help \t\t\t\t Show this help message\n"
        printf "$name $subname metric <route> <value> \t\t Change the metric of a route to said value\n"
        printf "$name $subname restart \t\t\t\t Restart the network stack\n"
        printf "$name $subname connect <ssid> \t\t\t Connect to a wifi network based on its ssid\n"
        printf "$name $subname list \t\t\t\t Show a list of all wifi networks found\n"
}

function changemetric {
        if [ "$(id -u)" == "0" ]; then

            echo "$1" "$2"
            current=$(ip route | grep -E "^default .* $1")
            new=$(printf "%s" "$current" | sed "s/metric [0-9]*/metric /")"$2"
            ip route del "$current"
            ip route add "$new"
        else
                printf "${RED}Only the root user can change the metric${NC}\n"
        fi
}

function listdevices {
    devices=$(ip link show up | awk '$1 ~ /[0-9]*:.*/{printf $2}' | tr ':' ' ')
    for device in $devices; do
            printf "%s %s %s %s\n\n" "$device"  "$(ip addr show dev "$device" | awk '$1 ~ /inet|inet6/{printf $1": "$2" " }')"  "Route:  " "$(ip route show dev "$device" | head -n1)"
    done
}

case "$2" in
    "m"|"metric")
        if [[ "$3" == "" || "$4" == "" ]]; then
                    printf "${RED}Can't change metric of specified device because you didn't specifie the device or metric value${NC}\n"
            else
                    changemetric "$3" "$4"
        fi
    ;;
    "d"|"device")
        listdevices
    ;;
    "r"|"restart")
        systemctl restart NetworkManager
    ;;
    "c"|"connect")
        if [[ "$3" != "" ]]; then
            nmcli dev wifi connect -a "${@:3}"
        fi
    ;;
    "l"|"list")
        nmcli d wifi list
    ;;
    "-h"|"--help"|"help"|"h")
        help
    ;;   
esac
