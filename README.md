# 1. Disable iMac bluetooth keyboard auto-request
Open the Bluetooth pane in System Preferences. Click the Advanced button. Uncheck the boxes marked  
Open Bluetooth Setup Assistant...
Disable the Bluetooth Setup Assistant.

Open System Preferences  
Click Bluetooth  
Click Advanced…  
Uncheck Open Bluetooth Setup Assistant at startup if no keyboard is detected  
Uncheck Open Bluetooth Setup Assistant at startup if no mouse or trackpad is detected  
Click "OK"

# 2. Use Applescript to save to application
```
tell application "System Events" to key code 144 using command down
```

# 3. Use Applescript to add TDM application to Dock
```
my add_item_to_dock(choose file of type {"APPL"} with prompt "Choose an application to add to the Dock:")

on add_item_to_dock(item_path)
   try
       get item_path as alias -- you need a POSIX path so this coerces the path in case it's an HFS path, alias, file ref, etc.        set item_path to POSIX path of item_path
   end try
   try
       tell application "Dock" to quit
   end try
   do shell script "defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>" & item_path & "</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'"
   try
       tell application "Dock" to activate
   end try
end add_item_to_dock
```

# Make Mac OS icon file icns
```
mkdir MyIcon.iconset  
sips -z 16 16     Icon1024.png --out MyIcon.iconset/icon_16x16.png  
sips -z 32 32     Icon1024.png --out MyIcon.iconset/icon_16x16@2x.png  
sips -z 32 32     Icon1024.png --out MyIcon.iconset/icon_32x32.png  
sips -z 64 64     Icon1024.png --out MyIcon.iconset/icon_32x32@2x.png  
sips -z 128 128   Icon1024.png --out MyIcon.iconset/icon_128x128.png  
sips -z 256 256   Icon1024.png --out MyIcon.iconset/icon_128x128@2x.png  
sips -z 256 256   Icon1024.png --out MyIcon.iconset/icon_256x256.png  
sips -z 512 512   Icon1024.png --out MyIcon.iconset/icon_256x256@2x.png  
sips -z 512 512   Icon1024.png --out MyIcon.iconset/icon_512x512.png  
cp Icon1024.png MyIcon.iconset/icon_512x512@2x.png  
iconutil -c icns MyIcon.iconset  
rm -R MyIcon.iconset
```

```
+---------------------+--------------------+--------------+  
|      filename       | resolution, pixels | density, PPI |  
+---------------------+--------------------+--------------+  
| icon_16x16.png      | 16x16              |           72 |  
| icon_16x16@2x.png   | 32x32              |          144 |  
| icon_32x32.png      | 32x32              |           72 |  
| icon_32x32@2x.png   | 64x64              |          144 |  
| icon_128x128.png    | 128x128            |           72 |  
| icon_128x128@2x.png | 256x256            |          144 |  
| icon_256x256.png    | 256x256            |           72 |  
| icon_256x256@2x.png | 512x512            |          144 |  
| icon_512x512.png    | 512x512            |           72 |  
| icon_512x512@2x.png | 1024x1024          |          144 |  
+---------------------+--------------------+--------------+  
```


# tdm-via-ssh
Target Display Mode via SSH

Slightly modified from http://aaronrutley.com/target-display-mode-via-ssh/

## Installation

### iMac:

1. Move all files to ~/tdm/

2.  `brew install blueutil`

3. Set up permissions:
   - System Preferences > Sharing > Remote Login ☑
   - You will also need to give some apps accessibility access (Security & Privacy > Privacy > Accessibility). Can add it after you run the code.

### MacBook:

* create alias (by pasting into ~/.bash_profile)

  - username: the user you're logging into iMac
  - hostname: the iMac's name (run `hostname` in iMac's terminal to get it)
  - after adding the below code, `source ~/.bash_profile` to take effect

  ```bash
  # imac target display mode function
  alias imac='function _imac(){
  	if [ $1 = "start" ]; then
  		echo "--- MacBook Bluetooth on...";
  	    blueutil -p 1;	
  		sleep 1;
  		echo "--- Connecting to iMac via ssh...";
  		ssh -2 -p 22 username@hostname.local sh ~/tdm/start.sh;
  	fi
  	if [ $1 = "end" ]; then
  		echo "--- MacBook Bluetooth off...";
  		blueutil -p 0;
  		sleep 1;
  		echo "--- Connecting to iMac via ssh...";
  		ssh -2 -p 22 username@hostname.local sh ~/tdm/end.sh;
  	fi
  	if [ $1 = "shutdown" ]; then
  		echo "--- MacBook Bluetooth off...";
  		blueutil -p 0;
  		echo "--- Shutting down remote imac.....";
  		ssh -2 -p 22 username@hostname.local sh ~/tdm/shutdown.sh;
  	fi
  	if [ $1 = "ssh" ]; then
  		echo "--- Connecting via ssh.....";
  		ssh username@hostname.local;
  	fi
  };_imac'
  ```

* SSH into iMac without password:

  - Snippet from: [https://danielpataki.com/target-display-mode-remotely/ (archived)](https://web.archive.org/web/20180815120109/https://danielpataki.com/target-display-mode-remotely/)

  ```bash
  # when you issue the following command you'll be asked some questions, keep hitting enter until done.
  ssh-keygen
  scp ~/.ssh/id_rsa.pub username@hostname.local:~/
  ssh username@hostname.local
  mkdir .ssh # skip this if you already have the folder
  cat id_rsa.pub >> ~/.ssh/authorized_keys
  rm -f id_rsa.pub
  exit
  ```

## Usage

`imac start`: start TDM

`imac end`: end TDM

`imac shutdown`

`imac ssh`: ssh into iMac


https://medium.com/@gutofoletto/how-to-share-your-imac-keyboard-on-target-display-mode-abfaf10a7992
```
#!/usr/bin/env bash
# Disable BT on remote machine and enable it on local machine, so KB/Mouse reconnect to local machine.  
#ensure local bluetooth is off  
blueutil off  
#disable imac bluetooth  
ssh user@imac.local '/usr/local/bin/blueutil off'  
#enable local bluetooth  
blueutil on  
```

```
#!/usr/bin/env bash  
# Disable BT on local machine and enable it on remote machine, so KB/Mouse reconnect to remote machine.  
#ensure local bluetooth is off  
blueutil off  
#enable imac bluetooth  
ssh user@imac.local '/usr/local/bin/blueutil on'  
```
