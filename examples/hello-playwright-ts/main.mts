import { chromium } from "playwright-core"

console.log("Start")

const browser = await chromium.connect("ws://localhost:2222/connect")

const context = await browser.newContext({
  baseURL: "https://blog.sh1ma.dev",
})

const page = await context.newPage()

await page.goto("/")
console.log(await page.title())

await page.waitForTimeout(2000)

// clean up
await browser.close()
await context.close()
