# Install Selenium & Chrome in WSL Ubuntu

This script can be used to install Chrome, Chromedriver, and Selenium in Ubuntu on Windows Subsystem for Linux (WSL2).

Detailed step by step explanation is available in this article on how to [Run Selenium and Chrome/Chromium on WSL2 using Python and Selenium webdriver](https://cloudbytes.dev/snippets/run-selenium-and-chrome-on-wsl2)

# Using the repository

Clone the repository

```bash
git clone https://github.com/rehanhaider/selenium-wsl2-ubuntu.git selenium && cd selenium
```

Update system packages

```bash
sudo apt update && sudo apt upgrade -y
```

Install Chrome & Chromedriver

```bash
./install-selenium.sh
```

A virtual environment is automatically created and recommended.

```bash
source .env/bin/activate
```

Install packages through requirements.txt

```bash
pip install -r requirements.txt
```

Run a python program (I can't believe I have to mention this)

```bash
python3 run_selenium.py
```
