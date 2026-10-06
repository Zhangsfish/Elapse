// Reuse installed Playwright + system Chrome. No package/browser download.
// Local render evidence is NOT proof of a public HTTPS deployment.
const fs = require('node:fs');
const path = require('node:path');
const {pathToFileURL} = require('node:url');
const {chromium} = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const root = path.resolve(__dirname, '../..');
const output = path.join(root, '.build/output/playwright/s03');

(async () => {
  fs.mkdirSync(output, {recursive: true});
  const browser = await chromium.launch({channel: 'chrome', headless: true});
  const records = [];
  try {
    for (const width of [320, 960]) {
      for (const colorScheme of ['light', 'dark']) {
        const context = await browser.newContext({viewport: {width, height: 900}, colorScheme});
        const page = await context.newPage();
        const externalRequests = [];
        const errors = [];
        page.on('request', r => {if (/^https?:/.test(r.url())) externalRequests.push(r.url());});
        page.on('pageerror', e => errors.push(e.message));
        for (const name of ['index', 'privacy']) {
          await page.goto(pathToFileURL(path.join(root, 'public-pages', name + '.html')).href);
          const layout = await page.evaluate(() => ({
            viewport: window.innerWidth,
            documentWidth: document.documentElement.scrollWidth,
            languages: [...document.querySelectorAll('[lang]')].map(e => e.lang),
            stylesheetLoaded: getComputedStyle(document.body).fontSize === '17px',
            contact: document.querySelector('a[href="mailto:zhangs.taq@gmail.com"]')?.textContent,
            cookie: document.cookie,
          }));
          if (layout.documentWidth > layout.viewport || !layout.stylesheetLoaded ||
              layout.contact !== 'zhangs.taq@gmail.com' || layout.cookie || errors.length || externalRequests.length) {
            throw Error('Local page validation failed: ' + JSON.stringify({name, width, layout, errors, externalRequests}));
          }
          await page.keyboard.press('Tab');
          const focused = await page.locator(':focus').evaluate(e => ({tag: e.tagName, outline: getComputedStyle(e).outlineWidth}));
          if (focused.tag !== 'A' || focused.outline !== '3px') throw Error('Missing visible keyboard focus');
          const file = `${name}-${width}-${colorScheme}.png`;
          await page.screenshot({path: path.join(output, file), fullPage: true});
          records.push({file, name, width, colorScheme, layout, keyboardFocus: 'PASS', externalRequests: 0});
        }
        await page.goto(pathToFileURL(path.join(root, 'public-pages/index.html')).href);
        await page.locator('nav a[href="privacy.html"]').click();
        if (!page.url().endsWith('/privacy.html')) throw Error('Privacy navigation failed');
        await context.close();
      }
    }
    const result = {status: 'PASS', browser: browser.version(), source: 'local file URLs only',
                    publicHTTPS: 'NOT_RUN_NOT_LIVE', records};
    fs.writeFileSync(path.join(output, 'RESULTS.json'), JSON.stringify(result, null, 2) + '\n');
    console.log(JSON.stringify(result, null, 2));
  } finally {await browser.close();}
})().catch(error => {console.error(error); process.exitCode = 1;});
