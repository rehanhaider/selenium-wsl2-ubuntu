#!/usr/bin/bash

echo "Changing to home directory..."
pushd "$HOME"

echo "Update the repository and any packages..."
sudo apt update && sudo apt upgrade -y

echo "Install prerequisite packages..."
sudo apt install wget curl unzip -y

echo "Download the latest Chrome .deb file..."
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb

echo "Install Google Chrome..."
sudo dpkg -i google-chrome-stable_current_amd64.deb

echo "Fix dependencies..."
sudo apt --fix-broken install -y

chrome_version=($(google-chrome-stable --version))
echo "Chrome version: ${chrome_version[2]}"

chromedriver_version=$(curl "https://chromedriver.storage.googleapis.com/LATEST_RELEASE")
echo "Chromedriver version: ${chromedriver_version}"
if [ "${chrome_version[2]}" == "$chromedriver_version" ]; then
    echo "Compatible Chromedriver is available..."
    echo "Proceeding with installation..."
else
    echo "Compabible Chromedriver not available...exiting"
    exit 1
fi

echo "Downloading latest Chromedriver..."
curl -Lo chromedriver_linux64.zip "https://chromedriver.storage.googleapis.com/${chromedriver_version}/chromedriver_linux64.zip"

echo "Unzip the binary file and make it executable..."
mkdir -p "chromedriver/stable"
unzip -q "chromedriver_linux64.zip" -d "chromedriver/stable"
chmod +x "chromedriver/stable/chromedriver"

echo "Install Selenium..."
python3 -m pip install selenium

popd