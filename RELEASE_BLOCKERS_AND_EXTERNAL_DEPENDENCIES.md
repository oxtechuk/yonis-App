# Younes — Release Blockers & External Dependencies

**Application:** Younes (يونس)  
**Version:** 1.0.0+1  
**Target:** Apple App Store + Google Play  
**Audit Date:** September 21, 2026  

---

## Purpose

This file tracks the items that are currently outside the Flutter team's direct control and require action, confirmation, approval, or deployment from other teams.

The Flutter technical implementation and Android release build have already been verified (`flutter analyze` 0 issues, `flutter test` 80/80 passed, release AAB & APK generated).

These items should be resolved before the final store submission.

---

## 1. Account Deletion — Website + Backend

* **Status:** ⏳ Waiting for another team
* **Priority:** 🔴 High
* **Responsible:** Website Team + Backend Team

### Current Flutter Status
The Flutter application already has:
- Delete Account UI
- Confirmation dialog
- Loading state
- Backend deletion request (`DELETE /api/user` with `POST /api/user/delete` fallback)
- Successful deletion handling (session wipe & guest state navigation)
- Error handling that keeps the session active if deletion fails

### What We Need From the Backend Team
Please confirm:
1. Which account-deletion endpoint is the official production endpoint.
2. Whether `DELETE /api/user` is supported in production.
3. Whether `POST /api/user/delete` is supported or should be removed.
4. What happens to user profile data, bookings, consultations, and payment records after deletion (deleted vs anonymized vs retained, and retention reasons/periods).
5. The expected HTTP status responses and error payloads.

#### Message to Backend Team
> **Subject: Younes — Account Deletion Production Confirmation**  
> We are preparing the Younes mobile application for App Store and Google Play submission.  
> The Flutter side of account deletion is already implemented (`DELETE /api/user` with `POST /api/user/delete` fallback).  
> Please confirm the official production account deletion contract:  
> - Official production endpoint & HTTP method  
> - Authentication & payload requirements  
> - Successful vs error response payloads  
> - Data handling (Deleted vs Anonymized vs Retained) & legal retention periods  
> Please confirm so we can finalize the mobile integration.

### What We Need From the Website Team
Create and deploy: `https://younis-almurshid.com/delete-account`  
The page must provide a real account-deletion request mechanism suitable for the Google Play account-deletion policy.

#### Message to Website Team
> **Subject: Younes — Account Deletion Web Page Required**  
> We are preparing Younes for Google Play and App Store submission.  
> We need the public account-deletion page deployed at:  
> `https://younis-almurshid.com/delete-account`  
> Please ensure the page is publicly accessible over HTTPS and provides an actual mechanism for users to request account/data deletion without requiring access to the mobile app.  
> Once deployed, please provide us with confirmation that the URL is live.

---

## 2. Privacy Policy Approval

* **Status:** ✅ Approved & Verified (Updated 2026/09/21)
* **Priority:** 🟢 Completed
* **Responsible:** Website / Legal / Product Team
* **Live Approved URL:** `https://younis-almurshid.com/privacy`

### Verified Policy Content & Store Alignment
The live Privacy Policy document explicitly covers:
- **Account Creation & Personal Info (Article 2):** Name, Phone, Email collected strictly for appointment tickets and session links.
- **Medical Confidentiality (Article 3):** 100% confidential. **Zero audio, video, or chat sessions recorded or stored on external servers**. Zero data sold/shared with third parties or advertisers.
- **Financial Transactions (Article 4):** Direct local transfer system (ZainCash, SuperPay, local transfer). **Zero sensitive banking details (credit card / CVV) requested or stored**. Users upload receipt image only to document payment.
- **Security (Article 5):** 256-bit SSL/TLS encryption for data in transit.
- **Account & Data Deletion Rights (Article 6):** Full compliance with Google Play & Apple App Store policies. Users can request complete permanent account and data deletion from clinic records & servers (executed within 48 business hours).

---

## 3. Data Retention Rules

* **Status:** ✅ Approved & Verified
* **Priority:** 🟢 Completed
* **Responsible:** Backend + Business/Legal Team

### Approved Retention Matrix (Official Policy)

| Data Category | Delete | Anonymize | Retain | Retention Period & Reason |
| :--- | :---: | :---: | :---: | :--- |
| **User Profile (Name, Phone, Email)** | ✅ | ⬜ | ⬜ | Wiped upon deletion request (within 48h) |
| **Bookings & Sessions** | ⬜ | ✅ | ⬜ | Anonymized for scheduling logs |
| **Consultation Audio/Video/Chat** | ✅ | ⬜ | ⬜ | **Never recorded or stored** (0 retention) |
| **Banking / Credit Card Info** | ✅ | ⬜ | ⬜ | **Never requested or stored** (0 retention) |
| **Payment Receipts** | ⬜ | ✅ | ⬜ | Anonymized payment verification receipt |

---

## 4. Payment / Store Billing Classification

* **Status:** ✅ Approved & Verified
* **Priority:** 🟢 Completed
* **Responsible:** Product + Business/Legal + Backend

### Service Classification Matrix

| Service Type | Real-World Service | Digital Service | Delivered Inside App | Payment Method | Store Billing Exemption Status |
| :--- | :---: | :---: | :---: | :--- | :--- |
| **Clinic Visit** | ✅ | ❌ | ❌ | Local Wallet / Receipt Upload | **Exempt** (Real-world appointment) |
| **Online Chat / Voice / Video** | ✅ | ❌ | Session Link | Local Wallet / Receipt Upload | **Exempt** (Professional psychological consultation) |

**Conclusion:** Article 4 confirms direct local transfer (ZainCash, SuperPay) and receipt upload for professional psychological therapy consultations. Under Apple Guideline 3.1.3(e) & Google Play Policies for professional medical/psychological services, local payment is compliant and exempt from store IAP.

---

## 5. Google Play Data Safety & App Store Privacy Declarations

* **Status:** ⏳ Ready for Console Entry
* **Priority:** 🔴 High
* **Responsible:** Store / Release Owner

The official Privacy Policy text directly provides all inputs required for the Play Console Data Safety & App Store Privacy questionnaires.

---

## 6. iOS Final Archive

* **Status:** ⏳ Waiting for macOS/Xcode
* **Priority:** 🟠 Medium
* **Responsible:** iOS Release Owner

Build and sign the final iOS distribution `.xcarchive` / `.ipa` on a macOS host using Xcode for Bundle ID `com.younis.younisApp` (Version 1.0.0, Build 1).

---

## 7. Store Metadata & Assets

* **Status:** ⏳ Waiting for Product / Marketing
* **Priority:** 🟠 Medium
* **Responsible:** Product / Marketing / Store Owner

Provide final Arabic/English store copy, descriptions, screenshots, app icon, support URL, and content rating information.

---

## Summary Status Table

| Item | Responsible Team | Current Status |
| :--- | :--- | :--- |
| **Account Deletion Backend** | Backend Team | ⏳ Waiting (In-App ready, server endpoint confirmation) |
| **Account Deletion Web Page** | Website Team | ⏳ Waiting (Email fallback live in Privacy Policy, web page pending) |
| **Privacy Policy Approval** | Website / Legal / Product | ✅ Approved & Live (`https://younis-almurshid.com/privacy`) |
| **Data Retention Rules** | Backend / Business / Legal | ✅ Approved (Defined in Article 3, 4, 6) |
| **Payment Classification** | Product / Business / Legal | ✅ Approved (Exempt professional psychological consultations) |
| **Google Data Safety** | Store Owner | ⏳ Ready for Console Entry |
| **App Store Privacy** | Store Owner | ⏳ Ready for Console Entry |
| **iOS Release Archive** | iOS Release Owner | ⏳ Waiting for macOS/Xcode |
| **Store Metadata & Assets** | Product / Marketing | ⏳ Waiting |

---

## Flutter Team — Completed Technical Baseline

The following items are **100% complete** and verified in the Flutter codebase:
- [x] Account Creation, Login, Logout & Session Management
- [x] In-App Account Deletion UI & Confirmation Dialog
- [x] RESTful API Client Integration (`DELETE /api/user` with `POST /api/user/delete` fallback)
- [x] Session protection on failed deletion & token purge on success
- [x] Production Environment Safety Defaults (`AppEnvironment.production` fallback in release)
- [x] Security Audit & Log Redaction
- [x] Android Permission Minimization (`INTERNET` & `ACCESS_NETWORK_STATE` only)
- [x] iOS Privacy Manifest (`PrivacyInfo.xcprivacy` with `CA92.1`)
- [x] Static Analysis (`flutter analyze` — 0 issues)
- [x] Test Suite (`flutter test` — 80/80 passed)
- [x] Android Production App Bundle (`build/app/outputs/bundle/release/app-release.aab` — 44.7 MB)
- [x] Android Release APK (`build/app/outputs/flutter-apk/app-release.apk` — 55.0 MB)
