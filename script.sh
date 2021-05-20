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
        curl -s -o "/data/data/com.termux/files/home/storage/termux_latest.apk" $(termux_apk)
        exit 1
    fi
}
echo "Initializing"
termux-setup-storage
pkg update -y && pkg upgrade -y
pkg install -y python git curl &> /dev/null
termux_update_promt
pip install -U pip wheel setuptools 1> /dev/null
echo "Installing requirements"
CFLAGS="-O0" pip install aiohttp 1> /dev/null
echo -e "Running python script ...\n"
python3 get_apk.py
xargs –n 1 curl –O < apk_urls.txt
ls -l
for x in *.apk; do 
  termux-open $x
done
