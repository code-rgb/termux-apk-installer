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
    v0.2                         By: code-rgb
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

install_non_root () {
   termux-open $1
   sleep 8
}

install_root () {
    pm install $1 &> /dev/null
}

echo -e "  Checking Python installation\n"
pkg install -y python curl &> /dev/null
termux_update_promt
pip install -U pip wheel setuptools 1> /dev/null
echo "  Installing requirements ..."
CFLAGS="-O0" pip install aiohttp beautifulsoup4 1> /dev/null
clear
logo
python3 get_apk.py

# Check if python program failed 
if ! [[ -f "apk_urls.txt" ]]; then
    echo -e "  [!] Failed to fetch apks.\n\n  Exiting."
    exit 1
fi

echo -e "\n  Downloading apks (Please wait) ..."
while ((i++)); read url
do
  echo "   $i) $(basename $url)"
  curl -sL -O "$url"
done < apk_urls.txt

# Check root permissions
if [ $HOME == "/" ] ; then
    install_apk=install_root
    echo -e "\n  Installing apps (root method) ..."
else
    install_apk=install_non_root
    echo -e "\n  Installing apps (non-root method) ..."
fi

for package in *.apk; do 
  $install_apk $package
done

echo "  Done, Success :)"
