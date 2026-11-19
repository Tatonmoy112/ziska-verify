// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

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
  String get requestAccessButton => 'Sign up';

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
      'Your password was set by someone else. Choose your own now, or later from Profile.';

  @override
  String get changePasswordLater => 'Not now';

  @override
  String get passwordLaterRefused =>
      'Not now is not available for your account. Choose a new password or log out.';

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
  String get ruleNoControl => 'no tabs or line breaks';

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
  String get resetCodeWrong =>
      'The code is wrong or has expired. Ask for a new code.';

  @override
  String get resetNewCode => 'Send a new code';

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
  String get requestAccessTitle => 'Sign up';

  @override
  String get requestAccessSubtitle =>
      'Create your account. Your office checks it and emails you when it is approved.';

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
  String get permissionsSection => 'WHAT YOU CAN DO';

  @override
  String get permissionLookup => 'Check one item';

  @override
  String get permissionBulkLookup => 'Check many items';

  @override
  String get permissionHistory => 'Own history';

  @override
  String get permissionReport => 'Report incidents';

  @override
  String get permissionsNone => 'None. Ask your office.';

  @override
  String get accountSection => 'ACCOUNT';

  @override
  String get statChecks => 'Checks';

  @override
  String get statValid => 'Valid';

  @override
  String get statNotVerified => 'Needs attention';

  @override
  String get statsFailed => 'Your counts couldn\'t load.';

  @override
  String get changePasswordRow => 'Change password';

  @override
  String get passwordPendingBanner =>
      'Your password was set by someone else. Change it to keep your account safe.';

  @override
  String get supportContactRow => 'Support contact';

  @override
  String get supportNotSet => 'Not set by your office';

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
  String get wayOther => 'Other';

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
  String get historyInSession => 'In a session';

  @override
  String get historyEmptyBody => 'No check matches these filters.';

  @override
  String get historyNoChecksYet =>
      'Your checks appear here after your first check.';

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
  String get reportChooseCheck => 'Link one of your checks (optional)';

  @override
  String get pickCheck => 'Choose a check';

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
      'No more photos: the report has 3, or its hour is over.';

  @override
  String get reportLeaveTitle => 'Photos not sent';

  @override
  String get reportLeaveBody =>
      'Some photos are still sending or can be sent again. If you leave, they are not sent.';

  @override
  String get reportStay => 'Stay';

  @override
  String get reportLeave => 'Leave';

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
  String get reportCheckMyReports => 'Check My reports';

  @override
  String get myReportsTitle => 'My reports';

  @override
  String get myReportsEmpty => 'You have not filed any report yet.';

  @override
  String get myReportsEmptyBody =>
      'Reports you file appear here. Use New report to file one.';

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
  String get backToList => 'Back to the list';

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
      'Thanks for signing up. Your office will check your details and email you when your account is ready.';

  @override
  String get accessWrongCode =>
      'The code is wrong or expired. Request a new code if needed.';

  @override
  String get accessTryLater =>
      'Try again later. Get a new code before you sign up again.';

  @override
  String get accessRoleUnavailable =>
      'This role is no longer available. Choose another role.';

  @override
  String get accessNoRoles => 'Ask the office for an account.';

  @override
  String get accessContactOffice => 'Contact the office';

  @override
  String get accessName => 'Name';

  @override
  String get accessRole => 'Role';

  @override
  String get accessRoleHint => 'Choose a role';

  @override
  String get accessPassword => 'Choose a password';

  @override
  String get accessShowPassword => 'Show password';

  @override
  String get accessHidePassword => 'Hide password';

  @override
  String get accessEmail => 'Email';

  @override
  String get accessCode => 'Code from the email';

  @override
  String get accessResend => 'Send a new code';

  @override
  String get accessSendCode => 'Send code';

  @override
  String get accessCodeSent => 'A code was sent to the address.';

  @override
  String get accessSubmit => 'Sign up';

  @override
  String get scannerModeTitle => 'Scanner mode';

  @override
  String get serialStackTitle => 'Serial stack';

  @override
  String get serialStackHint =>
      'Type or paste up to 50 serials, separated by spaces, commas, or new lines. Repeated serials are checked once.';

  @override
  String get serialStackLimit =>
      'Enter 1 to 50 different serials. Submit another stack for additional items.';

  @override
  String get serialStackUncertain =>
      'The answer was lost. These checks may already be recorded. Retrying may record them again.';

  @override
  String get serialStackNotSent =>
      'No connection. Nothing was sent; send the stack again when you are online.';

  @override
  String serialStackBadSerial(int position, String value, int digits) {
    return 'Serial $position ($value) is not a serial: digits only, up to $digits digits.';
  }

  @override
  String serialStackCount(int count) {
    return '$count of 50 serials';
  }

  @override
  String serialStackCountRepeats(int count, int repeats) {
    return '$count of 50 serials · $repeats repeated, sent once';
  }

  @override
  String get serialStackRecorded =>
      'These checks were recorded, but their answer could not be shown. See them in History → Sessions. Do not send the same stack again.';

  @override
  String get serialStackRetry => 'Send the same stack again';

  @override
  String get serialStackSubmit => 'Check serials';

  @override
  String get serialStackNew => 'Start another stack';

  @override
  String get serialStackHistory => 'View this session\'s checks';

  @override
  String get sessionScanned => 'Scanned';

  @override
  String get sessionValid => 'Valid';

  @override
  String get sessionWarning => 'Warning';

  @override
  String get sessionNotFound => 'Not found';

  @override
  String get sessionUnassigned => 'Not in a batch';

  @override
  String get sessionLeft => 'Remaining';

  @override
  String get sessionRepeat => 'Already scanned';

  @override
  String get sessionScanAgain => 'Scan again';

  @override
  String get sessionNoConnection => 'No connection, scan again.';

  @override
  String get sessionBusy =>
      'The service is busy. Nothing was recorded; scan again.';

  @override
  String get sessionRestarted => 'A new session started.';

  @override
  String get sessionsTitle => 'Sessions';

  @override
  String get sessionsMore => 'Load more';

  @override
  String get sessionsAll => 'All';

  @override
  String get sessionsOpen => 'Open';

  @override
  String get sessionsEnded => 'Ended';

  @override
  String get sessionsDates => 'Choose dates';

  @override
  String get sessionsLastSevenDays => 'Showing the last 7 days';

  @override
  String get sessionsEmpty => 'No sessions found.';

  @override
  String get historyChecksView => 'Checks';

  @override
  String get sessionsStarted => 'Started';

  @override
  String get sessionsLastScan => 'Last scan';

  @override
  String get sessionChecksTitle => 'Session checks';

  @override
  String get rateLimitedUnknown => 'Too many attempts. Try again later.';

  @override
  String get sessionRowsFailed => 'Couldn\'t load this session\'s scans.';

  @override
  String get reportPhotoSame => 'That photo is already on the report.';

  @override
  String get reportUnreadable =>
      'The report was sent, but its answer could not be read. It may have been filed: check My reports before filing it again.';

  @override
  String get reportCheckGone =>
      'The check was not found. Remove it and try again.';

  @override
  String get reportRetailUserGone =>
      'This retail user can no longer be named. Choose another, or file without one.';

  @override
  String get sessionResumedCounts =>
      'Resumed session. The counts show after the next scan.';

  @override
  String get sessionChecking => 'Checking…';

  @override
  String sessionCheckingMore(int count) {
    return 'Checking… $count more';
  }

  @override
  String sessionNotChecked(int count) {
    return '$count more scans were not checked. Scan them again.';
  }

  @override
  String get typeSerialLabel => 'Or type the serial';

  @override
  String get scanNotReady => 'Scanning waits for the code formats.';

  @override
  String copyrightNotice(String year) {
    return '© $year Ziska Pharmaceuticals Ltd. All rights reserved.';
  }

  @override
  String appVersionShort(String version, String build) {
    return 'Version $version ($build)';
  }
}
