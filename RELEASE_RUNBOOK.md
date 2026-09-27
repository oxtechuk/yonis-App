# Younis App — Release Runbook

**Application:** Younis Almurshid (يونس المرشد) / `younis_app`
**Bundle ID (iOS):** `com.younis.younisApp`
**Application ID (Android):** `com.younis.younis_app`
**Production backend:** `https://younis-almurshid.com`
**Privacy policy:** `https://younis-almurshid.com/privacy`
**Delete-account page:** `https://younis-almurshid.com/delete-account`
**CI/CD:** Codemagic (`codemagic.yaml` → workflow `ios-testflight`)
**Version:** 1.0 (`CFBundleShortVersionString` = `$(FLUTTER_BUILD_NAME)`, `CFBundleVersion` = `$(FLUTTER_BUILD_NUMBER)`)

---

## 1. iOS Build via Codemagic (Step 10)

### 1.1 What the workflow does
File: `codemagic.yaml` → `ios-testflight`

- Runner: `mac_mini_m2`, Xcode latest, Flutter stable, CocoaPods default
- Trigger: push to `main` + manual
- Steps:
  1. `keychain initialize`
  2. `app-store-connect fetch-signing-files "com.younis.younisApp" --type IOS_APP_STORE --create`
  3. `keychain add-certificates`
  4. `xcode-project use-profiles`
  5. `flutter pub get`
  6. `flutter test` (fail fast if `main` is broken)
  7. Dynamic build number: `get-latest-app-store-build-number + 1` → `$NEW_BUILD`
  8. `pod install` (fallback: `flutter build ios --config-only` first — no Podfile is committed, this is expected)
  9. `flutter build ipa --release --build-number=$NEW_BUILD --dart-define=APP_ENV=production --export-options-plist=$HOME/export_options.plist`
- Artifacts: `build/ios/ipa/*.ipa`
- Publishing: TestFlight via `auth: integration`, `submit_to_testflight: true`

### 1.2 Required Codemagic dashboard setup (outside repo, one time)
1. Team Settings → Team integrations → Developer Portal → Manage keys: add App Store Connect API key (App Manager role). Save Key ID + Issuer ID.
2. App Settings → Code signing identities:
   - iOS certificates: Generate or Fetch `Apple Distribution` (or let `--create` do it).
   - iOS provisioning profiles: Fetch App Store profile for `com.younis.younisApp`.
3. App Settings → Environment variables → group `app_store_credentials`:
   - `APP_STORE_CONNECT_KEY_IDENTIFIER` (secret)
   - `APP_STORE_CONNECT_ISSUER_ID` (secret)
   - `APP_STORE_CONNECT_PRIVATE_KEY` (secret, full `.p8` contents)
   - `CERTIFICATE_PRIVATE_KEY` (secret, RSA 2048 private key)
4. Apple Developer Portal: register App ID `com.younis.younisApp`.
5. Push `codemagic.yaml` to `main` → build triggers automatically.

### 1.3 iOS project readiness (verified)
- Deployment target 13.0, `ENABLE_BITCODE = NO` — OK
- `Runner.xcscheme` shared, Archive = Release — OK for CI
- `Info.plist` has `NSCameraUsageDescription` + `NSPhotoLibraryUsageDescription` (receipt upload) — OK
- `PrivacyInfo.xcprivacy` (`NSPrivacyTracking=false`, `CA92.1`) — OK
- `flutter analyze`: 0 issues

---

## 2. App Store Connect — Version 1.0 Prepare for Submission

Location: `App Store Connect → Apps → Younis Almurshid → App Store → iOS App → Version 1.0 → Prepare for Submission`.

Fill top-to-bottom. Do NOT click `Add for Review` until a Build is selected and all side tabs have green dots.

### 2.1 Previews and Screenshots (mandatory)
1. Run the app on a real iPhone (or simulator iPhone 15 Pro Max) and capture 3–10 screenshots: Home / Doctors / Doctor details / Booking / Payment receipt upload / Sessions / Profile / Arabic + English.
2. `6.5" Display` slot: upload `1242 x 2688px` or `1284 x 2778px` portrait. Apple reuses them for all iPhone sizes.
3. `iPad`: binary supports iPhone+iPad (`TARGETED_DEVICE_FAMILY = 1,2`). If iPad support is kept, iPad screenshots are mandatory. For v1.0 either upload scaled iPad screenshots in Media Manager or remove iPad support in Xcode later.
4. `App Previews` (video): optional, leave empty.

### 2.2 Promotional Text (170 chars, optional, no review needed)
Shown at top of product page, editable anytime. Arabic example (selector on `Arabic`):

```text
احجز عيادة أو استشارة نفسية أونلاين مع يونس المرشد. أطباء موثوقون، حجز سريع، ودفع محلي سهل.
```

### 2.3 Description (4000 chars, required)
User-facing description. Currently editing the **Arabic** localization — paste this, then add English via the language `+` button:

```text
تطبيق يونس المرشد لحجز المواعيد الطبية والاستشارات النفسية.

- تصفح ملفات الأطباء والتخصصات
- احجز زيارة عيادة أو جلسة أونلاين (شات / صوت / فيديو)
- حدد الموعد المناسب لك وأدر حجوزاتك
- ادفع محلياً عبر ZainCash و SuperPay وارفع صورة الإيصال من الكاميرا أو المعرض
- عربي / English بالكامل
- خصوصية تامة: لا يتم تسجيل أو تخزين الجلسات

حمّل التطبيق واحجز جلستك الأولى اليوم.
الدعم: https://younis-almurshid.com
الخصوصية: https://younis-almurshid.com/privacy
```

### 2.4 Keywords (100 chars, required, comma-separated)

```text
حجز,طبيب,استشارة,نفسي,عيادة,younis,doctor,therapy,clinic,booking
```

### 2.5 Support URL (required) / Marketing URL (optional)
- `Support URL`: `https://younis-almurshid.com` — must be live. Apple rejects dead links.
- `Marketing URL`: leave empty for v1.0.

### 2.6 Version / Copyright
- `Version`: keep `1.0`
- `Copyright`: `2026 Younis Almurshid`

Leave `Routing App Coverage File` empty (not a maps app).

### 2.7 Build (required — blocks submission until set)
1. Build cannot be picked until Codemagic `ios-testflight` uploads an IPA and it finishes `Processing` in `TestFlight`.
2. Return here, click `+` next to Build, select `1.0 (1)` or higher.
3. Export Compliance: `Does it use encryption?` → `Yes, HTTPS only, exempt`. App only uses standard HTTPS to `https://younis-almurshid.com`, no custom encryption.

Leave `Game Center`, `App Clip`, `iMessage App` untouched.

### 2.8 App Review Information (critical for approval)
- `Sign-in required`: CHECKED. App has login.
  - `User name / Password`: create a real test account on the **production** backend and enter it here, e.g. `apple_review@younis-almurshid.com / Test1234!`. Reviewer tests the production URL — do not use staging credentials.
- `Contact Information`: real first/last name, phone with country code, monitored email.
- `Notes` — paste:

```text
Test account provided. App is medical appointment + online psychological consultation booking.

1. Login with test account
2. Browse doctors > Book clinic visit or online session
3. Payment is local wallet transfer (ZainCash/SuperPay) + receipt image upload - no In-App Purchase per Guideline 3.1.3(e) for professional medical services.
4. Account deletion: Profile > Delete Account + web: https://younis-almurshid.com/delete-account
5. No audio/video sessions are recorded or stored. Privacy: https://younis-almurshid.com/privacy
```

- `Attachment`: leave empty unless supplying a payment demo document.

### 2.9 App Store Version Release
For first release select:

```text
Manually release this version
```

So it does not go live automatically before TestFlight verification.

Click `Save` (top-right).

---

## 3. Remaining Tabs Before `Add for Review`

1. `General → App Information`: Category → `Medical`, declare content rights (own/licensed), Age Rating questionnaire.
2. `Pricing and Availability`: Price `Free`, all countries for v1.0.
3. `App Privacy`: declare Name, Phone, Email, Photos (receipt upload) — linked to user, purpose App Functionality. Reference `https://younis-almurshid.com/privacy`.
4. `TestFlight → Internal`: build must show `Ready to Test`.

Once Build is selected + all dots green: `Add for Review` → `Submit to App Review`.

---

## 4. End-to-End Release Checklist (Step 12)
- [ ] `flutter analyze` 0 issues, `flutter test` 80/80 pass
- [ ] Codemagic `ios-testflight` green, IPA in TestFlight `Ready to Test`
- [ ] Install from TestFlight on physical iPhone: login, booking, receipt upload, AR↔EN switch
- [ ] App Store `Version 1.0` shows selected build + green dots everywhere
- [ ] Submit → `Waiting for Review` → `In Review` → approve → manual release
