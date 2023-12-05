#!/usr/bin/bash

echo "Changing to home directory..."
pushd "$HOME"

echo "Update the repository and any packages..."
sudo apt update && sudo apt upgrade -y

echo "Install prerequisite system packages..."
sudo apt install wget curl unzip jq -y

# Set metadata for Google Chrome repository...
meta_data=$(curl 'https://googlechromelabs.github.io/chrome-for-testing/'\
'last-known-good-versions-with-downloads.json')


echo "Download the latest Chrome binary..."
wget $(echo "$meta_data" | jq -r '.channels.Stable.downloads.chrome[0].url')

echo "Install Chrome dependencies..."
sudo apt install ca-certificates fonts-liberation \
    libappindicator3-1 libasound2 libatk-bridge2.0-0 libatk1.0-0 libc6 \
    libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 \
    libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 \
    libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \
    libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 \
    libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils -y


echo "Unzip the binary file..."
unzip chrome-linux64.zip


echo "Downloading latest Chromedriver..."
wget $(echo "$meta_data" | jq -r '.channels.Stable.downloads.chromedriver[0].url')

echo "Unzip the binary file and make it executable..."
unzip chromedriver-linux64.zip

echo "Install Selenium..."
python3 -m pip install selenium

echo "Removing archive files"
rm chrome-linux64.zip  chromedriver-linux64.zip

popd