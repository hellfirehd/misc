#!/bin/bash

#####################################################
# Prerequisites
source /etc/os-release
sudo touch /etc/apt/preferences
sudo install -d -m 0755 /etc/apt/keyrings
sudo apt-get update
sudo apt-get install -y wget apt-transport-https software-properties-common

#####################################################
# Register Package Repos

### Firefox
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla

### Microsoft Signing Key
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg

### Microsoft .NET
wget https://packages.microsoft.com/config/$ID/$VERSION_ID/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
echo '
Package: dotnet* aspnet* netstandard*
Pin: origin "packages.microsoft.com"
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/microsoft

### Microsoft Edge
sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main"

### Microsoft Powershell
wget https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/powershell_7.4.2-1.deb_amd64.deb
sudo dpkg -i powershell_7.4.2-1.deb_amd64.deb
rm powershell_7.4.2-1.deb_amd64.deb

### Microsoft Visual Studio Code
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

### Signal
wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
rm signal-desktop-keyring.gpg
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal-xenial.list

### Zulip
sudo curl -fL -o /etc/apt/trusted.gpg.d/zulip-desktop.asc https://download.zulip.com/desktop/apt/zulip-desktop.asc
echo "deb https://download.zulip.com/desktop/apt stable main" | sudo tee /etc/apt/sources.list.d/zulip-desktop.list

#####################################################
# Postrequisites
sudo apt update

#####################################################
# Install Apps
sudo apt-get install -y code dotnet-sdk-8.0 firefox microsoft-edge-stable signal-desktop zulip
# Resolve missing dependencies and finish the install (if necessary)
sudo apt-get install -f
