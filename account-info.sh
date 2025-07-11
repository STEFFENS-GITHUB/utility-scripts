#!/bin/bash
summary=false
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
    
    password_status=$(cat /etc/shadow | grep '^DONALD' | cut -d: -f2)
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
    # secondary group ids
    exit
elif [ "$summary" = "true" ]; then
    echo "INFO ABOUT SUMMARY"
else
    echo "${users[@]}"
fi

# chage -l
# lastlog