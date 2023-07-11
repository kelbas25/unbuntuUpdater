#!/bin/bash

log_file="myupdater.log"
lockfile="tmp/script.lock"


cleanup() {
  if [[ -e "$lockfile" ]]; then
    rm "$lockfile"
  fi
  log_message "Script was interrupted"
  exit 1
}
trap cleanup SIGINT SIGTERM

if [[ ! -d "tmp" ]]; then
  mkdir "tmp"
fi

log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S"): $1" >> "$log_file"
}

if [[ -e "$lockfile" ]]; then
  log_message "Script is already running."
  exit 1
fi

network_check() {
    for (( i=1; i<=5; i++ )); do
        echo "$(basename "$0")"
        if ping -c 1 google.com > /dev/null; then
            return 0
        fi
        sleep 20
    done
    return 1
}

perform_updates() {
    sudo apt update && sudo apt upgrade -y | sudo tee "$log_file" > /dev/null
    if [ $? -eq 0 ]; then
        log_message "Ubuntu update succeeded."
    else
        log_message "Ubuntu update failed."
    fi

    mirror_urls=(
        "git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git"
        "git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git"
    )

    for url in "${mirror_urls[@]}"; do
        repo_name="$(basename $(dirname "$url"))$(basename "$url" .git)"

        if [ -d "$repo_name" ]; then
            cd "$repo_name"
            cd "linux"
            git pull >> "$log_file"
            if [ $? -eq 0 ]; then
                log_message "Updated $repo_name."
            else
                log_message "Failed to update $repo_name."
            fi
            cd ../..
        else
            mkdir "$repo_name"
            cd "$repo_name"
            git clone "$url" >> "$log_file" 2>&1
            if [ $? -eq 0 ]; then
                log_message "Cloned $repo_name."
            else
                log_message "Failed to clone $repo_name."
            fi
            cd ..
        fi
    done
}

log_message "Script started."
touch "$lockfile"

if ! network_check; then
    log_message "No network connectivity. Update canceled."
    exit 1
fi

perform_updates

rm "$lockfile"
exit 0
