# MyUpdater
MyUpdater is a shell script that helps keep Ubuntu up-to-date and synchronizes local kernel.org mirrors. It provides an easy-to-use solution for maintaining multiple mirrors and logging update results.

## Installation
Clone the repository or download the myupdater.sh script to your local machine.

    git clone https://github.com/kelbas25/ubuntuUpdater
Change to the directory where the script is located.

    cd myupdater

## Usage

1.Make the script executable.

    chmod +x myupdater.sh
2.Run

    ./myupdater.sh

### OR

    /bin/bash /path/to/script/myupdater.sh
**(change path to your real path)**

## Scheduling the Script
To run the script automatically at a specific time (every day 1:00 AM in this case), you can use the cron utility. Follow these steps:

`crontab -e`

Add the following line to the end of the file:

    0 1 * * * /path/to/script/myupdater.sh
**(change path to your real path)**

