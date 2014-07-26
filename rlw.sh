#!/bin/bash
#
#  Copyright 2013 Jonathan Alfonso <alfonsojon1997@gmail.com>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#
# Changes:
# Jonathan Alfonso <alfonsojon1997@gmail.com>
# 2014-06-30 v 1.3.3 Pretty code is good code.
#
#Oliver Stieber <oliverthered@gmail.com>
#fixed EOF and improved url parsing
#
export RWLVERSION=1.3.3
export WINEPREFIX=$HOME/.local/share/wineprefixes/Roblox
export WINEARCH=win32
echo 'Roblox Linux Wrapper v'$RWLVERSION

spawndialog () {
  zenity \
    --window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
    --title='Roblox Linux Wrapper v'$RWLVERSION \
    --$1 \
    --width=450 \
    --height=120 \
    --text="$2"
}

depcheck () {
  if command -v zenity >/dev/null 2>&1; then
    echo 'Zenity installed, continuing'
  else
    echo 'Please install zenity via your system'\''s package manager.'
    exit 127
  fi
  if command -v wget >/dev/null 2>&1; then
    echo 'wget installed, continuing'
  else
    echo 'Please install wget via your system'\''s package manager.'
    exit 127
  fi
  if command -v wine >/dev/null 2>&1; then
    echo 'Wine installed, continuing'
  else
    spawndialog error 'Please install Wine from www.winehq.org/download'
    xdg-open 'http://www.winehq.org/download'
    exit 127
  fi
  if command -v winetricks >/dev/null 2>&1; then
    echo 'Winetricks installed, continuing'
  else
    echo 'Please install Wine from wiki.winehq.org/winetricks'
    spawndialog error 'Please install Winetricks from wiki.winehq.org/winetricks'
    xdg-open 'http://wiki.winehq.org/winetricks'
  exit 127
  fi
  if [ ! -e $WINEPREFIX ]; then
    spawndialog info 'Required dependencies are going to be installed. \n\nDepending on your internet connection, this may take a few minutes.'
    winetricks -q vcrun2008 winhttp wininet
    wget http://roblox.com/install/setup.ashx -O /tmp/RobloxPlayerLauncher.exe
    wine /tmp/RobloxPlayerLauncher.exe
  fi
}

upgraderoblox () {
  spawndialog info 'Roblox is going to be upgraded \n\nDepending on your internet connection, this may take a few minutes.'
  winetricks -q vcrun2008 winhttp wininet
  wget http://roblox.com/install/setup.ashx -O /tmp/RobloxPlayerLauncher.exe
  wine /tmp/RobloxPlayerLauncher.exe
}

addremoverlw () {
  if [ $1 == install ]; then
    cat < EOF > $HOME/.local/share/applications/Roblox.desktop
    [Desktop Entry]
    Comment=Play Roblox on Linux
    Name=Roblox Linux Wrapper
    Exec=$HOME/.rlw/rlw.sh
    Actions=ROLWiki;
    GenericName=Building Game
    Icon=roblox
    Categories=Game;
    Type=Application
  
    [Desktop Action ROLWiki]
    Name=Roblox on Linux Wiki
    Exec=xdg-open http://roblox.wikia.com/wiki/Roblox_On_Linux
EOF

    mkdir $HOME/.rlw
    wget https://raw.githubusercontent.com/alfonsojon/roblox-linux-wrapper/master/rlw.sh -O $HOME/.rlw/rlw.sh
    wget http://corp.roblox.com/wp-content/uploads/2012/09/ROBLOX-Circle-Logo1.png -O $HOME/.local/share/icons/roblox.png
    chmod +x $HOME/.rlw/rlw.sh
    chmod +x $HOME/.local/share/applications/Roblox.desktop
    xdg-desktop-menu install --novendor $HOME/.local/share/applications/Roblox.desktop
    xdg-desktop-menu forceupdate
    if [ -e $HOME/.rlw/rlw.sh ] && [ -e $HOME/.local/share/icons/roblox.png ] && [ -e $HOME/.local/share/applications/Roblox.desktop ]; then
      spawndialog info 'Roblox Linux Wrapper is installed. Browse your system menu, under the Games section if appliciable.'
    else
      spawndialog error 'Roblox Linux Wrapper did not install successfully. Please ensure you are connected to the internet and try again.'
    fi
  fi
  if [ $1 == uninstall ]; then
    xdg-desktop-menu uninstall $HOME/.local/share/applications/Roblox.desktop
    rm -rf $HOME/.rlw
    rm -rf $HOME/.local/share/icons/roblox.png
    xdg-desktop-menu forceupdate
    if [ -e $HOME/.rlw ] || [ -e $HOME/.local/share/icons/roblox.png ]; then
      spawndialog error 'Roblox Linux Wrapper is still installed. Please try uninstalling again.'
    else
      spawndialog info 'Roblox Linux Wrapper has been uninstalled successfully.'
    fi
  fi
}

playerwrapper () {
  export GAMEURL=`\
  zenity \
    --title='Roblox Linux Wrapper v'$RWLVERSION \
    --window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
    --entry \
    --text='Paste the URL for the game here.' \
    --ok-label='Play' \
    --width=450 \
    --height=120`
#this needs to use a regular expression, alternativly (increases dependencies) sed -e 's/.*\(&id=\)\([[:digit:]]*\).*/\2/gi' 
  GAMEID=`echo $GAMEURL | grep -o "&id=[[:digit:]]*" | cut -d "=" -f 2`
  if [ -n "$GAMEID" ]; then
    wine $WINEPREFIX/drive_c/users/`whoami`/Local\ Settings/Application\ Data/RobloxVersions/version-*/RobloxPlayerBeta.exe --id $GAMEID 2>&1 | \
    zenity \
      --window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
      --title='ROBLOX' \
      --text='Starting Roblox Player...' \
      --width=340 \
      --height=120 \
      --progress \
      --pulsate \
      --timeout=5 \
      --no-cancel
  else
    return
  fi
}

studiowrapper () {
  zenity \
    --title='Roblox Linux Wrapper v'$RWLVERSION \
    --window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
    --info \
    --text='Roblox Studio may take up to 90 seconds to load.'
  if [ -e wine $WINEPREFIX/drive_c/users/`whoami`/Local\ Settings/Application\ Data/RobloxVersions/version-*/RobloxStudioBeta.exe ]; then
    wine $WINEPREFIX/drive_c/users/`whoami`/Local\ Settings/Application\ Data/RobloxVersions/version-*/RobloxStudioBeta.exe | \
    gamestart
  else
    wine $WINEPREFIX/drive_c/users/`whoami`/Local\ Settings/Application\ Data/RobloxVersions/RobloxStudioLauncherBeta.exe | \
    zenity \
      --window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
      --title='ROBLOX' \
      --text='Starting Roblox Studio...' \
      --width=340 \
      --height=120 \
      --progress \
      --pulsate \
      --timeout=60 \
      --no-cancel
  fi
}

main () {
  sel=`zenity \
    --title='Roblox Linux Wrapper v'$RWLVERSION \
    --window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
    --width=560 \
    --height=256 \
    --cancel-label='Quit' \
    --list \
    --text 'What would you like to do?' \
    --radiolist \
    --column '' \
    --column 'Options' \
    TRUE 'Play Roblox' \
    FALSE 'Roblox Studio' \
    FALSE 'Log in/Log out' \
    FALSE 'Install Roblox Linux Wrapper (Recommended)' \
    FALSE 'Upgrade Roblox' \
    FALSE 'Reset Roblox to defaults'`
  case $sel in
    'Play Roblox')
      playerwrapper; main;;
    'Roblox Studio')
      studiowrapper; main;;
    'Install Roblox Wrapper (Recommended)')
      if [ -e $HOME/.local/share/applications/Roblox.desktop ]; then
        zenity \
          --window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
          --width=450 \
          --height=120 \
          --title='Roblox Linux Wrapper v'$RWLVERSION \
          --question \
          --text='Roblox Linux Wrapper is already installed. Would you like to uninstall it?'
        if [ $? == 0 ]; then
          addremoverlw uninstall; main
        else
          main;
        fi
      else
        addremoverlw install; main
      fi;;
    'Upgrade Roblox')		
      upgraderoblox; main;;		
    'Log in/Log out')
      zenity \
        --title='Roblox Linux Wrapper v'$RWLVERSION \
        --window-icon=$WINEPREFIX/ROBLOX-Circle-Logo1.png \
        --width=450 \
        --height=120 \
        --info \
        --text='Roblox Studio will now open. Log in through the studio\nand close it once logged in.'
      studiowrapper; main;;
    'Reset Roblox to defaults')
      rm -rf $WINEPREFIX;
      depcheck; main;;
  esac
}

# Run dependency check & launch main function
depcheck; main
