// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'Track & Trace';

  @override
  String get appSubtitle => 'পণ্যের সত্যতা যাচাই';

  @override
  String get splashTagline => 'আসল পণ্য মুহূর্তেই যাচাই করুন';

  @override
  String get brandTagline => 'TRACK · TRACE · CHECK';

  @override
  String get loginTitle => 'Track & Trace-এ লগইন করুন';

  @override
  String get loginSubtitle => 'পণ্য যাচাই করতে আপনার ইমেইল ও পাসওয়ার্ড দিন।';

  @override
  String get emailLabel => 'ইমেইল';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get passwordLabel => 'পাসওয়ার্ড';

  @override
  String get showPassword => 'পাসওয়ার্ড দেখুন';

  @override
  String get hidePassword => 'পাসওয়ার্ড লুকান';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get loginButton => 'নিরাপদে লগইন করুন';

  @override
  String get noAccountDivider => 'অ্যাকাউন্ট নেই?';

  @override
  String get noAccountQuestion => 'আপনার কি অ্যাকাউন্ট নেই?';

  @override
  String get requestAccessButton => 'অ্যাকাউন্টের আবেদন';

  @override
  String get authorizedOnly =>
      'শুধু অনুমোদিত ব্যবহারকারীরা এই সিস্টেম ব্যবহার করতে পারবেন';

  @override
  String get loginFailed => 'ইমেইল বা পাসওয়ার্ড সঠিক নয়।';

  @override
  String get fieldRequired => 'আবশ্যক';

  @override
  String get emailInvalid => 'একটি সঠিক ইমেইল ঠিকানা দিন';

  @override
  String get verifyCodeTitle => 'আপনার ইমেইল দেখুন';

  @override
  String verifyCodeSubtitle(String email) {
    return '$email-এ একটি ৬ অঙ্কের কোড পাঠানো হয়েছে। এই ফোনটিকে বিশ্বস্ত করতে কোডটি দিন।';
  }

  @override
  String get codeLabel => 'ইমেইলের কোড';

  @override
  String get verifyButton => 'চালিয়ে যান';

  @override
  String get codeWrong =>
      'কোডটি ভুল বা মেয়াদোত্তীর্ণ। সর্বশেষ ইমেইলটি দেখুন, অথবা আবার কোড পাঠান।';

  @override
  String get resendCode => 'আবার কোড পাঠান';

  @override
  String resendIn(int seconds) {
    return '$seconds সেকেন্ড পরে আবার পাঠান';
  }

  @override
  String get codeResent => 'একটি নতুন কোড পাঠানো হয়েছে।';

  @override
  String get resendLimitReached =>
      'আর কোনো কোড পাঠানো যাবে না। আবার লগইন করুন।';

  @override
  String get backToLogin => 'লগইনে ফিরে যান';

  @override
  String get changePasswordTitle => 'নতুন পাসওয়ার্ড দিন';

  @override
  String get changePasswordForcedSubtitle =>
      'আপনার পাসওয়ার্ড অন্য কেউ সেট করেছে। চালিয়ে যেতে নিজের পাসওয়ার্ড বেছে নিন।';

  @override
  String get changePasswordSubtitle =>
      'একটি নতুন পাসওয়ার্ড বেছে নিন। আপনার অন্যান্য ফোন থেকে লগআউট হয়ে যাবে।';

  @override
  String get currentPasswordLabel => 'বর্তমান পাসওয়ার্ড';

  @override
  String get newPasswordLabel => 'নতুন পাসওয়ার্ড';

  @override
  String get confirmPasswordLabel => 'নতুন পাসওয়ার্ড আবার দিন';

  @override
  String get passwordsDoNotMatch => 'পাসওয়ার্ড দুটি মেলেনি';

  @override
  String get changePasswordButton => 'পাসওয়ার্ড সংরক্ষণ করুন';

  @override
  String get currentPasswordWrong => 'বর্তমান পাসওয়ার্ড সঠিক নয়।';

  @override
  String get passwordChanged => 'আপনার পাসওয়ার্ড বদলানো হয়েছে।';

  @override
  String get logout => 'লগআউট';

  @override
  String get ruleLength => '৮ বা তার বেশি অক্ষর';

  @override
  String get ruleLetter => 'একটি বর্ণ';

  @override
  String get ruleNumber => 'একটি সংখ্যা';

  @override
  String get ruleNoControl => 'ট্যাব বা লাইন ব্রেক নয়';

  @override
  String get passwordRuleBroken => 'পাসওয়ার্ডটি নিচের নিয়ম মানছে না।';

  @override
  String get forgotTitle => 'পাসওয়ার্ড ভুলে গেছেন';

  @override
  String get forgotSubtitle =>
      'আপনার ইমেইল দিন। এর কোনো অ্যাকাউন্ট থাকলে আমরা একটি ৬ অঙ্কের কোড পাঠাব।';

  @override
  String get sendCodeButton => 'কোড পাঠান';

  @override
  String get forgotSent => 'ঠিকানাটির অ্যাকাউন্ট থাকলে একটি কোড পাঠানো হয়েছে।';

  @override
  String get resetTitle => 'পাসওয়ার্ড রিসেট';

  @override
  String get resetCodeWrong => 'কোডটি ভুল বা মেয়াদোত্তীর্ণ। নতুন কোড চান।';

  @override
  String get resetNewCode => 'নতুন কোড পাঠান';

  @override
  String resetSubtitle(String email) {
    return '$email-এর অ্যাকাউন্ট থাকলে সেখানে একটি কোড পাঠানো হয়েছে। কোডটি দিন এবং নতুন পাসওয়ার্ড বেছে নিন।';
  }

  @override
  String get resetButton => 'পাসওয়ার্ড রিসেট করুন';

  @override
  String get resetDone =>
      'পাসওয়ার্ড বদলানো হয়েছে। নতুন পাসওয়ার্ড দিয়ে লগইন করুন; পরের লগইনে প্রতিটি ফোনে ইমেইলের কোড লাগবে।';

  @override
  String get requestAccessTitle => 'অ্যাকাউন্টের আবেদন';

  @override
  String get requestAccessSubtitle =>
      'একটি অ্যাকাউন্ট চান। অফিস আবেদনটি যাচাই করে ইমেইলে উত্তর জানাবে।';

  @override
  String noPhoneApp(String phone) {
    return 'কোনো ফোন অ্যাপ পাওয়া যায়নি। $phone নম্বরে কল করুন।';
  }

  @override
  String noMailApp(String email) {
    return 'কোনো ইমেইল অ্যাপ পাওয়া যায়নি। $email-এ লিখুন।';
  }

  @override
  String get welcomeBack => 'আবার স্বাগতম,';

  @override
  String get loadingProfile => 'আপনার প্রোফাইল লোড হচ্ছে…';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get errorNetwork => 'সংযোগ নেই। ইন্টারনেট দেখে আবার চেষ্টা করুন।';

  @override
  String errorRateLimited(int seconds) {
    return 'অনেকবার চেষ্টা করা হয়েছে। $seconds সেকেন্ড পরে আবার চেষ্টা করুন।';
  }

  @override
  String get errorPreparing => 'অ্যাপটি প্রস্তুত হচ্ছে। পরে আবার চেষ্টা করুন।';

  @override
  String get errorUnavailable => 'সেবাটি ব্যস্ত। একটু পরে আবার চেষ্টা করুন।';

  @override
  String get errorNotAvailable => 'পাওয়া যাচ্ছে না।';

  @override
  String get errorGeneral => 'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String reference(String id) {
    return 'রেফারেন্স: $id';
  }

  @override
  String get tabVerify => 'যাচাই';

  @override
  String get tabHistory => 'ইতিহাস';

  @override
  String get tabProfile => 'প্রোফাইল';

  @override
  String get noFeaturesTitle => 'এখনো কোনো সুবিধা নেই';

  @override
  String get noFeaturesBody =>
      'আপনার ভূমিকায় এখনো কোনো সুবিধা দেওয়া হয়নি। আপনার অফিসে যোগাযোগ করুন।';

  @override
  String get profileTitle => 'প্রোফাইল';

  @override
  String get organisationLabel => 'প্রতিষ্ঠান';

  @override
  String get roleLabel => 'ভূমিকা';

  @override
  String get permissionsSection => 'আপনি যা করতে পারেন';

  @override
  String get permissionLookup => 'একটি পণ্য যাচাই';

  @override
  String get permissionBulkLookup => 'একাধিক পণ্য যাচাই';

  @override
  String get permissionHistory => 'নিজের ইতিহাস';

  @override
  String get permissionReport => 'ঘটনা রিপোর্ট';

  @override
  String get permissionsNone => 'কিছু নেই। আপনার অফিসকে জিজ্ঞাসা করুন।';

  @override
  String get accountSection => 'অ্যাকাউন্ট';

  @override
  String get statChecks => 'যাচাই';

  @override
  String get statValid => 'আসল';

  @override
  String get statNotVerified => 'মনোযোগ দরকার';

  @override
  String get statsFailed => 'আপনার হিসাব লোড করা যায়নি।';

  @override
  String get changePasswordRow => 'পাসওয়ার্ড বদলান';

  @override
  String get languageRow => 'ভাষা';

  @override
  String get languageTitle => 'অ্যাপের ভাষা';

  @override
  String get supportContactRow => 'সহায়তার যোগাযোগ';

  @override
  String get supportNotSet => 'আপনার অফিস সেট করেনি';

  @override
  String get appVersionRow => 'অ্যাপ সংস্করণ';

  @override
  String appVersionValue(String version, String build) {
    return 'v$version · বিল্ড $build';
  }

  @override
  String get logoutConfirmTitle => 'লগআউট করবেন?';

  @override
  String get logoutConfirmBody =>
      'এই ফোনটি বিশ্বস্ত থাকবে, তাই পরের লগইনে ইমেইলের কোড লাগবে না।';

  @override
  String get cancel => 'বাতিল';

  @override
  String get verifyItemTitle => 'সত্যতা যাচাই করুন';

  @override
  String get waySerial => 'সিরিয়াল';

  @override
  String get wayHiddenCode => 'গোপন কোড';

  @override
  String get wayQr => 'QR কোড';

  @override
  String get wayOther => 'অন্যান্য';

  @override
  String serialHint(int digits) {
    return 'সর্বোচ্চ $digits অঙ্ক';
  }

  @override
  String get verifyButtonLookup => 'যাচাই';

  @override
  String get clear => 'মুছুন';

  @override
  String get scanFrameHint => 'QR কোডটি ফ্রেমের ভেতরে রাখুন';

  @override
  String get scanLooking => 'QR কোড খোঁজা হচ্ছে · স্থির রাখুন';

  @override
  String get inputEmpty => 'আগে একটি মান দিন';

  @override
  String inputWrongSerial(int digits) {
    return 'সিরিয়ালে শুধু অঙ্ক থাকে, সর্বোচ্চ $digitsটি।';
  }

  @override
  String get notProductQr => 'এই QR কোডটি এই কোম্পানির কোনো পণ্যের কোড নয়।';

  @override
  String get formatsFailed => 'কোডের ফরম্যাট লোড করা যায়নি।';

  @override
  String get lookupNetworkError =>
      'যাচাই করা যায়নি। সংযোগ দেখে আবার চেষ্টা করুন।';

  @override
  String get verifying => 'যাচাই হচ্ছে…';

  @override
  String get toolsTitle => 'আরও';

  @override
  String get toolReport => 'ঘটনা রিপোর্ট করুন';

  @override
  String get toolMyReports => 'আমার রিপোর্ট';

  @override
  String get scannerPermissionDenied =>
      'ক্যামেরার অনুমতি বন্ধ। QR কোড স্ক্যান করতে সেটিংসে অনুমতি দিন।';

  @override
  String get scannerUnsupported =>
      'এই ফোনে QR কোড স্ক্যান করা যায় না। এর বদলে সিরিয়াল লিখুন।';

  @override
  String get scannerFailed => 'ক্যামেরা চালু করা যায়নি।';

  @override
  String get openSettings => 'সেটিংস খুলুন';

  @override
  String get torch => 'টর্চ';

  @override
  String get resultTitle => 'যাচাইয়ের ফল';

  @override
  String get resultValidTitle => 'আসল পণ্য';

  @override
  String get resultValidBody =>
      'কোনো কর্মকর্তার প্রথম যাচাই। এই পণ্যে কোনো সমস্যা নেই।';

  @override
  String get resultWarningTitle => 'আসল, তবে মনোযোগ দরকার';

  @override
  String get resultWarningBody => 'নিচের প্রতিটি কারণ পড়ুন।';

  @override
  String get resultNotFoundTitle => 'পাওয়া যায়নি';

  @override
  String get resultNotFoundBody =>
      'এই সিরিয়াল বা QR কোডের কোনো পণ্য এই কোম্পানির নেই।';

  @override
  String get resultUnassignedTitle => 'কোনো ব্যাচে নেই';

  @override
  String get resultUnassignedBody =>
      'পণ্যটি আছে, তবে এখনো কোনো ব্যাচে দেওয়া হয়নি।';

  @override
  String get resultUnknownTitle => 'যাচাই করা যায়নি';

  @override
  String get resultUnknownBody =>
      'এই ফলাফল এই অ্যাপ সংস্করণে জানা নেই। অ্যাপ হালনাগাদ করুন বা আপনার অফিসে যোগাযোগ করুন।';

  @override
  String get reasonCheckedBefore => 'আগে যাচাই হয়েছে';

  @override
  String reasonCheckedBeforeDetail(int count, String when) {
    return 'এটি এই পণ্যের $count নম্বর যাচাই। শেষ যাচাই: $when।';
  }

  @override
  String get reasonRecalled => 'ব্যাচ প্রত্যাহার করা হয়েছে';

  @override
  String get reasonExpired => 'মেয়াদোত্তীর্ণ';

  @override
  String get reasonDamaged => 'ক্ষতিগ্রস্ত হিসেবে চিহ্নিত';

  @override
  String get reasonSwitchedOff => 'ব্যাচ বন্ধ করা হয়েছে';

  @override
  String get reasonUnknown => 'মনোযোগ দরকার';

  @override
  String get referenceNumber => 'রেফারেন্স নম্বর';

  @override
  String get productLabel => 'পণ্য';

  @override
  String get genericLabel => 'জেনেরিক নাম';

  @override
  String get shortNameLabel => 'সংক্ষিপ্ত নাম';

  @override
  String get serialLabel => 'সিরিয়াল';

  @override
  String get codeLabel2 => 'গোপন কোড';

  @override
  String get batchLabel => 'ব্যাচ';

  @override
  String get madeLabel => 'তৈরি';

  @override
  String get expiresLabel => 'মেয়াদ শেষ';

  @override
  String get verifyAnother => 'আরেকটি পণ্য যাচাই করুন';

  @override
  String get copied => 'কপি হয়েছে';

  @override
  String get copyReference => 'রেফারেন্স নম্বর কপি করুন';

  @override
  String get bulkValid => 'আসল';

  @override
  String get bulkWarning => 'সতর্কতা';

  @override
  String get bulkNotFound => 'পাওয়া যায়নি';

  @override
  String get bulkUnassigned => 'কোনো ব্যাচে নেই';

  @override
  String get removeItem => 'সরান';

  @override
  String get clearSearch => 'খোঁজা মুছুন';

  @override
  String get historySearchHint => 'সিরিয়াল বা রেফারেন্স নম্বর খুঁজুন';

  @override
  String get historyFilters => 'ফিল্টার';

  @override
  String get historyApply => 'প্রয়োগ করুন';

  @override
  String get historyReset => 'রিসেট';

  @override
  String get historyWay => 'পদ্ধতি';

  @override
  String get historyDates => 'তারিখ';

  @override
  String get historyAny => 'যেকোনো';

  @override
  String get historyPickDates => 'তারিখ বেছে নিন';

  @override
  String get historyEmptyTitle => 'কোনো যাচাই নেই';

  @override
  String historySession(String id) {
    return 'সেশন $id';
  }

  @override
  String historyCheckedBy(String name) {
    return 'যাচাই করেছেন $name';
  }

  @override
  String get historyEmptyBody => 'এই ফিল্টারের সাথে কোনো যাচাই মেলেনি।';

  @override
  String get historyNoChecksYet =>
      'প্রথম যাচাইয়ের পর আপনার যাচাইগুলো এখানে দেখা যাবে।';

  @override
  String get historyAll => 'সব';

  @override
  String get historyToday => 'আজ';

  @override
  String get historyYesterday => 'গতকাল';

  @override
  String get historyItemTitle => 'পণ্য';

  @override
  String get historyTrackingLog => 'ট্র্যাকিং লগ';

  @override
  String historyCheckCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি যাচাই',
      one: '১টি যাচাই',
    );
    return '$_temp0';
  }

  @override
  String historyTracking(String serial) {
    return '$serial সিরিয়ালের আপনার যাচাইগুলো';
  }

  @override
  String get pickRetailUser => 'একজন খুচরা ব্যবহারকারী বেছে নিন';

  @override
  String get pickRetailUserHint => 'নামের অংশ, বা পুরো ইমেইল';

  @override
  String get pickRetailUserEmpty => 'কোনো খুচরা ব্যবহারকারী পাওয়া যায়নি';

  @override
  String get reportTitle => 'ঘটনা রিপোর্ট করুন';

  @override
  String get reportWhenNotNeeded =>
      'সতর্কতার জন্য রিপোর্ট লাগে না: প্রত্যাহার করা, মেয়াদোত্তীর্ণ, ক্ষতিগ্রস্ত বা বন্ধ করা পণ্যের খবর যাচাইয়ের সময়ই আপনার অফিসে চলে যায়। যা যাচাইয়ে ধরা পড়ে না তা রিপোর্ট করুন, যেমন নকল মনে হওয়া লেবেল বা ছেঁড়া সিল।';

  @override
  String get reportNoteLabel => 'আপনি কী পেয়েছেন?';

  @override
  String get reportNoteHint => 'সমস্যাটি বর্ণনা করুন';

  @override
  String get reportCheckLabel => 'যাচাই';

  @override
  String get reportRetailUserLabel => 'খুচরা ব্যবহারকারী';

  @override
  String get reportChooseRetailUser =>
      'একজন খুচরা ব্যবহারকারী বেছে নিন (ঐচ্ছিক)';

  @override
  String get reportChooseCheck => 'আপনার একটি যাচাই যুক্ত করুন (ঐচ্ছিক)';

  @override
  String get pickCheck => 'একটি যাচাই বেছে নিন';

  @override
  String get reportPhotosLabel => 'ছবি';

  @override
  String get reportPhotosHint =>
      'সর্বোচ্চ ৩টি ছবি। ছবির অবস্থান ও অন্যান্য তথ্য মুছে ফেলা হয়।';

  @override
  String get reportAddPhoto => 'ছবি যোগ করুন';

  @override
  String get reportCamera => 'ছবি তুলুন';

  @override
  String get reportGallery => 'গ্যালারি থেকে বেছে নিন';

  @override
  String get reportFile => 'রিপোর্ট জমা দিন';

  @override
  String reportFiled(int id) {
    return 'রিপোর্ট $id জমা হয়েছে।';
  }

  @override
  String get reportPhotoFailedRetry => 'পাঠানো হয়নি। আবার পাঠাতে চাপুন।';

  @override
  String get reportPhotoRefused => 'এই ছবিটি গ্রহণ করা হয়নি।';

  @override
  String get reportPhotoConflict =>
      'আর ছবি নয়: রিপোর্টে ৩টি আছে, অথবা এক ঘণ্টা পেরিয়ে গেছে।';

  @override
  String get reportLeaveTitle => 'ছবি পাঠানো হয়নি';

  @override
  String get reportLeaveBody =>
      'কিছু ছবি এখনো পাঠানো হচ্ছে বা আবার পাঠানো যায়। চলে গেলে সেগুলো পাঠানো হবে না।';

  @override
  String get reportStay => 'থাকুন';

  @override
  String get reportLeave => 'চলে যান';

  @override
  String reportPhotoSent(int n) {
    return 'ছবি $n';
  }

  @override
  String get reportPhotoTooLarge => 'ছোট করার পরেও এই ছবিটি অনেক বড়।';

  @override
  String get reportPhotoUnreadable =>
      'এই ছবিটি পড়া যায়নি। অন্য একটি চেষ্টা করুন।';

  @override
  String get reportPhotoWindowOver =>
      'রিপোর্ট জমার এক ঘণ্টার মধ্যেই শুধু ছবি যোগ করা যায়।';

  @override
  String get reportDone => 'সম্পন্ন';

  @override
  String get reportUnconfirmed =>
      'সংযোগ বিচ্ছিন্ন হয়েছে। রিপোর্টটি হয়তো জমা হয়েছে: আবার জমা দেওয়ার আগে আমার রিপোর্ট দেখুন।';

  @override
  String get reportCheckMyReports => 'আমার রিপোর্ট দেখুন';

  @override
  String get myReportsTitle => 'আমার রিপোর্ট';

  @override
  String get myReportsEmpty => 'আপনি এখনো কোনো রিপোর্ট জমা দেননি।';

  @override
  String get myReportsEmptyBody =>
      'আপনার পাঠানো রিপোর্ট এখানে দেখা যাবে। পাঠাতে নতুন রিপোর্ট ব্যবহার করুন।';

  @override
  String myReportsPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি ছবি',
      one: '১টি ছবি',
      zero: 'কোনো ছবি নেই',
    );
    return '$_temp0';
  }

  @override
  String get newReport => 'নতুন রিপোর্ট';

  @override
  String get reportFromResult => 'ঘটনা রিপোর্ট করুন';

  @override
  String get pictureTitle => 'পণ্যের ছবি';

  @override
  String get pictureNone => 'এই পণ্যের কোনো ছবি নেই';

  @override
  String get pictureFailed => 'ছবিটি লোড করা যায়নি';

  @override
  String pictureOf(String name) {
    return '$name-এর ছবি';
  }

  @override
  String get pictureOpenHint => 'ছবিটি পূর্ণ পর্দায় খোলে';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get badgeGenuine => 'আসল';

  @override
  String get detailsProductTitle => 'পণ্যের বিবরণ';

  @override
  String checkNumber(int count) {
    return 'যাচাই $count';
  }

  @override
  String get previousCheckLabel => 'আগের যাচাই';

  @override
  String get checkedByLabel => 'আগে যাচাই করেছেন';

  @override
  String get enteredTitle => 'আপনি যা দিয়েছেন';

  @override
  String get checkedAtLabel => 'যাচাইয়ের সময়';

  @override
  String get resultRowLabel => 'ফলাফল';

  @override
  String get hintsTitle => 'পরামর্শ';

  @override
  String get hintScanQr => 'লেখার বদলে QR কোড স্ক্যান করুন।';

  @override
  String get tryAgainLookup => 'আবার চেষ্টা করুন';

  @override
  String get contactSupport => 'সহায়তায় যোগাযোগ করুন';

  @override
  String get backToVerify => 'যাচাইয়ে ফিরে যান';

  @override
  String get backToList => 'তালিকায় ফিরুন';

  @override
  String supportEmailSubject(String ref) {
    return 'পণ্য পাওয়া যায়নি: $ref';
  }

  @override
  String supportEmailBody(String ref, String way, String value, String time) {
    return 'রেফারেন্স: $ref\n$way: $value\nযাচাইয়ের সময়: $time';
  }

  @override
  String get verifyingTitle => 'পণ্যটি যাচাই হচ্ছে…';

  @override
  String get verifyingBody =>
      'কোম্পানির রেকর্ডের সাথে মেলানো হচ্ছে। সাধারণত এক সেকেন্ডের কম সময় লাগে।';

  @override
  String get stepCodeFormat => 'কোডের ফরম্যাট';

  @override
  String get stepItemRecord => 'পণ্যের রেকর্ড';

  @override
  String get stepCheckCount => 'যাচাইয়ের সংখ্যা';

  @override
  String get stepDone => 'সম্পন্ন';

  @override
  String get stepWaiting => 'অপেক্ষমাণ';

  @override
  String get accessPending =>
      'আপনার আবেদন পাঠানো হয়েছে। উত্তর দেওয়া হলে আপনি একটি ইমেইল পাবেন।';

  @override
  String get accessWrongCode =>
      'কোডটি ভুল বা মেয়াদ শেষ। প্রয়োজনে নতুন কোড নিন।';

  @override
  String get accessTryLater =>
      'পরে আবার চেষ্টা করুন। আবার আবেদন পাঠানোর আগে নতুন কোড নিন।';

  @override
  String get accessRoleUnavailable =>
      'এই ভূমিকা এখন আর পাওয়া যাচ্ছে না। অন্য একটি বেছে নিন।';

  @override
  String get accessNoRoles => 'অ্যাকাউন্টের জন্য অফিসে যোগাযোগ করুন।';

  @override
  String get accessContactOffice => 'অফিসে যোগাযোগ করুন।';

  @override
  String get accessName => 'নাম';

  @override
  String get accessRole => 'ভূমিকা';

  @override
  String get accessRoleHint => 'একটি ভূমিকা বেছে নিন';

  @override
  String get accessPassword => 'পাসওয়ার্ড বেছে নিন';

  @override
  String get accessShowPassword => 'পাসওয়ার্ড দেখুন';

  @override
  String get accessHidePassword => 'পাসওয়ার্ড লুকান';

  @override
  String get accessEmail => 'ইমেইল';

  @override
  String get accessCode => 'ইমেইলের কোড';

  @override
  String get accessResend => 'নতুন কোড পাঠান';

  @override
  String get accessSendCode => 'কোড পাঠান';

  @override
  String get accessCodeSent => 'ঠিকানায় একটি কোড পাঠানো হয়েছে।';

  @override
  String get accessSubmit => 'আবেদন পাঠান';

  @override
  String get scannerModeTitle => 'স্ক্যানার মোড';

  @override
  String get serialStackTitle => 'সিরিয়ালের তালিকা';

  @override
  String get serialStackHint =>
      'সর্বোচ্চ ৫০টি সিরিয়াল লিখুন বা পেস্ট করুন। স্পেস, কমা বা নতুন লাইন দিয়ে আলাদা করুন। একই সিরিয়াল একবারই যাচাই হবে।';

  @override
  String get serialStackLimit =>
      '১ থেকে ৫০টি ভিন্ন সিরিয়াল দিন। আরও পণ্যের জন্য নতুন তালিকা পাঠান।';

  @override
  String get serialStackUncertain =>
      'উত্তর পাওয়া যায়নি। যাচাইগুলো ইতিমধ্যে সংরক্ষিত হতে পারে। আবার পাঠালে পুনরায় সংরক্ষিত হতে পারে।';

  @override
  String get serialStackNotSent =>
      'সংযোগ নেই। কিছুই পাঠানো হয়নি; অনলাইনে এলে তালিকাটি আবার পাঠান।';

  @override
  String serialStackBadSerial(int position, String value, int digits) {
    return '$position নম্বর ($value) সিরিয়াল নয়: শুধু সংখ্যা, সর্বোচ্চ $digits অঙ্ক।';
  }

  @override
  String serialStackCount(int count) {
    return '৫০টির মধ্যে $countটি সিরিয়াল';
  }

  @override
  String serialStackCountRepeats(int count, int repeats) {
    return '৫০টির মধ্যে $countটি সিরিয়াল · $repeatsটি পুনরাবৃত্ত, একবার পাঠানো হবে';
  }

  @override
  String get serialStackRecorded =>
      'যাচাইগুলো রেকর্ড হয়েছে, কিন্তু উত্তর দেখানো যায়নি। ইতিহাস → সেশনে দেখুন। একই তালিকা আবার পাঠাবেন না।';

  @override
  String get serialStackRetry => 'একই তালিকা আবার পাঠান';

  @override
  String get serialStackSubmit => 'সিরিয়াল যাচাই করুন';

  @override
  String get serialStackNew => 'নতুন তালিকা শুরু করুন';

  @override
  String get serialStackHistory => 'এই সেশনের যাচাই দেখুন';

  @override
  String get sessionScanned => 'যাচাই হয়েছে';

  @override
  String get sessionValid => 'সঠিক';

  @override
  String get sessionWarning => 'সতর্কতা';

  @override
  String get sessionNotFound => 'পাওয়া যায়নি';

  @override
  String get sessionUnassigned => 'বরাদ্দ হয়নি';

  @override
  String get sessionLeft => 'অবশিষ্ট';

  @override
  String get sessionRepeat => 'ইতিমধ্যে স্ক্যান হয়েছে';

  @override
  String get sessionScanAgain => 'আবার স্ক্যান করুন';

  @override
  String get sessionNoConnection => 'সংযোগ নেই, আবার স্ক্যান করুন।';

  @override
  String get sessionBusy =>
      'সেবাটি ব্যস্ত। কিছুই রেকর্ড হয়নি; আবার স্ক্যান করুন।';

  @override
  String get sessionRestarted => 'একটি নতুন সেশন শুরু হয়েছে।';

  @override
  String get sessionsTitle => 'সেশন';

  @override
  String get sessionsMore => 'আরও দেখুন';

  @override
  String get sessionsAll => 'সব';

  @override
  String get sessionsOpen => 'চলমান';

  @override
  String get sessionsEnded => 'সমাপ্ত';

  @override
  String get sessionsDates => 'তারিখ বেছে নিন';

  @override
  String get sessionsLastSevenDays => 'গত ৭ দিনের তথ্য দেখানো হচ্ছে';

  @override
  String get sessionsEmpty => 'কোনো সেশন পাওয়া যায়নি।';

  @override
  String get historyChecksView => 'যাচাই';

  @override
  String get sessionsStarted => 'শুরু';

  @override
  String get sessionsLastScan => 'শেষ স্ক্যান';

  @override
  String get sessionChecksTitle => 'সেশনের যাচাই';

  @override
  String get rateLimitedUnknown =>
      'অতিরিক্ত চেষ্টা হয়েছে। পরে আবার চেষ্টা করুন।';

  @override
  String get sessionRowsFailed => 'এই সেশনের স্ক্যানগুলো লোড করা যায়নি।';

  @override
  String get reportPhotoSame => 'এই ছবিটি রিপোর্টে আগেই আছে।';

  @override
  String get reportUnreadable =>
      'রিপোর্টটি পাঠানো হয়েছে, কিন্তু উত্তরটি পড়া যায়নি। এটি হয়তো জমা হয়েছে: আবার জমা দেওয়ার আগে আমার রিপোর্ট দেখুন।';

  @override
  String get reportCheckGone =>
      'চেকটি পাওয়া যায়নি। এটি সরিয়ে আবার চেষ্টা করুন।';

  @override
  String get reportRetailUserGone =>
      'এই খুচরা ব্যবহারকারীর নাম আর দেওয়া যাবে না। অন্য একজন বেছে নিন, অথবা ছাড়াই জমা দিন।';

  @override
  String get sessionResumedCounts =>
      'সেশন আবার চালু হয়েছে। পরের স্ক্যানের পর গণনা দেখা যাবে।';

  @override
  String get sessionChecking => 'যাচাই হচ্ছে…';

  @override
  String sessionCheckingMore(int count) {
    return 'যাচাই হচ্ছে… আরও $countটি';
  }

  @override
  String get sessionFinish => 'শেষ করুন';

  @override
  String get sessionFinishing => 'শেষ স্ক্যানগুলো যাচাই হচ্ছে…';

  @override
  String get sessionSummaryTitle => 'সেশন শেষ হয়েছে';

  @override
  String sessionSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countটি পণ্য স্ক্যান হয়েছে',
      one: '১টি পণ্য স্ক্যান হয়েছে',
    );
    return '$_temp0';
  }

  @override
  String get sessionScanMore => 'আরও স্ক্যান';

  @override
  String get sessionDone => 'সম্পন্ন';

  @override
  String sessionNotChecked(int count) {
    return 'আরও $countটি স্ক্যান যাচাই হয়নি। আবার স্ক্যান করুন।';
  }

  @override
  String get typeSerialLabel => 'অথবা সিরিয়াল লিখুন';

  @override
  String get scanNotReady => 'কোডের ফরম্যাট লোড হলে স্ক্যান শুরু হবে।';

  @override
  String copyrightNotice(String year) {
    return '© $year Ziska Pharmaceuticals Ltd. সর্বস্বত্ব সংরক্ষিত।';
  }

  @override
  String appVersionShort(String version, String build) {
    return 'সংস্করণ $version ($build)';
  }

  @override
  String get offlineBanner => 'ইন্টারনেট সংযোগ নেই। যাচাই করতে সংযোগ প্রয়োজন।';
}
