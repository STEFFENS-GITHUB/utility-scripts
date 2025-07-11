#!/bin/bash
# This is a utility script used to gather info about local users on a linux system. 
# By default, the script simply lists all users on a system
# If ran in summary mode (-s, --summary), it gives information about all users on the system
# If ran against a specific user, it gives information about that user. Running (-s, --summary) against a user has the same result

if [ "$EUID" -ne 0 ]; then # Checks if the user executing the script is root
  echo "This script must be run as root"
  exit 1
fi

summary=false # Var used to check if script is running in summary mode
users=($(cut -d: -f1 /etc/passwd))
for arg in "$@"; do
    case "$arg" in
        -s|--summary)
            summary=true
            ;;
        *)
            if echo "${users[@]}" | grep -qw "$arg"; then # Checks if arg is part of the users array
                user="$arg"
            else
                echo Invalid argument: "$arg"
                exit 1
            fi
    esac
done

if [ -n "$user" ]; then
    echo USERNAME:"$user"
    echo -n "USER ID:"; cat /etc/passwd | grep "$user" | cut -d: -f3
    echo -n "GROUP ID:"; cat /etc/passwd | grep "$user" | cut -d: -f4
    echo -n "HOME DIRECTORY:"; cat /etc/passwd | grep "$user" | cut -d: -f6
    echo -n "LOGIN SHELL:"; cat /etc/passwd | grep "$user" | cut -d: -f7
    
    password_status=$(cat /etc/shadow | grep "^$user" | cut -d: -f2)
    case "$password_status" in 
        '!!'*)
            echo "PASSWORD STATUS:Not set"
            ;;
        '!'*)
            echo "PASSWORD STATUS:Locked"
            ;;
        *)
            echo "PASSWORD STATUS:Unlocked"
            ;;
    esac
    exit
elif [ "$summary" = "true" ]; then
    echo -n "TOTAL SYSTEM USERS:"; cat /etc/passwd | wc -l
    echo -n "REGULAR USERS:"; awk -F: '$3 > 1000 {count++} END {print count}' /etc/passwd # Prints number of users with UID 1000 or greater
    echo -n "NUMBER OF LOCKED ACCOUNTS:"; grep '^.*:!' /etc/shadow | grep -v '^.*:!!' | grep -v '^.*:!\*' | wc -l # Checks number of locked accounts, excludes accounts starting with !! or !*
else
    echo "${users[@]}"
fi