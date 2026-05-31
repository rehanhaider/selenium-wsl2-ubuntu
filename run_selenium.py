#!/usr/bin/env python3
"""Run a small Selenium/Chrome smoke test on Ubuntu under WSL2."""

from __future__ import annotations

import argparse

from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

DEFAULT_URL = "https://cloudbytes.dev"
DEFAULT_SELECTOR = 'meta[name="description"]'
DEFAULT_TIMEOUT = 15


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Open a page with headless Chrome and print one selected value."
    )
    parser.add_argument(
        "url",
        nargs="?",
        default=DEFAULT_URL,
        help=f"URL to load. Defaults to {DEFAULT_URL}.",
    )
    parser.add_argument(
        "--selector",
        default=DEFAULT_SELECTOR,
        help=f"CSS selector to read. Defaults to {DEFAULT_SELECTOR!r}.",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=DEFAULT_TIMEOUT,
        help=f"Seconds to wait for the selector. Defaults to {DEFAULT_TIMEOUT}.",
    )
    parser.add_argument(
        "--headed",
        action="store_true",
        help="Run Chrome with a visible window instead of headless mode.",
    )
    parser.add_argument(
        "--browser-version",
        help=(
            'Ask Selenium Manager for a browser version or channel, '
            'such as "stable" or "beta".'
        ),
    )
    return parser.parse_args()


def build_chrome_options(args: argparse.Namespace) -> Options:
    options = Options()

    if not args.headed:
        options.add_argument("--headless=new")

    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--window-size=1280,800")

    if args.browser_version:
        options.set_capability("browserVersion", args.browser_version)

    return options


def read_selected_value(driver: webdriver.Chrome, selector: str, timeout: float) -> str:
    element = WebDriverWait(driver, timeout).until(
        EC.presence_of_element_located((By.CSS_SELECTOR, selector))
    )
    return element.get_attribute("content") or element.text or ""


def main() -> int:
    args = parse_args()
    options = build_chrome_options(args)
    driver = webdriver.Chrome(options=options)

    try:
        driver.get(args.url)
        value = read_selected_value(driver, args.selector, args.timeout)
    except TimeoutException as exc:
        raise SystemExit(
            f"Timed out after {args.timeout:g}s waiting for selector: {args.selector}"
        ) from exc
    finally:
        driver.quit()

    print(value)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
