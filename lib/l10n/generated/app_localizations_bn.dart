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
  String get appSubtitle => 'Product Authenticity Check';

  @override
  String get splashTagline => 'Check genuine products instantly';

  @override
  String get brandTagline => 'TRACK · TRACE · CHECK';

  @override
  String get loginTitle => 'Login to Track & Trace';

  @override
  String get loginSubtitle =>
      'Enter your email and password to check products.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get loginButton => 'Login securely';

  @override
  String get noAccountDivider => 'NO ACCOUNT?';

  @override
  String get noAccountQuestion => 'Don\'t have an account?';

  @override
  String get requestAccessButton => 'সাইন আপ';

  @override
  String get authorizedOnly => 'Only authorized users can access this system';

  @override
  String get loginFailed => 'Email or password is incorrect.';

  @override
  String get fieldRequired => 'Required';

  @override
  String get emailInvalid => 'Enter a valid email address';

  @override
  String get verifyCodeTitle => 'Check your email';

  @override
  String verifyCodeSubtitle(String email) {
    return 'We sent a 6-digit code to $email. Enter it to trust this phone.';
  }

  @override
  String get codeLabel => 'Code from the email';

  @override
  String get verifyButton => 'Continue';

  @override
  String get codeWrong =>
      'The code is wrong or has expired. Check the latest email, or send the code again.';

  @override
  String get resendCode => 'Send the code again';

  @override
  String resendIn(int seconds) {
    return 'Send again in $seconds s';
  }

  @override
  String get codeResent => 'A new code was sent.';

  @override
  String get resendLimitReached => 'No more codes can be sent. Log in again.';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get changePasswordTitle => 'Set a new password';

  @override
  String get changePasswordForcedSubtitle =>
      'Your password was set by someone else. Choose your own password to continue.';

  @override
  String get changePasswordChoiceSubtitle =>
      'আপনার পাসওয়ার্ড অন্য কেউ সেট করেছে। এখনই নিজের পাসওয়ার্ড বেছে নিন, অথবা পরে প্রোফাইল থেকে।';

  @override
  String get changePasswordLater => 'এখন নয়';

  @override
  String get passwordLaterRefused =>
      'আপনার অ্যাকাউন্টে \"এখন নয়\" নেই। নতুন পাসওয়ার্ড বেছে নিন বা লগ আউট করুন।';

  @override
  String get changePasswordSubtitle =>
      'Choose a new password. Your other phones will be logged out.';

  @override
  String get currentPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Repeat new password';

  @override
  String get passwordsDoNotMatch => 'The passwords do not match';

  @override
  String get changePasswordButton => 'Save password';

  @override
  String get currentPasswordWrong => 'The current password is incorrect.';

  @override
  String get passwordChanged => 'Your password was changed.';

  @override
  String get logout => 'Log out';

  @override
  String get ruleLength => '8 characters or more';

  @override
  String get ruleLetter => 'a letter';

  @override
  String get ruleNumber => 'a number';

  @override
  String get ruleNoControl => 'ট্যাব বা লাইন ব্রেক নয়';

  @override
  String get passwordRuleBroken =>
      'The password does not meet the rules below.';

  @override
  String get forgotTitle => 'Forgot password';

  @override
  String get forgotSubtitle =>
      'Enter your email. If it has an account, we will send a 6-digit code.';

  @override
  String get sendCodeButton => 'Send code';

  @override
  String get forgotSent => 'If the address has an account, a code was sent.';

  @override
  String get resetTitle => 'Reset password';

  @override
  String get resetCodeWrong => 'কোডটি ভুল বা মেয়াদোত্তীর্ণ। নতুন কোড চান।';

  @override
  String get resetNewCode => 'নতুন কোড পাঠান';

  @override
  String resetSubtitle(String email) {
    return 'If $email has an account, a code was sent to it. Enter the code and choose a new password.';
  }

  @override
  String get resetButton => 'Reset password';

  @override
  String get resetDone =>
      'Password changed. Log in with your new password; every phone needs the emailed code at its next login.';

  @override
  String get requestAccessTitle => 'সাইন আপ';

  @override
  String get requestAccessSubtitle =>
      'আপনার অ্যাকাউন্ট তৈরি করুন। অফিস যাচাই করে অনুমোদন হলে ইমেইলে জানাবে।';

  @override
  String noPhoneApp(String phone) {
    return 'No phone app found. Call $phone.';
  }

  @override
  String noMailApp(String email) {
    return 'No email app found. Write to $email.';
  }

  @override
  String get welcomeBack => 'Welcome back,';

  @override
  String get loadingProfile => 'Loading your profile…';

  @override
  String get retry => 'Try again';

  @override
  String get errorNetwork => 'No connection. Check the internet and try again.';

  @override
  String errorRateLimited(int seconds) {
    return 'Too many attempts. Try again in $seconds s.';
  }

  @override
  String get errorPreparing => 'The app is being prepared. Try again later.';

  @override
  String get errorUnavailable => 'The service is busy. Try again shortly.';

  @override
  String get errorNotAvailable => 'Not available.';

  @override
  String get errorGeneral => 'Something went wrong. Try again.';

  @override
  String reference(String id) {
    return 'Reference: $id';
  }

  @override
  String get tabVerify => 'Check';

  @override
  String get tabHistory => 'History';

  @override
  String get tabProfile => 'Profile';

  @override
  String get noFeaturesTitle => 'No features yet';

  @override
  String get noFeaturesBody =>
      'Your role does not allow any features yet. Contact your office.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get organisationLabel => 'Organization';

  @override
  String get roleLabel => 'Role';

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
  String get accountSection => 'ACCOUNT';

  @override
  String get statChecks => 'Checks';

  @override
  String get statValid => 'Valid';

  @override
  String get statNotVerified => 'মনোযোগ দরকার';

  @override
  String get statsFailed => 'Your counts couldn\'t load.';

  @override
  String get changePasswordRow => 'Change password';

  @override
  String get passwordPendingBanner =>
      'আপনার পাসওয়ার্ড অন্য কেউ সেট করেছে। অ্যাকাউন্ট নিরাপদ রাখতে এটি বদলান।';

  @override
  String get supportContactRow => 'Support contact';

  @override
  String get supportNotSet => 'আপনার অফিস সেট করেনি';

  @override
  String get appVersionRow => 'App version';

  @override
  String appVersionValue(String version, String build) {
    return 'v$version · build $build';
  }

  @override
  String get logoutConfirmTitle => 'Log out?';

  @override
  String get logoutConfirmBody =>
      'This phone stays trusted, so the next login needs no emailed code.';

  @override
  String get cancel => 'Cancel';

  @override
  String get verifyItemTitle => 'Check authenticity';

  @override
  String get waySerial => 'Serial';

  @override
  String get wayHiddenCode => 'Hidden code';

  @override
  String get wayQr => 'QR code';

  @override
  String get wayOther => 'অন্যান্য';

  @override
  String serialHint(int digits) {
    return 'Up to $digits digits';
  }

  @override
  String get verifyButtonLookup => 'Check';

  @override
  String get clear => 'Clear';

  @override
  String get scanFrameHint => 'Place the QR code inside the frame';

  @override
  String get scanLooking => 'Looking for a QR code · hold steady';

  @override
  String get inputEmpty => 'Enter a value first';

  @override
  String inputWrongSerial(int digits) {
    return 'A serial has digits only, up to $digits digits.';
  }

  @override
  String get notProductQr =>
      'This QR code is not a product code of this company.';

  @override
  String get formatsFailed => 'Could not load the code formats.';

  @override
  String get lookupNetworkError =>
      'Unable to check. Check the connection and try again.';

  @override
  String get verifying => 'Checking…';

  @override
  String get toolsTitle => 'MORE';

  @override
  String get toolReport => 'Report incident';

  @override
  String get toolMyReports => 'My reports';

  @override
  String get scannerPermissionDenied =>
      'Camera access is off. Allow it in Settings to scan QR codes.';

  @override
  String get scannerUnsupported =>
      'This phone cannot scan QR codes. Type the serial instead.';

  @override
  String get scannerFailed => 'The camera could not start.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get torch => 'Torch';

  @override
  String get resultTitle => 'Check result';

  @override
  String get resultValidTitle => 'Genuine product';

  @override
  String get resultValidBody =>
      'First check by any official. Nothing is wrong with this item.';

  @override
  String get resultWarningTitle => 'Genuine, needs attention';

  @override
  String get resultWarningBody => 'Read every reason below.';

  @override
  String get resultNotFoundTitle => 'Not found';

  @override
  String get resultNotFoundBody =>
      'No product of this company has this serial or QR code.';

  @override
  String get resultUnassignedTitle => 'Not in a batch';

  @override
  String get resultUnassignedBody =>
      'This item exists but has not been given to a batch yet.';

  @override
  String get resultUnknownTitle => 'Unable to check';

  @override
  String get resultUnknownBody =>
      'This result is not known to this app version. Update the app or contact your office.';

  @override
  String get reasonCheckedBefore => 'Checked before';

  @override
  String reasonCheckedBeforeDetail(int count, String when) {
    return 'This is check number $count of this item. Last check: $when.';
  }

  @override
  String get reasonRecalled => 'Batch recalled';

  @override
  String get reasonExpired => 'Expired';

  @override
  String get reasonDamaged => 'Marked damaged';

  @override
  String get reasonSwitchedOff => 'Batch switched off';

  @override
  String get reasonUnknown => 'Needs attention';

  @override
  String get referenceNumber => 'Reference number';

  @override
  String get productLabel => 'Product';

  @override
  String get genericLabel => 'Generic name';

  @override
  String get shortNameLabel => 'Short name';

  @override
  String get serialLabel => 'Serial';

  @override
  String get codeLabel2 => 'Hidden code';

  @override
  String get batchLabel => 'Batch';

  @override
  String get madeLabel => 'Made';

  @override
  String get expiresLabel => 'Expires';

  @override
  String get verifyAnother => 'Check another item';

  @override
  String get copied => 'Copied';

  @override
  String get copyReference => 'Copy reference number';

  @override
  String get bulkValid => 'Valid';

  @override
  String get bulkWarning => 'Warning';

  @override
  String get bulkNotFound => 'Not found';

  @override
  String get bulkUnassigned => 'Not in a batch';

  @override
  String get removeItem => 'Remove';

  @override
  String get clearSearch => 'Clear the search';

  @override
  String get historySearchHint => 'Search a serial or a reference number';

  @override
  String get historyFilters => 'Filters';

  @override
  String get historyApply => 'Apply';

  @override
  String get historyReset => 'Reset';

  @override
  String get historyWay => 'Way';

  @override
  String get historyDates => 'Dates';

  @override
  String get historyAny => 'Any';

  @override
  String get historyPickDates => 'Choose dates';

  @override
  String get historyEmptyTitle => 'No checks';

  @override
  String get historyInSession => 'একটি সেশনে';

  @override
  String get historyEmptyBody => 'No check matches these filters.';

  @override
  String get historyNoChecksYet =>
      'প্রথম যাচাইয়ের পর আপনার যাচাইগুলো এখানে দেখা যাবে।';

  @override
  String get historyAll => 'All';

  @override
  String get historyToday => 'Today';

  @override
  String get historyYesterday => 'Yesterday';

  @override
  String get historyItemTitle => 'Item';

  @override
  String get historyTrackingLog => 'Tracking log';

  @override
  String historyCheckCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count checks',
      one: '1 check',
    );
    return '$_temp0';
  }

  @override
  String historyTracking(String serial) {
    return 'Your checks of serial $serial';
  }

  @override
  String get pickRetailUser => 'Choose a retail user';

  @override
  String get pickRetailUserHint => 'Part of a name, or a whole email';

  @override
  String get pickRetailUserEmpty => 'No retail user found';

  @override
  String get reportTitle => 'Report incident';

  @override
  String get reportWhenNotNeeded =>
      'No report is needed for a warning: a recalled, expired, damaged, or switched-off item is already sent to your office by the lookup. Report what a lookup cannot see, such as a fake-looking label or a torn seal.';

  @override
  String get reportNoteLabel => 'What did you find?';

  @override
  String get reportNoteHint => 'Describe the problem';

  @override
  String get reportCheckLabel => 'Check';

  @override
  String get reportRetailUserLabel => 'Retail user';

  @override
  String get reportChooseRetailUser => 'Choose a retail user (optional)';

  @override
  String get reportChooseCheck => 'আপনার একটি যাচাই যুক্ত করুন (ঐচ্ছিক)';

  @override
  String get pickCheck => 'একটি যাচাই বেছে নিন';

  @override
  String get reportPhotosLabel => 'Photos';

  @override
  String get reportPhotosHint =>
      'Up to 3 photos. Location and other details in the photo are removed.';

  @override
  String get reportAddPhoto => 'Add photo';

  @override
  String get reportCamera => 'Take a photo';

  @override
  String get reportGallery => 'Choose from gallery';

  @override
  String get reportFile => 'File report';

  @override
  String reportFiled(int id) {
    return 'Report $id filed.';
  }

  @override
  String get reportPhotoFailedRetry => 'Not sent. Tap to send again.';

  @override
  String get reportPhotoRefused => 'This photo was refused.';

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
    return 'Photo $n';
  }

  @override
  String get reportPhotoTooLarge =>
      'This photo is too large even after shrinking.';

  @override
  String get reportPhotoUnreadable =>
      'This photo could not be read. Try another.';

  @override
  String get reportPhotoWindowOver =>
      'Photos can be added only within an hour of the report.';

  @override
  String get reportDone => 'Done';

  @override
  String get reportUnconfirmed =>
      'The connection dropped. The report may have been filed: check My reports before filing it again.';

  @override
  String get reportCheckMyReports => 'আমার রিপোর্ট দেখুন';

  @override
  String get myReportsTitle => 'My reports';

  @override
  String get myReportsEmpty => 'You have not filed any report yet.';

  @override
  String get myReportsEmptyBody =>
      'আপনার পাঠানো রিপোর্ট এখানে দেখা যাবে। পাঠাতে নতুন রিপোর্ট ব্যবহার করুন।';

  @override
  String myReportsPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
      zero: 'No photos',
    );
    return '$_temp0';
  }

  @override
  String get newReport => 'New report';

  @override
  String get reportFromResult => 'Report incident';

  @override
  String get pictureTitle => 'Product image';

  @override
  String get pictureNone => 'No picture for this product';

  @override
  String get pictureFailed => 'The picture could not be loaded';

  @override
  String pictureOf(String name) {
    return 'Picture of $name';
  }

  @override
  String get pictureOpenHint => 'Opens the picture full screen';

  @override
  String get close => 'Close';

  @override
  String get badgeGenuine => 'Genuine';

  @override
  String get detailsProductTitle => 'Product details';

  @override
  String checkNumber(int count) {
    return 'Check $count';
  }

  @override
  String get previousCheckLabel => 'Previous check';

  @override
  String get checkedByLabel => 'Checked before by';

  @override
  String get enteredTitle => 'What you entered';

  @override
  String get checkedAtLabel => 'Checked at';

  @override
  String get resultRowLabel => 'Result';

  @override
  String get hintsTitle => 'Hints';

  @override
  String get hintScanQr => 'Scan the QR code instead of typing.';

  @override
  String get tryAgainLookup => 'Try again';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get backToVerify => 'Back to Check';

  @override
  String get backToList => 'তালিকায় ফিরুন';

  @override
  String supportEmailSubject(String ref) {
    return 'Item not found: $ref';
  }

  @override
  String supportEmailBody(String ref, String way, String value, String time) {
    return 'Reference: $ref\n$way: $value\nChecked at: $time';
  }

  @override
  String get verifyingTitle => 'Checking the item…';

  @override
  String get verifyingBody =>
      'Checked against the company\'s records. This usually takes under a second.';

  @override
  String get stepCodeFormat => 'Code format';

  @override
  String get stepItemRecord => 'Item record';

  @override
  String get stepCheckCount => 'Check count';

  @override
  String get stepDone => 'done';

  @override
  String get stepWaiting => 'waiting';

  @override
  String get accessPending =>
      'সাইন আপের জন্য ধন্যবাদ। অফিস আপনার তথ্য যাচাই করে অ্যাকাউন্ট প্রস্তুত হলে ইমেইলে জানাবে।';

  @override
  String get accessWrongCode =>
      'কোডটি ভুল বা মেয়াদ শেষ। প্রয়োজনে নতুন কোড নিন।';

  @override
  String get accessTryLater =>
      'পরে আবার চেষ্টা করুন। আবার সাইন আপের আগে নতুন কোড নিন।';

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
  String get accessSubmit => 'সাইন আপ';

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
}
