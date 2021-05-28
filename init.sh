#!/usr/bin/env bash

file_path="/data/data/com.termux/files"

if [[ -z "$LD_LIBRARY_PATH" ]] ; then
    echo -e "\n\n  Setting LD_LIBRARY_PATH ..."
    export LD_LIBRARY_PATH="$file_path/usr/lib"
    PATH="${PATH}:$file_path/usr/bin"
fi

echo -e "\n\n  Initializing ..."
cd "$file_path/home"
echo -e "  Cloning termux-apk-installer"
git clone https://github.com/code-rgb/termux-apk-installer.git apk_installer &> /dev/null
cd apk_installer && bash script.sh
echo -e "\n  Removing installed apks"
cd "$file_path/home" && rm -rf apk_installer
echo "  Done."
