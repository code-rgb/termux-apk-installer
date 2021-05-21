#!/usr/bin/env bash

termux_apk () {
    curl -s "https://f-droid.org/api/v1/packages/com.termux" | \
    python3 -c "import sys, json; ver = json.load(sys.stdin)['suggestedVersionCode'] ; print(f'https://f-droid.org/repo/com.termux_{ver}.apk')"
}

termux_update_promt () {
    local url
    read -p "Note: This script requires latest Termux from F-Droid. Update Termux ? (y/n)  " -t 15 -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        echo -e "\n  Skipping ..."
    else
        echo -e "\nDownloading Latest Apk ..."
        cd $HOME && curl -o "storage/termux_latest.apk" $(termux_apk)
        exit 1
    fi
}

echo -e "\n\nInitializing"
termux-setup-storage
pkg update -y && pkg upgrade -y
echo "Checking Python Installtion"
pkg install -y python git curl &> /dev/null
termux_update_promt
pip install -U pip wheel setuptools 1> /dev/null
echo "Installing requirements"
CFLAGS="-O0" pip install aiohttp 1> /dev/null
echo -e "Running python script ...\n"
python3 get_apk.py
echo "Downloading apks"
while read url; do
  echo "  --> $url"
  curl -sL -O "$url"
done < apk_urls.txt
echo "Installing"
for package in *.apk; do 
  termux-open $package
  sleep 5
done
