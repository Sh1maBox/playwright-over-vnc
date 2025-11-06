from playwright.sync_api import sync_playwright

def run(playwright):
    browser = playwright.chromium.connect("ws://localhost:2222/connect")
    page = browser.new_page()
    page.goto('https://example.com')
    page.screenshot(path='screenshot.png')
    #browser.close()

with sync_playwright() as playwright:
    run(playwright)

