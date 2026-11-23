import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// The app's name.
  ///
  /// In en, this message translates to:
  /// **'Track & Trace'**
  String get appTitle;

  /// Under the app's name on the Splash.
  ///
  /// In en, this message translates to:
  /// **'Product Authenticity Check'**
  String get appSubtitle;

  /// The line on the Splash's navy glow, above the progress.
  ///
  /// In en, this message translates to:
  /// **'Check genuine products instantly'**
  String get splashTagline;

  /// No description provided for @brandTagline.
  ///
  /// In en, this message translates to:
  /// **'TRACK · TRACE · CHECK'**
  String get brandTagline;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login to Track & Trace'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and password to check products.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login securely'**
  String get loginButton;

  /// No description provided for @noAccountDivider.
  ///
  /// In en, this message translates to:
  /// **'NO ACCOUNT?'**
  String get noAccountDivider;

  /// No description provided for @noAccountQuestion.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccountQuestion;

  /// No description provided for @requestAccessButton.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get requestAccessButton;

  /// No description provided for @authorizedOnly.
  ///
  /// In en, this message translates to:
  /// **'Only authorized users can access this system'**
  String get authorizedOnly;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get loginFailed;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get emailInvalid;

  /// No description provided for @verifyCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get verifyCodeTitle;

  /// No description provided for @verifyCodeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}. Enter it to trust this phone.'**
  String verifyCodeSubtitle(String email);

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code from the email'**
  String get codeLabel;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get verifyButton;

  /// No description provided for @codeWrong.
  ///
  /// In en, this message translates to:
  /// **'The code is wrong or has expired. Check the latest email, or send the code again.'**
  String get codeWrong;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Send the code again'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Send again in {seconds} s'**
  String resendIn(int seconds);

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'A new code was sent.'**
  String get codeResent;

  /// No description provided for @resendLimitReached.
  ///
  /// In en, this message translates to:
  /// **'No more codes can be sent. Log in again.'**
  String get resendLimitReached;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get backToLogin;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordForcedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your password was set by someone else. Choose your own password to continue.'**
  String get changePasswordForcedSubtitle;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a new password. Your other phones will be logged out.'**
  String get changePasswordSubtitle;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPasswordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat new password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @changePasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get changePasswordButton;

  /// No description provided for @currentPasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'The current password is incorrect.'**
  String get currentPasswordWrong;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Your password was changed.'**
  String get passwordChanged;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @ruleLength.
  ///
  /// In en, this message translates to:
  /// **'8 characters or more'**
  String get ruleLength;

  /// No description provided for @ruleLetter.
  ///
  /// In en, this message translates to:
  /// **'a letter'**
  String get ruleLetter;

  /// No description provided for @ruleNumber.
  ///
  /// In en, this message translates to:
  /// **'a number'**
  String get ruleNumber;

  /// No description provided for @ruleNoControl.
  ///
  /// In en, this message translates to:
  /// **'no tabs or line breaks'**
  String get ruleNoControl;

  /// No description provided for @passwordRuleBroken.
  ///
  /// In en, this message translates to:
  /// **'The password does not meet the rules below.'**
  String get passwordRuleBroken;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot password'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email. If it has an account, we will send a 6-digit code.'**
  String get forgotSubtitle;

  /// No description provided for @sendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCodeButton;

  /// No description provided for @forgotSent.
  ///
  /// In en, this message translates to:
  /// **'If the address has an account, a code was sent.'**
  String get forgotSent;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetTitle;

  /// No description provided for @resetCodeWrong.
  ///
  /// In en, this message translates to:
  /// **'The code is wrong or has expired. Ask for a new code.'**
  String get resetCodeWrong;

  /// No description provided for @resetNewCode.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get resetNewCode;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'If {email} has an account, a code was sent to it. Enter the code and choose a new password.'**
  String resetSubtitle(String email);

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetButton;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Log in with your new password; every phone needs the emailed code at its next login.'**
  String get resetDone;

  /// No description provided for @requestAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get requestAccessTitle;

  /// No description provided for @requestAccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account. Your office checks it and emails you its answer.'**
  String get requestAccessSubtitle;

  /// No description provided for @noPhoneApp.
  ///
  /// In en, this message translates to:
  /// **'No phone app found. Call {phone}.'**
  String noPhoneApp(String phone);

  /// No description provided for @noMailApp.
  ///
  /// In en, this message translates to:
  /// **'No email app found. Write to {email}.'**
  String noMailApp(String email);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @loadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Loading your profile…'**
  String get loadingProfile;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check the internet and try again.'**
  String get errorNetwork;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {seconds} s.'**
  String errorRateLimited(int seconds);

  /// No description provided for @errorPreparing.
  ///
  /// In en, this message translates to:
  /// **'The app is being prepared. Try again later.'**
  String get errorPreparing;

  /// No description provided for @errorUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The service is busy. Try again shortly.'**
  String get errorUnavailable;

  /// No description provided for @errorNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available.'**
  String get errorNotAvailable;

  /// No description provided for @errorGeneral.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorGeneral;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference: {id}'**
  String reference(String id);

  /// No description provided for @tabVerify.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get tabVerify;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @noFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'No features yet'**
  String get noFeaturesTitle;

  /// No description provided for @noFeaturesBody.
  ///
  /// In en, this message translates to:
  /// **'Your role does not allow any features yet. Contact your office.'**
  String get noFeaturesBody;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @organisationLabel.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organisationLabel;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @permissionsSection.
  ///
  /// In en, this message translates to:
  /// **'WHAT YOU CAN DO'**
  String get permissionsSection;

  /// No description provided for @permissionLookup.
  ///
  /// In en, this message translates to:
  /// **'Check one item'**
  String get permissionLookup;

  /// No description provided for @permissionBulkLookup.
  ///
  /// In en, this message translates to:
  /// **'Check many items'**
  String get permissionBulkLookup;

  /// No description provided for @permissionHistory.
  ///
  /// In en, this message translates to:
  /// **'Own history'**
  String get permissionHistory;

  /// No description provided for @permissionReport.
  ///
  /// In en, this message translates to:
  /// **'Report incidents'**
  String get permissionReport;

  /// No description provided for @permissionsNone.
  ///
  /// In en, this message translates to:
  /// **'None. Ask your office.'**
  String get permissionsNone;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get accountSection;

  /// Profile card: every check the official made.
  ///
  /// In en, this message translates to:
  /// **'Checks'**
  String get statChecks;

  /// No description provided for @statValid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get statValid;

  /// Profile card: the official's checks found in no batch or not found at all (not_found + unassigned).
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get statNotVerified;

  /// Under the Profile cards' place when GET checks fails; a Try again link follows.
  ///
  /// In en, this message translates to:
  /// **'Your counts couldn\'t load.'**
  String get statsFailed;

  /// No description provided for @changePasswordRow.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordRow;

  /// Profile row that opens the language choice; its subtitle names the current language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageRow;

  /// Title of the sheet offering English and Bangla.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get languageTitle;

  /// No description provided for @supportContactRow.
  ///
  /// In en, this message translates to:
  /// **'Support contact'**
  String get supportContactRow;

  /// No description provided for @supportNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set by your office'**
  String get supportNotSet;

  /// No description provided for @appVersionRow.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersionRow;

  /// No description provided for @appVersionValue.
  ///
  /// In en, this message translates to:
  /// **'v{version} · build {build}'**
  String appVersionValue(String version, String build);

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This phone stays trusted, so the next login needs no emailed code.'**
  String get logoutConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @verifyItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Check authenticity'**
  String get verifyItemTitle;

  /// No description provided for @waySerial.
  ///
  /// In en, this message translates to:
  /// **'Serial'**
  String get waySerial;

  /// No description provided for @wayHiddenCode.
  ///
  /// In en, this message translates to:
  /// **'Hidden code'**
  String get wayHiddenCode;

  /// No description provided for @wayQr.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get wayQr;

  /// No description provided for @wayOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get wayOther;

  /// No description provided for @serialHint.
  ///
  /// In en, this message translates to:
  /// **'Up to {digits} digits'**
  String serialHint(int digits);

  /// No description provided for @verifyButtonLookup.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get verifyButtonLookup;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Above the scanner's frame; shown in capitals.
  ///
  /// In en, this message translates to:
  /// **'Place the QR code inside the frame'**
  String get scanFrameHint;

  /// The status under the scanner's frame while the camera looks for a code.
  ///
  /// In en, this message translates to:
  /// **'Looking for a QR code · hold steady'**
  String get scanLooking;

  /// No description provided for @inputEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a value first'**
  String get inputEmpty;

  /// No description provided for @inputWrongSerial.
  ///
  /// In en, this message translates to:
  /// **'A serial has digits only, up to {digits} digits.'**
  String inputWrongSerial(int digits);

  /// No description provided for @notProductQr.
  ///
  /// In en, this message translates to:
  /// **'This QR code is not a product code of this company.'**
  String get notProductQr;

  /// No description provided for @formatsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the code formats.'**
  String get formatsFailed;

  /// No description provided for @lookupNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Unable to check. Check the connection and try again.'**
  String get lookupNetworkError;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get verifying;

  /// No description provided for @toolsTitle.
  ///
  /// In en, this message translates to:
  /// **'MORE'**
  String get toolsTitle;

  /// No description provided for @toolReport.
  ///
  /// In en, this message translates to:
  /// **'Report incident'**
  String get toolReport;

  /// No description provided for @toolMyReports.
  ///
  /// In en, this message translates to:
  /// **'My reports'**
  String get toolMyReports;

  /// No description provided for @scannerPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access is off. Allow it in Settings to scan QR codes.'**
  String get scannerPermissionDenied;

  /// No description provided for @scannerUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This phone cannot scan QR codes. Type the serial instead.'**
  String get scannerUnsupported;

  /// No description provided for @scannerFailed.
  ///
  /// In en, this message translates to:
  /// **'The camera could not start.'**
  String get scannerFailed;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @torch.
  ///
  /// In en, this message translates to:
  /// **'Torch'**
  String get torch;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Check result'**
  String get resultTitle;

  /// No description provided for @resultValidTitle.
  ///
  /// In en, this message translates to:
  /// **'Genuine product'**
  String get resultValidTitle;

  /// No description provided for @resultValidBody.
  ///
  /// In en, this message translates to:
  /// **'First check by any official. Nothing is wrong with this item.'**
  String get resultValidBody;

  /// No description provided for @resultWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Genuine, needs attention'**
  String get resultWarningTitle;

  /// No description provided for @resultWarningBody.
  ///
  /// In en, this message translates to:
  /// **'Read every reason below.'**
  String get resultWarningBody;

  /// No description provided for @resultNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get resultNotFoundTitle;

  /// No description provided for @resultNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'No product of this company has this serial or QR code.'**
  String get resultNotFoundBody;

  /// No description provided for @resultUnassignedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not in a batch'**
  String get resultUnassignedTitle;

  /// No description provided for @resultUnassignedBody.
  ///
  /// In en, this message translates to:
  /// **'This item exists but has not been given to a batch yet.'**
  String get resultUnassignedBody;

  /// No description provided for @resultUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to check'**
  String get resultUnknownTitle;

  /// No description provided for @resultUnknownBody.
  ///
  /// In en, this message translates to:
  /// **'This result is not known to this app version. Update the app or contact your office.'**
  String get resultUnknownBody;

  /// No description provided for @reasonCheckedBefore.
  ///
  /// In en, this message translates to:
  /// **'Checked before'**
  String get reasonCheckedBefore;

  /// No description provided for @reasonCheckedBeforeDetail.
  ///
  /// In en, this message translates to:
  /// **'This is check number {count} of this item. Last check: {when}.'**
  String reasonCheckedBeforeDetail(int count, String when);

  /// No description provided for @reasonRecalled.
  ///
  /// In en, this message translates to:
  /// **'Batch recalled'**
  String get reasonRecalled;

  /// No description provided for @reasonExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get reasonExpired;

  /// No description provided for @reasonDamaged.
  ///
  /// In en, this message translates to:
  /// **'Marked damaged'**
  String get reasonDamaged;

  /// No description provided for @reasonSwitchedOff.
  ///
  /// In en, this message translates to:
  /// **'Batch switched off'**
  String get reasonSwitchedOff;

  /// No description provided for @reasonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get reasonUnknown;

  /// No description provided for @referenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Reference number'**
  String get referenceNumber;

  /// No description provided for @productLabel.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get productLabel;

  /// No description provided for @genericLabel.
  ///
  /// In en, this message translates to:
  /// **'Generic name'**
  String get genericLabel;

  /// No description provided for @shortNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Short name'**
  String get shortNameLabel;

  /// No description provided for @serialLabel.
  ///
  /// In en, this message translates to:
  /// **'Serial'**
  String get serialLabel;

  /// No description provided for @codeLabel2.
  ///
  /// In en, this message translates to:
  /// **'Hidden code'**
  String get codeLabel2;

  /// No description provided for @batchLabel.
  ///
  /// In en, this message translates to:
  /// **'Batch'**
  String get batchLabel;

  /// No description provided for @madeLabel.
  ///
  /// In en, this message translates to:
  /// **'Made'**
  String get madeLabel;

  /// No description provided for @expiresLabel.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expiresLabel;

  /// No description provided for @verifyAnother.
  ///
  /// In en, this message translates to:
  /// **'Check another item'**
  String get verifyAnother;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @copyReference.
  ///
  /// In en, this message translates to:
  /// **'Copy reference number'**
  String get copyReference;

  /// No description provided for @bulkValid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get bulkValid;

  /// No description provided for @bulkWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get bulkWarning;

  /// No description provided for @bulkNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get bulkNotFound;

  /// No description provided for @bulkUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Not in a batch'**
  String get bulkUnassigned;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeItem;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear the search'**
  String get clearSearch;

  /// No description provided for @historySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a serial or a reference number'**
  String get historySearchHint;

  /// No description provided for @historyFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get historyFilters;

  /// No description provided for @historyApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get historyApply;

  /// No description provided for @historyReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get historyReset;

  /// No description provided for @historyWay.
  ///
  /// In en, this message translates to:
  /// **'Way'**
  String get historyWay;

  /// No description provided for @historyDates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get historyDates;

  /// No description provided for @historyAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get historyAny;

  /// No description provided for @historyPickDates.
  ///
  /// In en, this message translates to:
  /// **'Choose dates'**
  String get historyPickDates;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No checks'**
  String get historyEmptyTitle;

  /// The scanner session or stack a check belongs to, by the first 8 characters of its ID.
  ///
  /// In en, this message translates to:
  /// **'Session {id}'**
  String historySession(String id);

  /// Who made the check: always the official logged in (SRS FR-HIS-04).
  ///
  /// In en, this message translates to:
  /// **'Checked by {name}'**
  String historyCheckedBy(String name);

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No check matches these filters.'**
  String get historyEmptyBody;

  /// No description provided for @historyNoChecksYet.
  ///
  /// In en, this message translates to:
  /// **'Your checks appear here after your first check.'**
  String get historyNoChecksYet;

  /// The History result chip that shows every result.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historyAll;

  /// No description provided for @historyToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get historyToday;

  /// No description provided for @historyYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get historyYesterday;

  /// Title of the item card above a serial's tracking log; shown in capitals.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get historyItemTitle;

  /// Title above a serial's numbered checks; shown in capitals.
  ///
  /// In en, this message translates to:
  /// **'Tracking log'**
  String get historyTrackingLog;

  /// No description provided for @historyCheckCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 check} other{{count} checks}}'**
  String historyCheckCount(int count);

  /// No description provided for @historyTracking.
  ///
  /// In en, this message translates to:
  /// **'Your checks of serial {serial}'**
  String historyTracking(String serial);

  /// No description provided for @pickRetailUser.
  ///
  /// In en, this message translates to:
  /// **'Choose a retail user'**
  String get pickRetailUser;

  /// No description provided for @pickRetailUserHint.
  ///
  /// In en, this message translates to:
  /// **'Part of a name, or a whole email'**
  String get pickRetailUserHint;

  /// No description provided for @pickRetailUserEmpty.
  ///
  /// In en, this message translates to:
  /// **'No retail user found'**
  String get pickRetailUserEmpty;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report incident'**
  String get reportTitle;

  /// No description provided for @reportWhenNotNeeded.
  ///
  /// In en, this message translates to:
  /// **'No report is needed for a warning: a recalled, expired, damaged, or switched-off item is already sent to your office by the lookup. Report what a lookup cannot see, such as a fake-looking label or a torn seal.'**
  String get reportWhenNotNeeded;

  /// No description provided for @reportNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'What did you find?'**
  String get reportNoteLabel;

  /// No description provided for @reportNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem'**
  String get reportNoteHint;

  /// No description provided for @reportCheckLabel.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get reportCheckLabel;

  /// No description provided for @reportRetailUserLabel.
  ///
  /// In en, this message translates to:
  /// **'Retail user'**
  String get reportRetailUserLabel;

  /// No description provided for @reportChooseRetailUser.
  ///
  /// In en, this message translates to:
  /// **'Choose a retail user (optional)'**
  String get reportChooseRetailUser;

  /// No description provided for @reportChooseCheck.
  ///
  /// In en, this message translates to:
  /// **'Link one of your checks (optional)'**
  String get reportChooseCheck;

  /// No description provided for @pickCheck.
  ///
  /// In en, this message translates to:
  /// **'Choose a check'**
  String get pickCheck;

  /// No description provided for @reportPhotosLabel.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get reportPhotosLabel;

  /// No description provided for @reportPhotosHint.
  ///
  /// In en, this message translates to:
  /// **'Up to 3 photos. Location and other details in the photo are removed.'**
  String get reportPhotosHint;

  /// No description provided for @reportAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get reportAddPhoto;

  /// No description provided for @reportCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get reportCamera;

  /// No description provided for @reportGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get reportGallery;

  /// No description provided for @reportFile.
  ///
  /// In en, this message translates to:
  /// **'File report'**
  String get reportFile;

  /// No description provided for @reportFiled.
  ///
  /// In en, this message translates to:
  /// **'Report {id} filed.'**
  String reportFiled(int id);

  /// No description provided for @reportPhotoFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Not sent. Tap to send again.'**
  String get reportPhotoFailedRetry;

  /// No description provided for @reportPhotoRefused.
  ///
  /// In en, this message translates to:
  /// **'This photo was refused.'**
  String get reportPhotoRefused;

  /// No description provided for @reportPhotoConflict.
  ///
  /// In en, this message translates to:
  /// **'No more photos: the report has 3, or its hour is over.'**
  String get reportPhotoConflict;

  /// No description provided for @reportLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos not sent'**
  String get reportLeaveTitle;

  /// No description provided for @reportLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'Some photos are still sending or can be sent again. If you leave, they are not sent.'**
  String get reportLeaveBody;

  /// No description provided for @reportStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get reportStay;

  /// No description provided for @reportLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get reportLeave;

  /// No description provided for @reportPhotoSent.
  ///
  /// In en, this message translates to:
  /// **'Photo {n}'**
  String reportPhotoSent(int n);

  /// No description provided for @reportPhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This photo is too large even after shrinking.'**
  String get reportPhotoTooLarge;

  /// No description provided for @reportPhotoUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This photo could not be read. Try another.'**
  String get reportPhotoUnreadable;

  /// No description provided for @reportPhotoWindowOver.
  ///
  /// In en, this message translates to:
  /// **'Photos can be added only within an hour of the report.'**
  String get reportPhotoWindowOver;

  /// No description provided for @reportDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get reportDone;

  /// No description provided for @reportUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'The connection dropped. The report may have been filed: check My reports before filing it again.'**
  String get reportUnconfirmed;

  /// No description provided for @reportCheckMyReports.
  ///
  /// In en, this message translates to:
  /// **'Check My reports'**
  String get reportCheckMyReports;

  /// No description provided for @myReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'My reports'**
  String get myReportsTitle;

  /// No description provided for @myReportsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have not filed any report yet.'**
  String get myReportsEmpty;

  /// No description provided for @myReportsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Reports you file appear here. Use New report to file one.'**
  String get myReportsEmptyBody;

  /// No description provided for @myReportsPhotos.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No photos} =1{1 photo} other{{count} photos}}'**
  String myReportsPhotos(int count);

  /// No description provided for @newReport.
  ///
  /// In en, this message translates to:
  /// **'New report'**
  String get newReport;

  /// No description provided for @reportFromResult.
  ///
  /// In en, this message translates to:
  /// **'Report incident'**
  String get reportFromResult;

  /// No description provided for @pictureTitle.
  ///
  /// In en, this message translates to:
  /// **'Product image'**
  String get pictureTitle;

  /// No description provided for @pictureNone.
  ///
  /// In en, this message translates to:
  /// **'No picture for this product'**
  String get pictureNone;

  /// No description provided for @pictureFailed.
  ///
  /// In en, this message translates to:
  /// **'The picture could not be loaded'**
  String get pictureFailed;

  /// No description provided for @pictureOf.
  ///
  /// In en, this message translates to:
  /// **'Picture of {name}'**
  String pictureOf(String name);

  /// No description provided for @pictureOpenHint.
  ///
  /// In en, this message translates to:
  /// **'Opens the picture full screen'**
  String get pictureOpenHint;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @badgeGenuine.
  ///
  /// In en, this message translates to:
  /// **'Genuine'**
  String get badgeGenuine;

  /// No description provided for @detailsProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Product details'**
  String get detailsProductTitle;

  /// No description provided for @checkNumber.
  ///
  /// In en, this message translates to:
  /// **'Check {count}'**
  String checkNumber(int count);

  /// No description provided for @previousCheckLabel.
  ///
  /// In en, this message translates to:
  /// **'Previous check'**
  String get previousCheckLabel;

  /// No description provided for @checkedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Checked before by'**
  String get checkedByLabel;

  /// No description provided for @enteredTitle.
  ///
  /// In en, this message translates to:
  /// **'What you entered'**
  String get enteredTitle;

  /// No description provided for @checkedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Checked at'**
  String get checkedAtLabel;

  /// No description provided for @resultRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get resultRowLabel;

  /// No description provided for @hintsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hints'**
  String get hintsTitle;

  /// No description provided for @hintScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code instead of typing.'**
  String get hintScanQr;

  /// No description provided for @tryAgainLookup.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgainLookup;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @backToVerify.
  ///
  /// In en, this message translates to:
  /// **'Back to Check'**
  String get backToVerify;

  /// No description provided for @backToList.
  ///
  /// In en, this message translates to:
  /// **'Back to the list'**
  String get backToList;

  /// No description provided for @supportEmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Item not found: {ref}'**
  String supportEmailSubject(String ref);

  /// No description provided for @supportEmailBody.
  ///
  /// In en, this message translates to:
  /// **'Reference: {ref}\n{way}: {value}\nChecked at: {time}'**
  String supportEmailBody(String ref, String way, String value, String time);

  /// No description provided for @verifyingTitle.
  ///
  /// In en, this message translates to:
  /// **'Checking the item…'**
  String get verifyingTitle;

  /// No description provided for @verifyingBody.
  ///
  /// In en, this message translates to:
  /// **'Checked against the company\'s records. This usually takes under a second.'**
  String get verifyingBody;

  /// No description provided for @stepCodeFormat.
  ///
  /// In en, this message translates to:
  /// **'Code format'**
  String get stepCodeFormat;

  /// No description provided for @stepItemRecord.
  ///
  /// In en, this message translates to:
  /// **'Item record'**
  String get stepItemRecord;

  /// No description provided for @stepCheckCount.
  ///
  /// In en, this message translates to:
  /// **'Check count'**
  String get stepCheckCount;

  /// No description provided for @stepDone.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get stepDone;

  /// No description provided for @stepWaiting.
  ///
  /// In en, this message translates to:
  /// **'waiting'**
  String get stepWaiting;

  /// No description provided for @accessPending.
  ///
  /// In en, this message translates to:
  /// **'Thanks for signing up. Your request was sent. You will get an email when it is answered.'**
  String get accessPending;

  /// No description provided for @accessWrongCode.
  ///
  /// In en, this message translates to:
  /// **'The code is wrong or expired. Request a new code if needed.'**
  String get accessWrongCode;

  /// No description provided for @accessTryLater.
  ///
  /// In en, this message translates to:
  /// **'Try again later. Get a new code before you sign up again.'**
  String get accessTryLater;

  /// No description provided for @accessRoleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This role is no longer available. Choose another role.'**
  String get accessRoleUnavailable;

  /// No description provided for @accessNoRoles.
  ///
  /// In en, this message translates to:
  /// **'Ask the office for an account.'**
  String get accessNoRoles;

  /// No description provided for @accessContactOffice.
  ///
  /// In en, this message translates to:
  /// **'Contact the office'**
  String get accessContactOffice;

  /// No description provided for @accessName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get accessName;

  /// No description provided for @accessRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get accessRole;

  /// No description provided for @accessRoleHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a role'**
  String get accessRoleHint;

  /// No description provided for @accessPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a password'**
  String get accessPassword;

  /// No description provided for @accessShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get accessShowPassword;

  /// No description provided for @accessHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get accessHidePassword;

  /// No description provided for @accessEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accessEmail;

  /// No description provided for @accessCode.
  ///
  /// In en, this message translates to:
  /// **'Code from the email'**
  String get accessCode;

  /// No description provided for @accessResend.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get accessResend;

  /// No description provided for @accessSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get accessSendCode;

  /// No description provided for @accessCodeSent.
  ///
  /// In en, this message translates to:
  /// **'A code was sent to the address.'**
  String get accessCodeSent;

  /// No description provided for @accessSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get accessSubmit;

  /// No description provided for @scannerModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Scanner mode'**
  String get scannerModeTitle;

  /// No description provided for @serialStackTitle.
  ///
  /// In en, this message translates to:
  /// **'Serial stack'**
  String get serialStackTitle;

  /// No description provided for @serialStackHint.
  ///
  /// In en, this message translates to:
  /// **'Type or paste up to 50 serials, separated by spaces, commas, or new lines. Repeated serials are checked once.'**
  String get serialStackHint;

  /// No description provided for @serialStackLimit.
  ///
  /// In en, this message translates to:
  /// **'Enter 1 to 50 different serials. Submit another stack for additional items.'**
  String get serialStackLimit;

  /// No description provided for @serialStackUncertain.
  ///
  /// In en, this message translates to:
  /// **'The answer was lost. These checks may already be recorded. Retrying may record them again.'**
  String get serialStackUncertain;

  /// No description provided for @serialStackNotSent.
  ///
  /// In en, this message translates to:
  /// **'No connection. Nothing was sent; send the stack again when you are online.'**
  String get serialStackNotSent;

  /// No description provided for @serialStackBadSerial.
  ///
  /// In en, this message translates to:
  /// **'Serial {position} ({value}) is not a serial: digits only, up to {digits} digits.'**
  String serialStackBadSerial(int position, String value, int digits);

  /// No description provided for @serialStackCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of 50 serials'**
  String serialStackCount(int count);

  /// No description provided for @serialStackCountRepeats.
  ///
  /// In en, this message translates to:
  /// **'{count} of 50 serials · {repeats} repeated, sent once'**
  String serialStackCountRepeats(int count, int repeats);

  /// No description provided for @serialStackRecorded.
  ///
  /// In en, this message translates to:
  /// **'These checks were recorded, but their answer could not be shown. See them in History → Sessions. Do not send the same stack again.'**
  String get serialStackRecorded;

  /// No description provided for @serialStackRetry.
  ///
  /// In en, this message translates to:
  /// **'Send the same stack again'**
  String get serialStackRetry;

  /// No description provided for @serialStackSubmit.
  ///
  /// In en, this message translates to:
  /// **'Check serials'**
  String get serialStackSubmit;

  /// No description provided for @serialStackNew.
  ///
  /// In en, this message translates to:
  /// **'Start another stack'**
  String get serialStackNew;

  /// No description provided for @serialStackHistory.
  ///
  /// In en, this message translates to:
  /// **'View this session\'s checks'**
  String get serialStackHistory;

  /// No description provided for @sessionScanned.
  ///
  /// In en, this message translates to:
  /// **'Scanned'**
  String get sessionScanned;

  /// No description provided for @sessionValid.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get sessionValid;

  /// No description provided for @sessionWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get sessionWarning;

  /// No description provided for @sessionNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get sessionNotFound;

  /// No description provided for @sessionUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Not in a batch'**
  String get sessionUnassigned;

  /// No description provided for @sessionLeft.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get sessionLeft;

  /// No description provided for @sessionRepeat.
  ///
  /// In en, this message translates to:
  /// **'Already scanned'**
  String get sessionRepeat;

  /// No description provided for @sessionScanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get sessionScanAgain;

  /// No description provided for @sessionNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection, scan again.'**
  String get sessionNoConnection;

  /// No description provided for @sessionBusy.
  ///
  /// In en, this message translates to:
  /// **'The service is busy. Nothing was recorded; scan again.'**
  String get sessionBusy;

  /// No description provided for @sessionRestarted.
  ///
  /// In en, this message translates to:
  /// **'A new session started.'**
  String get sessionRestarted;

  /// No description provided for @sessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessionsTitle;

  /// No description provided for @sessionsMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get sessionsMore;

  /// No description provided for @sessionsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get sessionsAll;

  /// No description provided for @sessionsOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get sessionsOpen;

  /// No description provided for @sessionsEnded.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get sessionsEnded;

  /// No description provided for @sessionsDates.
  ///
  /// In en, this message translates to:
  /// **'Choose dates'**
  String get sessionsDates;

  /// No description provided for @sessionsLastSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Showing the last 7 days'**
  String get sessionsLastSevenDays;

  /// No description provided for @sessionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No sessions found.'**
  String get sessionsEmpty;

  /// No description provided for @historyChecksView.
  ///
  /// In en, this message translates to:
  /// **'Checks'**
  String get historyChecksView;

  /// No description provided for @sessionsStarted.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get sessionsStarted;

  /// No description provided for @sessionsLastScan.
  ///
  /// In en, this message translates to:
  /// **'Last scan'**
  String get sessionsLastScan;

  /// No description provided for @sessionChecksTitle.
  ///
  /// In en, this message translates to:
  /// **'Session checks'**
  String get sessionChecksTitle;

  /// No description provided for @rateLimitedUnknown.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again later.'**
  String get rateLimitedUnknown;

  /// No description provided for @sessionRowsFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this session\'s scans.'**
  String get sessionRowsFailed;

  /// No description provided for @reportPhotoSame.
  ///
  /// In en, this message translates to:
  /// **'That photo is already on the report.'**
  String get reportPhotoSame;

  /// No description provided for @reportUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The report was sent, but its answer could not be read. It may have been filed: check My reports before filing it again.'**
  String get reportUnreadable;

  /// No description provided for @reportCheckGone.
  ///
  /// In en, this message translates to:
  /// **'The check was not found. Remove it and try again.'**
  String get reportCheckGone;

  /// No description provided for @reportRetailUserGone.
  ///
  /// In en, this message translates to:
  /// **'This retail user can no longer be named. Choose another, or file without one.'**
  String get reportRetailUserGone;

  /// No description provided for @sessionResumedCounts.
  ///
  /// In en, this message translates to:
  /// **'Resumed session. The counts show after the next scan.'**
  String get sessionResumedCounts;

  /// No description provided for @sessionChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get sessionChecking;

  /// No description provided for @sessionCheckingMore.
  ///
  /// In en, this message translates to:
  /// **'Checking… {count} more'**
  String sessionCheckingMore(int count);

  /// Scanner mode: ends the session and shows every scan together.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get sessionFinish;

  /// Finish was pressed; scans already read are still being answered.
  ///
  /// In en, this message translates to:
  /// **'Checking the last scans…'**
  String get sessionFinishing;

  /// Title of the summary after Finish in scanner mode.
  ///
  /// In en, this message translates to:
  /// **'Session finished'**
  String get sessionSummaryTitle;

  /// How many different products the finished session scanned.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 product scanned} other{{count} products scanned}}'**
  String sessionSummaryCount(int count);

  /// On the summary: starts a new scanner session.
  ///
  /// In en, this message translates to:
  /// **'Scan more'**
  String get sessionScanMore;

  /// On the summary: back to the Check tab.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get sessionDone;

  /// No description provided for @sessionNotChecked.
  ///
  /// In en, this message translates to:
  /// **'{count} more scans were not checked. Scan them again.'**
  String sessionNotChecked(int count);

  /// No description provided for @typeSerialLabel.
  ///
  /// In en, this message translates to:
  /// **'Or type the serial'**
  String get typeSerialLabel;

  /// No description provided for @scanNotReady.
  ///
  /// In en, this message translates to:
  /// **'Scanning waits for the code formats.'**
  String get scanNotReady;

  /// No description provided for @copyrightNotice.
  ///
  /// In en, this message translates to:
  /// **'© {year} Ziska Pharmaceuticals Ltd. All rights reserved.'**
  String copyrightNotice(String year);

  /// No description provided for @appVersionShort.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String appVersionShort(String version, String build);

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Checks need a connection.'**
  String get offlineBanner;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
