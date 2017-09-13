#!/bin/bash

STORAGE_DEVICE="0722968d-9bbb-4f95-a6cb-db03579feea2"
BACKUP_PATH="/media/$(whoami)/$STORAGE_DEVICE/roms"
BACKUP_PATH_META="/media/$(whoami)/$STORAGE_DEVICE/emulationstation"
LINE_BREAK="+----------------------------------------------------------------+"
clear
echo -e "$LINE_BREAK\n-- $(basename $0) options: import, export --\n$LINE_BREAK"

if [ -f $(dirname $0)/repos ];then

  for repo in $(cat $(dirname $0)/repos)
  do
    echo -e "Adding PPA: $repo\n$LINE_BREAK"
    sudo add-apt-repository "ppa:$repo" -y >/dev/null 2>&1
  done
fi

echo -e "Updating apt cache\n$LINE_BREAK"
sudo apt-get update >/dev/null 2>&1

if [ -f $(dirname $0)/packages ];then

  for package in $(cat $(dirname $0)/packages)
  do
    echo -e "Installing package: $package\n$LINE_BREAK"
    sudo apt-get install $package -y >/dev/null 2>&1
  done
fi

echo -e "Upgrading all packages\n$LINE_BREAK"
sudo apt-get upgrade -y >/dev/null 2>&1

if [ -f ~/.emulationstation/es_systems.cfg ] && [ -f $(dirname $0)/emulationstation/es_systems.cfg ] && [ ! -z $1 ] && [ $1 == "import" ];then

  echo -e "Updating emulationstation config files\n$LINE_BREAK"
  cp $(dirname $0)/emulationstation/* ~/.emulationstation/ >/dev/null 2>&1

  echo -e "Updating retroarch config files\n$LINE_BREAK"
  cp $(dirname $0)/retroarch/* ~/.config/retroarch/ >/dev/null 2>&1
  mkdir -p ~/.config/retroarch/ >/dev/null 2>&1

  echo -e "Updating dolphin config files\n$LINE_BREAK"
  mkdir -p ~/.dolphin-emu/Config/ >/dev/null 2>&1
  cp $(dirname $0)/dolphin/* ~/.dolphin-emu/Config/ >/dev/null 2>&1
fi

mkdir ~/roms >/dev/null 2>&1

if [ -z $1 ];then

exit 1


elif [ $1 == "import" ] && [ -d $BACKUP_PATH ];then

  echo -e "Importing ROMS from device: $STORAGE_DEVICE\n$LINE_BREAK"
  sudo rsync -av $BACKUP_PATH/* ~/roms/ >/dev/null 2>&1
  sudo chown -Rv $(whoami):$(whoami) ~/roms >/dev/null 2>&1

  if [ -d $BACKUP_PATH_META ];then

    echo -e "Importing DATA from device: $STORAGE_DEVICE\n$LINE_BREAK"
    sudo rsync -av $BACKUP_PATH_META/themes ~/.emulationstation/ >/dev/null 2>&1
    sudo rsync -av $BACKUP_PATH_META/downloaded_images ~/.emulationstation/ >/dev/null 2>&1
    sudo rsync -av $BACKUP_PATH_META/gamelists ~/.emulationstation/ >/dev/null 2>&1

  else

    echo -e "Data dir missing: $BACKUP_PATH_META\n$LINE_BREAK"
  fi

  for core in $(ls $(dirname $0)/cores)
  do
    echo -e "Installing core: $core\n$LINE_BREAK"
    sudo cp $(dirname $0)/cores/$core /usr/lib/libretro/ >/dev/null 2>&1
  done


elif [ $1 == "export" ] && [ -d $BACKUP_PATH ];then

  echo -e "Exporting ROMS to device: $STORAGE_DEVICE\n$LINE_BREAK"
  sudo rsync -av ~/roms/* $BACKUP_PATH >/dev/null 2>&1

  if [ -d $BACKUP_PATH_META ];then

    echo -e "Exporting DATA to device: $STORAGE_DEVICE\n$LINE_BREAK"
    sudo rsync -av ~/.emulationstation/themes $BACKUP_PATH_META/ >/dev/null 2>&1
    sudo rsync -av ~/.emulationstation/downloaded_images $BACKUP_PATH_META/ >/dev/null 2>&1
    sudo rsync -av ~/.emulationstation/gamelists $BACKUP_PATH_META/ >/dev/null 2>&1

  echo -e "Exporting emulationstation config files\n$LINE_BREAK"
  cp ~/.emulationstation/*.cfg $(dirname $0)/emulationstation/ >/dev/null 2>&1

  echo -e "Exporting retroarch config files\n$LINE_BREAK"
  cp ~/.config/retroarch/*.cfg $(dirname $0)/retroarch/ >/dev/null 2>&1

  echo -e "Exporting dolphin config files\n$LINE_BREAK"
  cp ~/.dolphin-emu/Config/*.ini $(dirname $0)/dolphin/ >/dev/null 2>&1

  else

    echo -e "Data dir missing: $BACKUP_PATH_META\n$LINE_BREAK"
  fi

elif [ ! -d $BACKUP_PATH ];then

  echo -e "Backup dir missing: $BACKUP_PATH\n$LINE_BREAK"
fi

sudo chown -Rv $(whoami):$(whoami) ~/.emulationstation >/dev/null 2>&1
