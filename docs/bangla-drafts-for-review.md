# Bangla drafts for the client's review

**From:** the mobile app team. **Date:** 2026-11-19 (replaces the list of 2026-11-17, which is included). **Status:** drafts, to be read and corrected by a Bangla reader chosen by Ziska (client question B5; final.md Section 20.3).

The app has 327 texts. **226** of them were drafted on 2026-11-19 so that the language switch could ship; the other 101 were written earlier, with the screens they belong to, and are listed at the end. Both lists are part of the review; every text is in `lib/l10n/app_bn.arb`.

## How to review

- Mark each row ✅ (keep), or write the corrected text in the last column.
- Keep everything in `{curly brackets}` exactly as it is: the app puts a value there (an email, a number, a date). A test fails if one is lost.
- `{count, plural, …}` texts choose a form by the number; correct the words inside each form only.
- Product names, codes, references, emails, and "Track & Trace" stay in Latin letters on purpose.
- "Check" in the app means checking that a product is genuine; the drafts use **যাচাই** for it throughout. The app never says "verify" (no ভেরিফাই or যাচাইকরণ).
- Times and dates are written by the phone's Bangla calendar data (Bangla digits and month names); they are not in this list.

## The drafts

| # | Key | English | Bangla draft | Review |
|---|---|---|---|---|
| 1 | `appSubtitle` | Product Authenticity Check | পণ্যের সত্যতা যাচাই | |
| 2 | `splashTagline` | Check genuine products instantly | আসল পণ্য মুহূর্তেই যাচাই করুন | |
| 3 | `brandTagline` | TRACK · TRACE · CHECK | TRACK · TRACE · CHECK | |
| 4 | `loginTitle` | Login to Track & Trace | Track & Trace-এ লগইন করুন | |
| 5 | `loginSubtitle` | Enter your email and password to check products. | পণ্য যাচাই করতে আপনার ইমেইল ও পাসওয়ার্ড দিন। | |
| 6 | `emailLabel` | Email | ইমেইল | |
| 7 | `emailHint` | name@example.com | name@example.com | |
| 8 | `passwordLabel` | Password | পাসওয়ার্ড | |
| 9 | `showPassword` | Show password | পাসওয়ার্ড দেখুন | |
| 10 | `hidePassword` | Hide password | পাসওয়ার্ড লুকান | |
| 11 | `forgotPassword` | Forgot password? | পাসওয়ার্ড ভুলে গেছেন? | |
| 12 | `loginButton` | Login securely | নিরাপদে লগইন করুন | |
| 13 | `noAccountDivider` | NO ACCOUNT? | অ্যাকাউন্ট নেই? | |
| 14 | `noAccountQuestion` | Don't have an account? | আপনার কি অ্যাকাউন্ট নেই? | |
| 15 | `authorizedOnly` | Only authorized users can access this system | শুধু অনুমোদিত ব্যবহারকারীরা এই সিস্টেম ব্যবহার করতে পারবেন | |
| 16 | `loginFailed` | Email or password is incorrect. | ইমেইল বা পাসওয়ার্ড সঠিক নয়। | |
| 17 | `fieldRequired` | Required | আবশ্যক | |
| 18 | `emailInvalid` | Enter a valid email address | একটি সঠিক ইমেইল ঠিকানা দিন | |
| 19 | `verifyCodeTitle` | Check your email | আপনার ইমেইল দেখুন | |
| 20 | `verifyCodeSubtitle` | We sent a 6-digit code to {email}. Enter it to trust this phone. | {email}-এ একটি ৬ অঙ্কের কোড পাঠানো হয়েছে। এই ফোনটিকে বিশ্বস্ত করতে কোডটি দিন। | |
| 21 | `codeLabel` | Code from the email | ইমেইলের কোড | |
| 22 | `verifyButton` | Continue | চালিয়ে যান | |
| 23 | `codeWrong` | The code is wrong or has expired. Check the latest email, or send the code again. | কোডটি ভুল বা মেয়াদোত্তীর্ণ। সর্বশেষ ইমেইলটি দেখুন, অথবা আবার কোড পাঠান। | |
| 24 | `resendCode` | Send the code again | আবার কোড পাঠান | |
| 25 | `resendIn` | Send again in {seconds} s | {seconds} সেকেন্ড পরে আবার পাঠান | |
| 26 | `codeResent` | A new code was sent. | একটি নতুন কোড পাঠানো হয়েছে। | |
| 27 | `resendLimitReached` | No more codes can be sent. Log in again. | আর কোনো কোড পাঠানো যাবে না। আবার লগইন করুন। | |
| 28 | `backToLogin` | Back to login | লগইনে ফিরে যান | |
| 29 | `changePasswordTitle` | Set a new password | নতুন পাসওয়ার্ড দিন | |
| 30 | `changePasswordForcedSubtitle` | Your password was set by someone else. Choose your own password to continue. | আপনার পাসওয়ার্ড অন্য কেউ সেট করেছে। চালিয়ে যেতে নিজের পাসওয়ার্ড বেছে নিন। | |
| 31 | `changePasswordSubtitle` | Choose a new password. Your other phones will be logged out. | একটি নতুন পাসওয়ার্ড বেছে নিন। আপনার অন্যান্য ফোন থেকে লগআউট হয়ে যাবে। | |
| 32 | `currentPasswordLabel` | Current password | বর্তমান পাসওয়ার্ড | |
| 33 | `newPasswordLabel` | New password | নতুন পাসওয়ার্ড | |
| 34 | `confirmPasswordLabel` | Repeat new password | নতুন পাসওয়ার্ড আবার দিন | |
| 35 | `passwordsDoNotMatch` | The passwords do not match | পাসওয়ার্ড দুটি মেলেনি | |
| 36 | `changePasswordButton` | Save password | পাসওয়ার্ড সংরক্ষণ করুন | |
| 37 | `currentPasswordWrong` | The current password is incorrect. | বর্তমান পাসওয়ার্ড সঠিক নয়। | |
| 38 | `passwordChanged` | Your password was changed. | আপনার পাসওয়ার্ড বদলানো হয়েছে। | |
| 39 | `logout` | Log out | লগআউট | |
| 40 | `ruleLength` | 8 characters or more | ৮ বা তার বেশি অক্ষর | |
| 41 | `ruleLetter` | a letter | একটি বর্ণ | |
| 42 | `ruleNumber` | a number | একটি সংখ্যা | |
| 43 | `passwordRuleBroken` | The password does not meet the rules below. | পাসওয়ার্ডটি নিচের নিয়ম মানছে না। | |
| 44 | `forgotTitle` | Forgot password | পাসওয়ার্ড ভুলে গেছেন | |
| 45 | `forgotSubtitle` | Enter your email. If it has an account, we will send a 6-digit code. | আপনার ইমেইল দিন। এর কোনো অ্যাকাউন্ট থাকলে আমরা একটি ৬ অঙ্কের কোড পাঠাব। | |
| 46 | `sendCodeButton` | Send code | কোড পাঠান | |
| 47 | `forgotSent` | If the address has an account, a code was sent. | ঠিকানাটির অ্যাকাউন্ট থাকলে একটি কোড পাঠানো হয়েছে। | |
| 48 | `resetTitle` | Reset password | পাসওয়ার্ড রিসেট | |
| 49 | `resetSubtitle` | If {email} has an account, a code was sent to it. Enter the code and choose a new password. | {email}-এর অ্যাকাউন্ট থাকলে সেখানে একটি কোড পাঠানো হয়েছে। কোডটি দিন এবং নতুন পাসওয়ার্ড বেছে নিন। | |
| 50 | `resetButton` | Reset password | পাসওয়ার্ড রিসেট করুন | |
| 51 | `resetDone` | Password changed. Log in with your new password; every phone needs the emailed code at its next login. | পাসওয়ার্ড বদলানো হয়েছে। নতুন পাসওয়ার্ড দিয়ে লগইন করুন; পরের লগইনে প্রতিটি ফোনে ইমেইলের কোড লাগবে। | |
| 52 | `noPhoneApp` | No phone app found. Call {phone}. | কোনো ফোন অ্যাপ পাওয়া যায়নি। {phone} নম্বরে কল করুন। | |
| 53 | `noMailApp` | No email app found. Write to {email}. | কোনো ইমেইল অ্যাপ পাওয়া যায়নি। {email}-এ লিখুন। | |
| 54 | `welcomeBack` | Welcome back, | আবার স্বাগতম, | |
| 55 | `loadingProfile` | Loading your profile… | আপনার প্রোফাইল লোড হচ্ছে… | |
| 56 | `retry` | Try again | আবার চেষ্টা করুন | |
| 57 | `errorNetwork` | No connection. Check the internet and try again. | সংযোগ নেই। ইন্টারনেট দেখে আবার চেষ্টা করুন। | |
| 58 | `errorRateLimited` | Too many attempts. Try again in {seconds} s. | অনেকবার চেষ্টা করা হয়েছে। {seconds} সেকেন্ড পরে আবার চেষ্টা করুন। | |
| 59 | `errorPreparing` | The app is being prepared. Try again later. | অ্যাপটি প্রস্তুত হচ্ছে। পরে আবার চেষ্টা করুন। | |
| 60 | `errorUnavailable` | The service is busy. Try again shortly. | সেবাটি ব্যস্ত। একটু পরে আবার চেষ্টা করুন। | |
| 61 | `errorNotAvailable` | Not available. | পাওয়া যাচ্ছে না। | |
| 62 | `errorGeneral` | Something went wrong. Try again. | কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন। | |
| 63 | `reference` | Reference: {id} | রেফারেন্স: {id} | |
| 64 | `tabVerify` | Check | যাচাই | |
| 65 | `tabHistory` | History | ইতিহাস | |
| 66 | `tabProfile` | Profile | প্রোফাইল | |
| 67 | `noFeaturesTitle` | No features yet | এখনো কোনো সুবিধা নেই | |
| 68 | `noFeaturesBody` | Your role does not allow any features yet. Contact your office. | আপনার ভূমিকায় এখনো কোনো সুবিধা দেওয়া হয়নি। আপনার অফিসে যোগাযোগ করুন। | |
| 69 | `profileTitle` | Profile | প্রোফাইল | |
| 70 | `organisationLabel` | Organization | প্রতিষ্ঠান | |
| 71 | `roleLabel` | Role | ভূমিকা | |
| 72 | `accountSection` | ACCOUNT | অ্যাকাউন্ট | |
| 73 | `statChecks` | Checks | যাচাই | |
| 74 | `statValid` | Valid | আসল | |
| 75 | `statsFailed` | Your counts couldn't load. | আপনার হিসাব লোড করা যায়নি। | |
| 76 | `changePasswordRow` | Change password | পাসওয়ার্ড বদলান | |
| 77 | `languageRow` | Language | ভাষা | |
| 78 | `languageTitle` | App language | অ্যাপের ভাষা | |
| 79 | `supportContactRow` | Support contact | সহায়তার যোগাযোগ | |
| 80 | `appVersionRow` | App version | অ্যাপ সংস্করণ | |
| 81 | `appVersionValue` | v{version} · build {build} | v{version} · বিল্ড {build} | |
| 82 | `logoutConfirmTitle` | Log out? | লগআউট করবেন? | |
| 83 | `logoutConfirmBody` | This phone stays trusted, so the next login needs no emailed code. | এই ফোনটি বিশ্বস্ত থাকবে, তাই পরের লগইনে ইমেইলের কোড লাগবে না। | |
| 84 | `cancel` | Cancel | বাতিল | |
| 85 | `verifyItemTitle` | Check authenticity | সত্যতা যাচাই করুন | |
| 86 | `waySerial` | Serial | সিরিয়াল | |
| 87 | `wayHiddenCode` | Hidden code | গোপন কোড | |
| 88 | `wayQr` | QR code | QR কোড | |
| 89 | `serialHint` | Up to {digits} digits | সর্বোচ্চ {digits} অঙ্ক | |
| 90 | `verifyButtonLookup` | Check | যাচাই | |
| 91 | `clear` | Clear | মুছুন | |
| 92 | `scanFrameHint` | Place the QR code inside the frame | QR কোডটি ফ্রেমের ভেতরে রাখুন | |
| 93 | `scanLooking` | Looking for a QR code · hold steady | QR কোড খোঁজা হচ্ছে · স্থির রাখুন | |
| 94 | `inputEmpty` | Enter a value first | আগে একটি মান দিন | |
| 95 | `inputWrongSerial` | A serial has digits only, up to {digits} digits. | সিরিয়ালে শুধু অঙ্ক থাকে, সর্বোচ্চ {digits}টি। | |
| 96 | `notProductQr` | This QR code is not a product code of this company. | এই QR কোডটি এই কোম্পানির কোনো পণ্যের কোড নয়। | |
| 97 | `formatsFailed` | Could not load the code formats. | কোডের ফরম্যাট লোড করা যায়নি। | |
| 98 | `lookupNetworkError` | Unable to check. Check the connection and try again. | যাচাই করা যায়নি। সংযোগ দেখে আবার চেষ্টা করুন। | |
| 99 | `verifying` | Checking… | যাচাই হচ্ছে… | |
| 100 | `toolsTitle` | MORE | আরও | |
| 101 | `toolReport` | Report incident | ঘটনা রিপোর্ট করুন | |
| 102 | `toolMyReports` | My reports | আমার রিপোর্ট | |
| 103 | `scannerPermissionDenied` | Camera access is off. Allow it in Settings to scan QR codes. | ক্যামেরার অনুমতি বন্ধ। QR কোড স্ক্যান করতে সেটিংসে অনুমতি দিন। | |
| 104 | `scannerUnsupported` | This phone cannot scan QR codes. Type the serial instead. | এই ফোনে QR কোড স্ক্যান করা যায় না। এর বদলে সিরিয়াল লিখুন। | |
| 105 | `scannerFailed` | The camera could not start. | ক্যামেরা চালু করা যায়নি। | |
| 106 | `openSettings` | Open settings | সেটিংস খুলুন | |
| 107 | `torch` | Torch | টর্চ | |
| 108 | `resultTitle` | Check result | যাচাইয়ের ফল | |
| 109 | `resultValidTitle` | Genuine product | আসল পণ্য | |
| 110 | `resultValidBody` | First check by any official. Nothing is wrong with this item. | কোনো কর্মকর্তার প্রথম যাচাই। এই পণ্যে কোনো সমস্যা নেই। | |
| 111 | `resultWarningTitle` | Genuine, needs attention | আসল, তবে মনোযোগ দরকার | |
| 112 | `resultWarningBody` | Read every reason below. | নিচের প্রতিটি কারণ পড়ুন। | |
| 113 | `resultNotFoundTitle` | Not found | পাওয়া যায়নি | |
| 114 | `resultNotFoundBody` | No product of this company has this serial or QR code. | এই সিরিয়াল বা QR কোডের কোনো পণ্য এই কোম্পানির নেই। | |
| 115 | `resultUnassignedTitle` | Not in a batch | কোনো ব্যাচে নেই | |
| 116 | `resultUnassignedBody` | This item exists but has not been given to a batch yet. | পণ্যটি আছে, তবে এখনো কোনো ব্যাচে দেওয়া হয়নি। | |
| 117 | `resultUnknownTitle` | Unable to check | যাচাই করা যায়নি | |
| 118 | `resultUnknownBody` | This result is not known to this app version. Update the app or contact your office. | এই ফলাফল এই অ্যাপ সংস্করণে জানা নেই। অ্যাপ হালনাগাদ করুন বা আপনার অফিসে যোগাযোগ করুন। | |
| 119 | `reasonCheckedBefore` | Checked before | আগে যাচাই হয়েছে | |
| 120 | `reasonCheckedBeforeDetail` | This is check number {count} of this item. Last check: {when}. | এটি এই পণ্যের {count} নম্বর যাচাই। শেষ যাচাই: {when}। | |
| 121 | `reasonRecalled` | Batch recalled | ব্যাচ প্রত্যাহার করা হয়েছে | |
| 122 | `reasonExpired` | Expired | মেয়াদোত্তীর্ণ | |
| 123 | `reasonDamaged` | Marked damaged | ক্ষতিগ্রস্ত হিসেবে চিহ্নিত | |
| 124 | `reasonSwitchedOff` | Batch switched off | ব্যাচ বন্ধ করা হয়েছে | |
| 125 | `reasonUnknown` | Needs attention | মনোযোগ দরকার | |
| 126 | `referenceNumber` | Reference number | রেফারেন্স নম্বর | |
| 127 | `productLabel` | Product | পণ্য | |
| 128 | `genericLabel` | Generic name | জেনেরিক নাম | |
| 129 | `shortNameLabel` | Short name | সংক্ষিপ্ত নাম | |
| 130 | `serialLabel` | Serial | সিরিয়াল | |
| 131 | `codeLabel2` | Hidden code | গোপন কোড | |
| 132 | `batchLabel` | Batch | ব্যাচ | |
| 133 | `madeLabel` | Made | তৈরি | |
| 134 | `expiresLabel` | Expires | মেয়াদ শেষ | |
| 135 | `verifyAnother` | Check another item | আরেকটি পণ্য যাচাই করুন | |
| 136 | `copied` | Copied | কপি হয়েছে | |
| 137 | `copyReference` | Copy reference number | রেফারেন্স নম্বর কপি করুন | |
| 138 | `bulkValid` | Valid | আসল | |
| 139 | `bulkWarning` | Warning | সতর্কতা | |
| 140 | `bulkNotFound` | Not found | পাওয়া যায়নি | |
| 141 | `bulkUnassigned` | Not in a batch | কোনো ব্যাচে নেই | |
| 142 | `removeItem` | Remove | সরান | |
| 143 | `clearSearch` | Clear the search | খোঁজা মুছুন | |
| 144 | `historySearchHint` | Search a serial or a reference number | সিরিয়াল বা রেফারেন্স নম্বর খুঁজুন | |
| 145 | `historyFilters` | Filters | ফিল্টার | |
| 146 | `historyApply` | Apply | প্রয়োগ করুন | |
| 147 | `historyReset` | Reset | রিসেট | |
| 148 | `historyWay` | Way | পদ্ধতি | |
| 149 | `historyDates` | Dates | তারিখ | |
| 150 | `historyAny` | Any | যেকোনো | |
| 151 | `historyPickDates` | Choose dates | তারিখ বেছে নিন | |
| 152 | `historyEmptyTitle` | No checks | কোনো যাচাই নেই | |
| 153 | `historyEmptyBody` | No check matches these filters. | এই ফিল্টারের সাথে কোনো যাচাই মেলেনি। | |
| 154 | `historyAll` | All | সব | |
| 155 | `historyToday` | Today | আজ | |
| 156 | `historyYesterday` | Yesterday | গতকাল | |
| 157 | `historyItemTitle` | Item | পণ্য | |
| 158 | `historyTrackingLog` | Tracking log | ট্র্যাকিং লগ | |
| 159 | `historyCheckCount` | {count, plural, =1{1 check} other{{count} checks}} | {count, plural, =1{১টি যাচাই} other{{count}টি যাচাই}} | |
| 160 | `historyTracking` | Your checks of serial {serial} | {serial} সিরিয়ালের আপনার যাচাইগুলো | |
| 161 | `pickRetailUser` | Choose a retail user | একজন খুচরা ব্যবহারকারী বেছে নিন | |
| 162 | `pickRetailUserHint` | Part of a name, or a whole email | নামের অংশ, বা পুরো ইমেইল | |
| 163 | `pickRetailUserEmpty` | No retail user found | কোনো খুচরা ব্যবহারকারী পাওয়া যায়নি | |
| 164 | `reportTitle` | Report incident | ঘটনা রিপোর্ট করুন | |
| 165 | `reportWhenNotNeeded` | No report is needed for a warning: a recalled, expired, damaged, or switched-off item is already sent to your office by the lookup. Report what a lookup cannot see, such as a fake-looking label or a torn seal. | সতর্কতার জন্য রিপোর্ট লাগে না: প্রত্যাহার করা, মেয়াদোত্তীর্ণ, ক্ষতিগ্রস্ত বা বন্ধ করা পণ্যের খবর যাচাইয়ের সময়ই আপনার অফিসে চলে যায়। যা যাচাইয়ে ধরা পড়ে না তা রিপোর্ট করুন, যেমন নকল মনে হওয়া লেবেল বা ছেঁড়া সিল। | |
| 166 | `reportNoteLabel` | What did you find? | আপনি কী পেয়েছেন? | |
| 167 | `reportNoteHint` | Describe the problem | সমস্যাটি বর্ণনা করুন | |
| 168 | `reportCheckLabel` | Check | যাচাই | |
| 169 | `reportRetailUserLabel` | Retail user | খুচরা ব্যবহারকারী | |
| 170 | `reportChooseRetailUser` | Choose a retail user (optional) | একজন খুচরা ব্যবহারকারী বেছে নিন (ঐচ্ছিক) | |
| 171 | `reportPhotosLabel` | Photos | ছবি | |
| 172 | `reportPhotosHint` | Up to 3 photos. Location and other details in the photo are removed. | সর্বোচ্চ ৩টি ছবি। ছবির অবস্থান ও অন্যান্য তথ্য মুছে ফেলা হয়। | |
| 173 | `reportAddPhoto` | Add photo | ছবি যোগ করুন | |
| 174 | `reportCamera` | Take a photo | ছবি তুলুন | |
| 175 | `reportGallery` | Choose from gallery | গ্যালারি থেকে বেছে নিন | |
| 176 | `reportFile` | File report | রিপোর্ট জমা দিন | |
| 177 | `reportFiled` | Report {id} filed. | রিপোর্ট {id} জমা হয়েছে। | |
| 178 | `reportPhotoFailedRetry` | Not sent. Tap to send again. | পাঠানো হয়নি। আবার পাঠাতে চাপুন। | |
| 179 | `reportPhotoRefused` | This photo was refused. | এই ছবিটি গ্রহণ করা হয়নি। | |
| 180 | `reportPhotoSent` | Photo {n} | ছবি {n} | |
| 181 | `reportPhotoTooLarge` | This photo is too large even after shrinking. | ছোট করার পরেও এই ছবিটি অনেক বড়। | |
| 182 | `reportPhotoUnreadable` | This photo could not be read. Try another. | এই ছবিটি পড়া যায়নি। অন্য একটি চেষ্টা করুন। | |
| 183 | `reportPhotoWindowOver` | Photos can be added only within an hour of the report. | রিপোর্ট জমার এক ঘণ্টার মধ্যেই শুধু ছবি যোগ করা যায়। | |
| 184 | `reportDone` | Done | সম্পন্ন | |
| 185 | `reportUnconfirmed` | The connection dropped. The report may have been filed: check My reports before filing it again. | সংযোগ বিচ্ছিন্ন হয়েছে। রিপোর্টটি হয়তো জমা হয়েছে: আবার জমা দেওয়ার আগে আমার রিপোর্ট দেখুন। | |
| 186 | `myReportsTitle` | My reports | আমার রিপোর্ট | |
| 187 | `myReportsEmpty` | You have not filed any report yet. | আপনি এখনো কোনো রিপোর্ট জমা দেননি। | |
| 188 | `myReportsPhotos` | {count, plural, =0{No photos} =1{1 photo} other{{count} photos}} | {count, plural, =0{কোনো ছবি নেই} =1{১টি ছবি} other{{count}টি ছবি}} | |
| 189 | `newReport` | New report | নতুন রিপোর্ট | |
| 190 | `reportFromResult` | Report incident | ঘটনা রিপোর্ট করুন | |
| 191 | `pictureTitle` | Product image | পণ্যের ছবি | |
| 192 | `pictureNone` | No picture for this product | এই পণ্যের কোনো ছবি নেই | |
| 193 | `pictureFailed` | The picture could not be loaded | ছবিটি লোড করা যায়নি | |
| 194 | `pictureOf` | Picture of {name} | {name}-এর ছবি | |
| 195 | `pictureOpenHint` | Opens the picture full screen | ছবিটি পূর্ণ পর্দায় খোলে | |
| 196 | `close` | Close | বন্ধ করুন | |
| 197 | `badgeGenuine` | Genuine | আসল | |
| 198 | `detailsProductTitle` | Product details | পণ্যের বিবরণ | |
| 199 | `checkNumber` | Check {count} | যাচাই {count} | |
| 200 | `previousCheckLabel` | Previous check | আগের যাচাই | |
| 201 | `checkedByLabel` | Checked before by | আগে যাচাই করেছেন | |
| 202 | `enteredTitle` | What you entered | আপনি যা দিয়েছেন | |
| 203 | `checkedAtLabel` | Checked at | যাচাইয়ের সময় | |
| 204 | `resultRowLabel` | Result | ফলাফল | |
| 205 | `hintsTitle` | Hints | পরামর্শ | |
| 206 | `hintScanQr` | Scan the QR code instead of typing. | লেখার বদলে QR কোড স্ক্যান করুন। | |
| 207 | `tryAgainLookup` | Try again | আবার চেষ্টা করুন | |
| 208 | `contactSupport` | Contact support | সহায়তায় যোগাযোগ করুন | |
| 209 | `backToVerify` | Back to Check | যাচাইয়ে ফিরে যান | |
| 210 | `supportEmailSubject` | Item not found: {ref} | পণ্য পাওয়া যায়নি: {ref} | |
| 211 | `supportEmailBody` | Reference: {ref}<br>{way}: {value}<br>Checked at: {time} | রেফারেন্স: {ref}<br>{way}: {value}<br>যাচাইয়ের সময়: {time} | |
| 212 | `verifyingTitle` | Checking the item… | পণ্যটি যাচাই হচ্ছে… | |
| 213 | `verifyingBody` | Checked against the company's records. This usually takes under a second. | কোম্পানির রেকর্ডের সাথে মেলানো হচ্ছে। সাধারণত এক সেকেন্ডের কম সময় লাগে। | |
| 214 | `stepCodeFormat` | Code format | কোডের ফরম্যাট | |
| 215 | `stepItemRecord` | Item record | পণ্যের রেকর্ড | |
| 216 | `stepCheckCount` | Check count | যাচাইয়ের সংখ্যা | |
| 217 | `stepDone` | done | সম্পন্ন | |
| 218 | `stepWaiting` | waiting | অপেক্ষমাণ | |
| 219 | `sessionFinish` | Finish | শেষ করুন | |
| 220 | `sessionFinishing` | Checking the last scans… | শেষ স্ক্যানগুলো যাচাই হচ্ছে… | |
| 221 | `sessionSummaryTitle` | Session finished | সেশন শেষ হয়েছে | |
| 222 | `sessionSummaryCount` | {count, plural, =1{1 product scanned} other{{count} products scanned}} | {count, plural, =1{১টি পণ্য স্ক্যান হয়েছে} other{{count}টি পণ্য স্ক্যান হয়েছে}} | |
| 223 | `sessionScanMore` | Scan more | আরও স্ক্যান | |
| 224 | `sessionDone` | Done | সম্পন্ন | |
| 225 | `historySession` | Session {id} | সেশন {id} | |
| 226 | `historyCheckedBy` | Checked by {name} | যাচাই করেছেন {name} | |

## Written earlier (101)

| # | Key | English | Bangla | Drafted | Review |
|---|---|---|---|---|---|
| 1 | `appTitle` | Track & Trace | Track & Trace | earlier | |
| 2 | `requestAccessButton` | Sign up | সাইন আপ | earlier | |
| 3 | `changePasswordChoiceSubtitle` | Your password was set by someone else. Choose your own now, or later from Profile. | আপনার পাসওয়ার্ড অন্য কেউ সেট করেছে। এখনই নিজের পাসওয়ার্ড বেছে নিন, অথবা পরে প্রোফাইল থেকে। | 2026-11-17 | |
| 4 | `changePasswordLater` | Not now | এখন নয় | 2026-11-17 | |
| 5 | `passwordLaterRefused` | Not now is not available for your account. Choose a new password or log out. | আপনার অ্যাকাউন্টে "এখন নয়" নেই। নতুন পাসওয়ার্ড বেছে নিন বা লগ আউট করুন। | 2026-11-17 | |
| 6 | `ruleNoControl` | no tabs or line breaks | ট্যাব বা লাইন ব্রেক নয় | 2026-11-17 | |
| 7 | `resetCodeWrong` | The code is wrong or has expired. Ask for a new code. | কোডটি ভুল বা মেয়াদোত্তীর্ণ। নতুন কোড চান। | 2026-11-17 | |
| 8 | `resetNewCode` | Send a new code | নতুন কোড পাঠান | 2026-11-17 | |
| 9 | `requestAccessTitle` | Sign up | সাইন আপ | earlier | |
| 10 | `requestAccessSubtitle` | Create your account. Your office checks it and emails you its answer. | আপনার অ্যাকাউন্ট তৈরি করুন। অফিস যাচাই করে ইমেইলে উত্তর জানাবে। | 2026-11-19 | |
| 11 | `permissionsSection` | WHAT YOU CAN DO | আপনি যা করতে পারেন | 2026-11-17 | |
| 12 | `permissionLookup` | Check one item | একটি পণ্য যাচাই | 2026-11-17 | |
| 13 | `permissionBulkLookup` | Check many items | একাধিক পণ্য যাচাই | 2026-11-17 | |
| 14 | `permissionHistory` | Own history | নিজের ইতিহাস | 2026-11-17 | |
| 15 | `permissionReport` | Report incidents | ঘটনা রিপোর্ট | 2026-11-17 | |
| 16 | `permissionsNone` | None. Ask your office. | কিছু নেই। আপনার অফিসকে জিজ্ঞাসা করুন। | 2026-11-17 | |
| 17 | `statNotVerified` | Needs attention | মনোযোগ দরকার | 2026-11-17 | |
| 18 | `passwordPendingBanner` | Your password was set by someone else. Change it to keep your account safe. | আপনার পাসওয়ার্ড অন্য কেউ সেট করেছে। অ্যাকাউন্ট নিরাপদ রাখতে এটি বদলান। | 2026-11-17 | |
| 19 | `supportNotSet` | Not set by your office | আপনার অফিস সেট করেনি | 2026-11-17 | |
| 20 | `wayOther` | Other | অন্যান্য | 2026-11-17 | |
| 21 | `historyNoChecksYet` | Your checks appear here after your first check. | প্রথম যাচাইয়ের পর আপনার যাচাইগুলো এখানে দেখা যাবে। | 2026-11-17 | |
| 22 | `reportChooseCheck` | Link one of your checks (optional) | আপনার একটি যাচাই যুক্ত করুন (ঐচ্ছিক) | 2026-11-17 | |
| 23 | `pickCheck` | Choose a check | একটি যাচাই বেছে নিন | 2026-11-17 | |
| 24 | `reportPhotoConflict` | No more photos: the report has 3, or its hour is over. | আর ছবি নয়: রিপোর্টে ৩টি আছে, অথবা এক ঘণ্টা পেরিয়ে গেছে। | 2026-11-17 | |
| 25 | `reportLeaveTitle` | Photos not sent | ছবি পাঠানো হয়নি | 2026-11-17 | |
| 26 | `reportLeaveBody` | Some photos are still sending or can be sent again. If you leave, they are not sent. | কিছু ছবি এখনো পাঠানো হচ্ছে বা আবার পাঠানো যায়। চলে গেলে সেগুলো পাঠানো হবে না। | 2026-11-17 | |
| 27 | `reportStay` | Stay | থাকুন | 2026-11-17 | |
| 28 | `reportLeave` | Leave | চলে যান | 2026-11-17 | |
| 29 | `reportCheckMyReports` | Check My reports | আমার রিপোর্ট দেখুন | 2026-11-17 | |
| 30 | `myReportsEmptyBody` | Reports you file appear here. Use New report to file one. | আপনার পাঠানো রিপোর্ট এখানে দেখা যাবে। পাঠাতে নতুন রিপোর্ট ব্যবহার করুন। | 2026-11-17 | |
| 31 | `backToList` | Back to the list | তালিকায় ফিরুন | 2026-11-17 | |
| 32 | `accessPending` | Thanks for signing up. Your request was sent. You will get an email when it is answered. | সাইন আপের জন্য ধন্যবাদ। আপনার আবেদন পাঠানো হয়েছে। উত্তর দেওয়া হলে আপনি একটি ইমেইল পাবেন। | 2026-11-19 | |
| 33 | `accessWrongCode` | The code is wrong or expired. Request a new code if needed. | কোডটি ভুল বা মেয়াদ শেষ। প্রয়োজনে নতুন কোড নিন। | earlier | |
| 34 | `accessTryLater` | Try again later. Get a new code before you sign up again. | পরে আবার চেষ্টা করুন। আবার সাইন আপের আগে নতুন কোড নিন। | earlier | |
| 35 | `accessRoleUnavailable` | This role is no longer available. Choose another role. | এই ভূমিকা এখন আর পাওয়া যাচ্ছে না। অন্য একটি বেছে নিন। | earlier | |
| 36 | `accessNoRoles` | Ask the office for an account. | অ্যাকাউন্টের জন্য অফিসে যোগাযোগ করুন। | earlier | |
| 37 | `accessContactOffice` | Contact the office | অফিসে যোগাযোগ করুন। | earlier | |
| 38 | `accessName` | Name | নাম | earlier | |
| 39 | `accessRole` | Role | ভূমিকা | earlier | |
| 40 | `accessRoleHint` | Choose a role | একটি ভূমিকা বেছে নিন | 2026-11-17 | |
| 41 | `accessPassword` | Choose a password | পাসওয়ার্ড বেছে নিন | earlier | |
| 42 | `accessShowPassword` | Show password | পাসওয়ার্ড দেখুন | earlier | |
| 43 | `accessHidePassword` | Hide password | পাসওয়ার্ড লুকান | earlier | |
| 44 | `accessEmail` | Email | ইমেইল | earlier | |
| 45 | `accessCode` | Code from the email | ইমেইলের কোড | 2026-11-17 | |
| 46 | `accessResend` | Send a new code | নতুন কোড পাঠান | earlier | |
| 47 | `accessSendCode` | Send code | কোড পাঠান | earlier | |
| 48 | `accessCodeSent` | A code was sent to the address. | ঠিকানায় একটি কোড পাঠানো হয়েছে। | earlier | |
| 49 | `accessSubmit` | Sign up | সাইন আপ | earlier | |
| 50 | `scannerModeTitle` | Scanner mode | স্ক্যানার মোড | earlier | |
| 51 | `serialStackTitle` | Serial stack | সিরিয়ালের তালিকা | earlier | |
| 52 | `serialStackHint` | Type or paste up to 50 serials, separated by spaces, commas, or new lines. Repeated serials are checked once. | সর্বোচ্চ ৫০টি সিরিয়াল লিখুন বা পেস্ট করুন। স্পেস, কমা বা নতুন লাইন দিয়ে আলাদা করুন। একই সিরিয়াল একবারই যাচাই হবে। | earlier | |
| 53 | `serialStackLimit` | Enter 1 to 50 different serials. Submit another stack for additional items. | ১ থেকে ৫০টি ভিন্ন সিরিয়াল দিন। আরও পণ্যের জন্য নতুন তালিকা পাঠান। | earlier | |
| 54 | `serialStackUncertain` | The answer was lost. These checks may already be recorded. Retrying may record them again. | উত্তর পাওয়া যায়নি। যাচাইগুলো ইতিমধ্যে সংরক্ষিত হতে পারে। আবার পাঠালে পুনরায় সংরক্ষিত হতে পারে। | earlier | |
| 55 | `serialStackNotSent` | No connection. Nothing was sent; send the stack again when you are online. | সংযোগ নেই। কিছুই পাঠানো হয়নি; অনলাইনে এলে তালিকাটি আবার পাঠান। | 2026-11-17 | |
| 56 | `serialStackBadSerial` | Serial {position} ({value}) is not a serial: digits only, up to {digits} digits. | {position} নম্বর ({value}) সিরিয়াল নয়: শুধু সংখ্যা, সর্বোচ্চ {digits} অঙ্ক। | 2026-11-17 | |
| 57 | `serialStackCount` | {count} of 50 serials | ৫০টির মধ্যে {count}টি সিরিয়াল | 2026-11-17 | |
| 58 | `serialStackCountRepeats` | {count} of 50 serials · {repeats} repeated, sent once | ৫০টির মধ্যে {count}টি সিরিয়াল · {repeats}টি পুনরাবৃত্ত, একবার পাঠানো হবে | 2026-11-17 | |
| 59 | `serialStackRecorded` | These checks were recorded, but their answer could not be shown. See them in History → Sessions. Do not send the same stack again. | যাচাইগুলো রেকর্ড হয়েছে, কিন্তু উত্তর দেখানো যায়নি। ইতিহাস → সেশনে দেখুন। একই তালিকা আবার পাঠাবেন না। | 2026-11-17 | |
| 60 | `serialStackRetry` | Send the same stack again | একই তালিকা আবার পাঠান | earlier | |
| 61 | `serialStackSubmit` | Check serials | সিরিয়াল যাচাই করুন | earlier | |
| 62 | `serialStackNew` | Start another stack | নতুন তালিকা শুরু করুন | earlier | |
| 63 | `serialStackHistory` | View this session's checks | এই সেশনের যাচাই দেখুন | earlier | |
| 64 | `sessionScanned` | Scanned | যাচাই হয়েছে | earlier | |
| 65 | `sessionValid` | Valid | সঠিক | earlier | |
| 66 | `sessionWarning` | Warning | সতর্কতা | earlier | |
| 67 | `sessionNotFound` | Not found | পাওয়া যায়নি | earlier | |
| 68 | `sessionUnassigned` | Not in a batch | বরাদ্দ হয়নি | earlier | |
| 69 | `sessionLeft` | Remaining | অবশিষ্ট | earlier | |
| 70 | `sessionRepeat` | Already scanned | ইতিমধ্যে স্ক্যান হয়েছে | earlier | |
| 71 | `sessionScanAgain` | Scan again | আবার স্ক্যান করুন | earlier | |
| 72 | `sessionNoConnection` | No connection, scan again. | সংযোগ নেই, আবার স্ক্যান করুন। | 2026-11-17 | |
| 73 | `sessionBusy` | The service is busy. Nothing was recorded; scan again. | সেবাটি ব্যস্ত। কিছুই রেকর্ড হয়নি; আবার স্ক্যান করুন। | 2026-11-17 | |
| 74 | `sessionRestarted` | A new session started. | একটি নতুন সেশন শুরু হয়েছে। | 2026-11-17 | |
| 75 | `sessionsTitle` | Sessions | সেশন | earlier | |
| 76 | `sessionsMore` | Load more | আরও দেখুন | earlier | |
| 77 | `sessionsAll` | All | সব | earlier | |
| 78 | `sessionsOpen` | Open | চলমান | earlier | |
| 79 | `sessionsEnded` | Ended | সমাপ্ত | earlier | |
| 80 | `sessionsDates` | Choose dates | তারিখ বেছে নিন | earlier | |
| 81 | `sessionsLastSevenDays` | Showing the last 7 days | গত ৭ দিনের তথ্য দেখানো হচ্ছে | earlier | |
| 82 | `sessionsEmpty` | No sessions found. | কোনো সেশন পাওয়া যায়নি। | earlier | |
| 83 | `historyChecksView` | Checks | যাচাই | 2026-11-17 | |
| 84 | `sessionsStarted` | Started | শুরু | 2026-11-17 | |
| 85 | `sessionsLastScan` | Last scan | শেষ স্ক্যান | 2026-11-17 | |
| 86 | `sessionChecksTitle` | Session checks | সেশনের যাচাই | 2026-11-17 | |
| 87 | `rateLimitedUnknown` | Too many attempts. Try again later. | অতিরিক্ত চেষ্টা হয়েছে। পরে আবার চেষ্টা করুন। | earlier | |
| 88 | `sessionRowsFailed` | Couldn't load this session's scans. | এই সেশনের স্ক্যানগুলো লোড করা যায়নি। | 2026-11-17 | |
| 89 | `reportPhotoSame` | That photo is already on the report. | এই ছবিটি রিপোর্টে আগেই আছে। | 2026-11-17 | |
| 90 | `reportUnreadable` | The report was sent, but its answer could not be read. It may have been filed: check My reports before filing it again. | রিপোর্টটি পাঠানো হয়েছে, কিন্তু উত্তরটি পড়া যায়নি। এটি হয়তো জমা হয়েছে: আবার জমা দেওয়ার আগে আমার রিপোর্ট দেখুন। | 2026-11-17 | |
| 91 | `reportCheckGone` | The check was not found. Remove it and try again. | চেকটি পাওয়া যায়নি। এটি সরিয়ে আবার চেষ্টা করুন। | 2026-11-17 | |
| 92 | `reportRetailUserGone` | This retail user can no longer be named. Choose another, or file without one. | এই খুচরা ব্যবহারকারীর নাম আর দেওয়া যাবে না। অন্য একজন বেছে নিন, অথবা ছাড়াই জমা দিন। | 2026-11-17 | |
| 93 | `sessionResumedCounts` | Resumed session. The counts show after the next scan. | সেশন আবার চালু হয়েছে। পরের স্ক্যানের পর গণনা দেখা যাবে। | 2026-11-17 | |
| 94 | `sessionChecking` | Checking… | যাচাই হচ্ছে… | 2026-11-17 | |
| 95 | `sessionCheckingMore` | Checking… {count} more | যাচাই হচ্ছে… আরও {count}টি | 2026-11-17 | |
| 96 | `sessionNotChecked` | {count} more scans were not checked. Scan them again. | আরও {count}টি স্ক্যান যাচাই হয়নি। আবার স্ক্যান করুন। | 2026-11-17 | |
| 97 | `typeSerialLabel` | Or type the serial | অথবা সিরিয়াল লিখুন | 2026-11-17 | |
| 98 | `scanNotReady` | Scanning waits for the code formats. | কোডের ফরম্যাট লোড হলে স্ক্যান শুরু হবে। | 2026-11-17 | |
| 99 | `copyrightNotice` | © {year} Ziska Pharmaceuticals Ltd. All rights reserved. | © {year} Ziska Pharmaceuticals Ltd. সর্বস্বত্ব সংরক্ষিত। | 2026-11-17 | |
| 100 | `appVersionShort` | Version {version} ({build}) | সংস্করণ {version} ({build}) | 2026-11-17 | |
| 101 | `offlineBanner` | No internet connection. Checks need a connection. | ইন্টারনেট সংযোগ নেই। যাচাই করতে সংযোগ প্রয়োজন। | earlier | |

## After the review

Corrections go into `lib/l10n/app_bn.arb`, then `flutter gen-l10n`, then `flutter test test/l10n test/ui/wording_test.dart` (every key present, placeholders kept, no "verify" wording) and the Bangla goldens (`flutter test --tags golden test/ui/consistency_fit_test.dart`).
