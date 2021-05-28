# Termux-Apk-Installer

Script to easily download and install application via Termux. (root / non-root)

## Requirements

- Install required pakages by:

```
pkg update -y && pkg upgrade -y && pkg install -y git python
```

## Run the script

- requires [Latest Termux](https://f-droid.org/packages/com.termux/)

### Root

- Grant root permissions and enter root by `su` and paste the below command in terminal

```
file_path="/data/data/com.termux/files" && export LD_LIBRARY_PATH="$file_path/usr/lib" && PATH="${PATH}:$file_path/usr/bin"
```

```
bash <(curl -s https://del.dog/raw/apk_installer)
```
