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
  String get appSubtitle => 'Product Verification System';

  @override
  String get splashTagline => 'Verify genuine products instantly';

  @override
  String get brandTagline => 'TRACK · TRACE · VERIFY';

  @override
  String get loginTitle => 'Login to Track & Trace';

  @override
  String get loginSubtitle =>
      'Enter your email and password to verify products.';

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
  String get noAccountQuestion => 'Don\'t have an ID and password?';

  @override
  String get requestAccessButton => 'Contact us to request access';

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
  String get codeLabel => 'Verification code';

  @override
  String get verifyButton => 'Verify';

  @override
  String get codeWrong =>
      'The code is wrong or has expired. Check the latest email, or log in again for a new code.';

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
  String resetSubtitle(String email) {
    return 'Enter the code sent to $email and choose a new password.';
  }

  @override
  String get resetButton => 'Reset password';

  @override
  String get resetDone => 'Password changed. Log in with your new password.';

  @override
  String get requestAccessTitle => 'Request access';

  @override
  String get requestAccessSubtitle =>
      'Accounts are created by your office. Email or call them with the details below.';

  @override
  String get pleaseInclude => 'Please include';

  @override
  String get includeName => 'Full name';

  @override
  String get includeOrganisation => 'Organization';

  @override
  String get includePhone => 'Phone number';

  @override
  String get includeEmail => 'Email address';

  @override
  String get includeReason => 'Reason for access';

  @override
  String get includeJobTitle => 'Job title';

  @override
  String get emailTeamButton => 'Email the office';

  @override
  String get callTeamButton => 'Call the office';

  @override
  String get accessRequestSubject => 'Access request';

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
  String get tabVerify => 'Verify';

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
  String get comingSoon => 'This part of the app is being built.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get organisationLabel => 'Organization';

  @override
  String get roleLabel => 'Role';

  @override
  String get accountSection => 'ACCOUNT';

  @override
  String get statChecks => 'Checks';

  @override
  String get statValid => 'Valid';

  @override
  String get statNotVerified => 'Not verified';

  @override
  String get statsFailed => 'Your counts couldn\'t load.';

  @override
  String get changePasswordRow => 'Change password';

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
  String get howItWorks => 'How it works';

  @override
  String get requestStepSendTitle => 'Send your request';

  @override
  String get requestStepSendBody =>
      'Email or call the office with the details below.';

  @override
  String get requestStepSendBodyEmailOnly =>
      'Email the office with the details below.';

  @override
  String get requestStepCheckTitle => 'Your office checks it';

  @override
  String get requestStepCheckBody =>
      'An administrator checks your request and creates your account.';

  @override
  String get requestStepLoginTitle => 'Receive your login';

  @override
  String get requestStepLoginBody =>
      'Your first password is emailed to you or given to you in person. You change it at your first login.';

  @override
  String get verifyItemTitle => 'Verify an item';

  @override
  String get verifyItemSubtitle =>
      'Type the serial or the hidden code, or scan the QR code.';

  @override
  String get waySerial => 'Serial';

  @override
  String get wayHiddenCode => 'Hidden code';

  @override
  String get wayQr => 'QR code';

  @override
  String serialHint(int digits) {
    return 'Up to $digits digits';
  }

  @override
  String get hiddenCodeHint => 'The code under the scratch layer';

  @override
  String get verifyButtonLookup => 'Verify product';

  @override
  String get clear => 'Clear';

  @override
  String get scanQrTitle => 'Scan QR code';

  @override
  String get scanQrSubtitle => 'Point your camera at the product\'s QR code';

  @override
  String get scanFrameHint => 'Place the QR code inside the frame';

  @override
  String get scanLooking => 'Looking for a QR code · hold steady';

  @override
  String get enterManually => 'Enter manually';

  @override
  String get inputEmpty => 'Enter a value first';

  @override
  String inputWrongSerial(int digits) {
    return 'A serial has digits only, up to $digits digits.';
  }

  @override
  String get inputWrongHiddenCode =>
      'This is not a hidden code of this company. Check each character.';

  @override
  String get notProductQr =>
      'This QR code is not a product code of this company.';

  @override
  String get formatsFailed => 'Could not load the code formats.';

  @override
  String get lookupNetworkError =>
      'Unable to verify. Check the connection and try again.';

  @override
  String get verifying => 'Verifying…';

  @override
  String get toolsTitle => 'MORE';

  @override
  String get toolBulk => 'Bulk lookup';

  @override
  String get toolReport => 'Report incident';

  @override
  String get toolMyReports => 'My reports';

  @override
  String get toolRetailUsers => 'Retail users';

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
  String get resultTitle => 'Verification result';

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
  String get resultNotFoundBody => 'No product of this company has this code.';

  @override
  String get resultUnassignedTitle => 'Not in a batch';

  @override
  String get resultUnassignedBody =>
      'This item exists but has not been given to a batch yet.';

  @override
  String get resultUnknownTitle => 'Unable to verify';

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
  String get verifyAnother => 'Verify another item';

  @override
  String get copied => 'Copied';

  @override
  String get copyReference => 'Copy reference number';

  @override
  String get copyPassword => 'Copy password';

  @override
  String get bulkTitle => 'Bulk lookup';

  @override
  String bulkCount(int count, int max) {
    return '$count / $max items';
  }

  @override
  String get bulkScanStart => 'Scan QR codes';

  @override
  String get bulkScanStop => 'Stop scanning';

  @override
  String get bulkAdd => 'Add';

  @override
  String bulkAdded(String label) {
    return 'Added $label';
  }

  @override
  String get bulkDuplicate => 'This item is already in the list.';

  @override
  String bulkFull(int max) {
    return 'The list is full ($max items).';
  }

  @override
  String get bulkEmpty =>
      'Scan QR codes or type serials and hidden codes to build the list.';

  @override
  String get bulkClearList => 'Clear list';

  @override
  String bulkSend(int count) {
    return 'Check $count items';
  }

  @override
  String bulkSending(int count) {
    return 'Checking $count items…';
  }

  @override
  String get bulkNothingChecked =>
      'Nothing was checked. Send the same list again.';

  @override
  String get bulkSendAgain => 'Send again';

  @override
  String get bulkSummaryTitle => 'Summary';

  @override
  String get bulkTotal => 'Total';

  @override
  String get bulkValid => 'Valid';

  @override
  String get bulkWarning => 'Warning';

  @override
  String get bulkNotFound => 'Not found';

  @override
  String get bulkUnassigned => 'Not in a batch';

  @override
  String get bulkOnlyAttention => 'Only items that need attention';

  @override
  String get bulkNewList => 'New list';

  @override
  String get bulkNoAttention => 'No item needs attention.';

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
  String get historyScopeAll => 'Everyone\'s checks';

  @override
  String get historyScopeAllHint => 'Include the checks of every official';

  @override
  String get historyEmptyTitle => 'No checks';

  @override
  String get historyEmptyBody => 'No check matches these filters.';

  @override
  String historyBy(String name) {
    return 'by $name';
  }

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
    return 'Every check of serial $serial';
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
  String get reportPhotosSending => 'Sending photos…';

  @override
  String get reportPhotoFailedRetry => 'Not sent. Tap to send again.';

  @override
  String get reportPhotoRefused => 'This photo was refused.';

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
  String get reportNotFound =>
      'The check or the retail user was not found. Remove it and try again.';

  @override
  String get reportUnconfirmed =>
      'The connection dropped. The report may have been filed: check My reports before filing it again.';

  @override
  String get myReportsTitle => 'My reports';

  @override
  String get myReportsEmpty => 'You have not filed any report yet.';

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
  String get retailUsersTitle => 'Retail users';

  @override
  String get retailUsersAdd => 'Add retail user';

  @override
  String get retailUsersSearchHint => 'Part of a name, or a whole email';

  @override
  String get retailUsersEmpty => 'No retail user yet.';

  @override
  String get retailUserEmailPassword => 'Email a new first password';

  @override
  String retailUserEmailPasswordConfirm(String name) {
    return 'A new first password is emailed to $name. The old one stops working at once.';
  }

  @override
  String get retailUserEmailPasswordSend => 'Email it';

  @override
  String retailUserPasswordEmailed(String name) {
    return 'A new first password was emailed to $name.';
  }

  @override
  String retailUserOwnPassword(String name) {
    return '$name has set their own password. Only your office can change it now.';
  }

  @override
  String get retailUserNotFound =>
      'This retail user was not found or is blocked.';

  @override
  String get addRetailUserTitle => 'Add retail user';

  @override
  String get addRetailUserName => 'Name';

  @override
  String get addRetailUserNameHint => 'Shop or person name';

  @override
  String get addRetailUserEmail => 'Email';

  @override
  String get addRetailUserEmailHint =>
      'The address they log in with and read mail at';

  @override
  String get addRetailUserRole => 'Role';

  @override
  String get addRetailUserPassword => 'First password';

  @override
  String get addRetailUserPasswordHint =>
      'Used once; they change it at the first login';

  @override
  String get addRetailUserSendEmail => 'Email the login details';

  @override
  String get addRetailUserSendEmailOff =>
      'Give the password to the retail user yourself.';

  @override
  String get addRetailUserSubmit => 'Add retail user';

  @override
  String get addRetailUserNoRoles =>
      'Your office has not marked any role as a retail role yet, so no retail user can be added.';

  @override
  String get addRetailUserEmailInUse =>
      'An official with this email already exists.';

  @override
  String get addRetailUserRoleGone =>
      'This role is no longer a retail role. Choose another.';

  @override
  String addRetailUserDoneTitle(String name) {
    return '$name was added';
  }

  @override
  String addRetailUserEmailed(String email) {
    return 'The login details were emailed to $email.';
  }

  @override
  String get addRetailUserMailFailed =>
      'The account was made, but the email could not be sent. Give them the password below, or use \"Email a new first password\" a little later.';

  @override
  String get addRetailUserGiveYourself =>
      'Give the password to the retail user yourself.';

  @override
  String get addRetailUserPasswordOnce => 'Password (shown once):';

  @override
  String get addRetailUserFirstLogin =>
      'They change it at the first login, and their phone needs the emailed code.';

  @override
  String get addAnother => 'Add another';

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
  String get detailsTrackingTitle => 'Tracking details';

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
  String hintHiddenCodeLength(String lengths) {
    return 'A hidden code has $lengths characters.';
  }

  @override
  String lengthsOr(String first, String last) {
    return '$first or $last';
  }

  @override
  String get hintScratch =>
      'Scratch the panel off fully before typing the hidden code.';

  @override
  String get hintScanQr => 'Scan the QR code instead of typing.';

  @override
  String get tryAgainLookup => 'Try again';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get backToVerify => 'Back to Verify';

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
}
