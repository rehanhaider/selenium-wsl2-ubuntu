# Selenium on WSL2 Ubuntu

Minimal setup for running Selenium with Chrome from Ubuntu on Windows Subsystem
for Linux 2.

Modern Selenium 4 includes Selenium Manager, which can discover, download, and
cache the browser and driver it needs. This project therefore no longer stores
Chrome or Chromedriver in your home directory or hard-codes their paths in the
Python script.

## Requirements

- Ubuntu on WSL2
- Python 3.10 or newer
- `sudo` access for installing system packages
- Internet access on the first Selenium run so Selenium Manager can populate
  its cache

## Quick Start

Clone the repository:

```bash
git clone https://github.com/rehanhaider/selenium-wsl2-ubuntu.git selenium
cd selenium
```

Install the Ubuntu runtime packages and Python dependencies:

```bash
./install-selenium.sh
```

Activate the virtual environment:

```bash
source .venv/bin/activate
```

Run the smoke test:

```bash
python run_selenium.py
```

By default, the script opens `https://cloudbytes.dev` in headless Chrome and
prints the page's meta description.

## Usage

Open another URL:

```bash
python run_selenium.py https://selenium.dev
```

Read a specific CSS selector:

```bash
python run_selenium.py https://selenium.dev --selector h1
```

Run with a visible browser window:

```bash
python run_selenium.py --headed
```

Ask Selenium Manager for a browser channel or version:

```bash
python run_selenium.py --browser-version stable
python run_selenium.py --browser-version beta
```

## Installer Options

Use a different Python executable:

```bash
PYTHON=python3.12 ./install-selenium.sh
```

Use a different virtual environment directory:

```bash
VENV_DIR="$PWD/.venv-selenium" ./install-selenium.sh
```

Skip `apt` package installation if the runtime packages are already present:

```bash
SKIP_APT=1 ./install-selenium.sh
```

Rebuild the virtual environment from scratch:

```bash
RESET_VENV=1 ./install-selenium.sh
```

## Notes

Selenium Manager caches downloaded browsers and drivers under
`~/.cache/selenium`. If you need to inspect what it is doing, run with Selenium's
manager debug output enabled:

```bash
SE_DEBUG=true python run_selenium.py
```

The original walkthrough for this repository is still available here:
[Run Selenium and Chrome/Chromium on WSL2 using Python and Selenium webdriver](https://cloudbytes.dev/snippets/run-selenium-and-chrome-on-wsl2).
