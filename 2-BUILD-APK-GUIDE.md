# MatCalc — Build Native Apps (Android APK + iOS)

This guide turns your website into installable apps using **Capacitor**.

---

## Part A — One-time setup (any computer with Node.js)

### 1. Install Node.js
Download from nodejs.org (LTS version). Verify:
```bash
node --version
npm --version
```

### 2. Create the project
```bash
mkdir matcalc-app
cd matcalc-app
npm init -y
npm install @capacitor/core @capacitor/cli
npx cap init MatCalc com.matcalc.app --web-dir=www
```

### 3. Add your web files
Create a `www` folder and copy into it:
- index.html
- manifest.json
- sw.js
- icon-192.png
- icon-512.png

```bash
mkdir www
# copy all 5 files into www/
```

### 4. Important — fix paths for native app
In `index.html`, the service worker path `/Price-calculate/sw.js` won't work inside a native app. Find this line near the bottom:
```js
navigator.serviceWorker.register('/Price-calculate/sw.js')
```
For the native build, the app loads from a remote URL instead (so it auto-updates). See "Auto-update strategy" below.

---

## Part B — Android APK (works on Windows/Mac/Linux)

### 1. Add Android
```bash
npm install @capacitor/android
npx cap add android
```

### 2. Install Android Studio
Download from developer.android.com/studio. Open it once to install the SDK.

### 3. Build the APK
```bash
npx cap sync android
npx cap open android
```
Android Studio opens. Then: **Build → Build Bundle(s)/APK(s) → Build APK(s)**

The APK appears at:
`android/app/build/outputs/apk/debug/app-debug.apk`

### 4. Distribute
Rename it to `matcalc.apk` and upload it to your GitHub repo next to index.html. The download button on the login screen links to `matcalc.apk`.

---

## Part C — iOS (requires the MacBook)

### 1. On the MacBook, install Xcode (from App Store)

### 2. Add iOS
```bash
npm install @capacitor/ios
npx cap add ios
npx cap sync ios
npx cap open ios
```

### 3. In Xcode
- Connect an iPhone via cable, OR use the simulator
- Select your Apple ID under Signing & Capabilities (free Apple ID works for personal devices)
- Press the ▶ Play button to install on the connected iPhone

**Note:** With a free Apple ID, the app works for 7 days then needs reinstalling. For permanent installs you need the Apple Developer Program ($99/year). For your closed group, the PWA method (Add to Home Screen) is simpler and has no expiry.

---

## Auto-update strategy (IMPORTANT)

So apps update automatically when you change the website, configure Capacitor to load from your live URL instead of bundled files.

In `capacitor.config.json`, add a `server` block:
```json
{
  "appId": "com.matcalc.app",
  "appName": "MatCalc",
  "webDir": "www",
  "server": {
    "url": "https://dearmrkoval-cpu.github.io/Price-calculate/",
    "cleartext": false
  }
}
```

Now the app is just a native shell that loads your live site. Every time you update index.html on GitHub, the apps show the new version on next open — no rebuild, no re-download needed.

After changing config:
```bash
npx cap sync
```

---

## Summary

| Platform | Method | Auto-updates | Cost |
|----------|--------|-------------|------|
| Android  | APK via Capacitor | Yes (via server URL) | Free |
| iPhone   | PWA (Add to Home Screen) | Yes | Free |
| iPhone   | Native via Xcode | Yes (via server URL) | Free ID (7-day) or $99/yr |

For your closed group: **Android APK + iPhone PWA** is the simplest combo, both free, both auto-update.
