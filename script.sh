#!/usr/bin/env bash

logo () {
    echo "
    _________________________________________  
                     _                       
         /\         | |                      
        /  \   _ __ | | __                   
       / /\ \ | '_ \| |/ /                   
      / ____ \| |_) |   <                    
     /_/___ \_\ .__/|_|\_\     _ _           
     |_   _|  | |    | |      | | |          
       | |  _ |_| ___| |_ __ _| | | ___ _ __ 
       | | | '_ \/ __| __/ _\` | | |/ _ \ '__|
      _| |_| | | \__ \ || (_| | | |  __/ |   
     |_____|_| |_|___/\__\__,_|_|_|\___|_|
    _________________________________________
                                By: code-rgb
    "
}

termux_apk () {
    curl -s "https://f-droid.org/api/v1/packages/com.termux" | \
    python3 -c "import sys, json; ver = json.load(sys.stdin)['suggestedVersionCode'] ; print(f'https://f-droid.org/repo/com.termux_{ver}.apk')"
}

termux_update_promt () {
    local url
    local down_path
    echo -e "Note: This script requires latest Termux from F-Droid.\n"
    read -p "  Update Termux ? (y/n)  " -t 15 -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        echo -e "\n  [-] Skipped."
    else
        echo -e "\n  [+] Downloading Latest Termux."
        down_path="storage/termux_latest.apk"
        cd $HOME && curl -o $down_path $(termux_apk)
        echo -e "\nUninstall current version and install manually from $down_path"
        exit 1
    fi
}

echo -e "  Checking Python installation\n"
pkg install -y python curl &> /dev/null
termux_update_promt
pip install -U pip wheel setuptools 1> /dev/null
echo -e "  Installing requirements ..."
CFLAGS="-O0" pip install aiohttp 1> /dev/null
clear
logo
python3 get_apk.py
echo -e "\n\n  Downloading apks."
while read url; do
  echo "  ->  $url"
  curl -sL -O "$url"
done < apk_urls.txt
echo -e "\n  Installing ..."
for package in *.apk; do 
  termux-open $package
  sleep 8
done
echo -e "\n  Done, Success :)"