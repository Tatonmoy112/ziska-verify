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
  /// **'Product Verification System'**
  String get appSubtitle;

  /// The line on the Splash's navy glow, above the progress.
  ///
  /// In en, this message translates to:
  /// **'Verify genuine products instantly'**
  String get splashTagline;

  /// No description provided for @brandTagline.
  ///
  /// In en, this message translates to:
  /// **'TRACK · TRACE · VERIFY'**
  String get brandTagline;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login to Track & Trace'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and password to verify products.'**
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
  /// **'Don\'t have an ID and password?'**
  String get noAccountQuestion;

  /// No description provided for @requestAccessButton.
  ///
  /// In en, this message translates to:
  /// **'Contact us to request access'**
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
  /// **'Verification code'**
  String get codeLabel;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// No description provided for @codeWrong.
  ///
  /// In en, this message translates to:
  /// **'The code is wrong or has expired. Check the latest email, or log in again for a new code.'**
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

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to {email} and choose a new password.'**
  String resetSubtitle(String email);

  /// No description provided for @resetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetButton;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Log in with your new password.'**
  String get resetDone;

  /// No description provided for @requestAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Request access'**
  String get requestAccessTitle;

  /// No description provided for @requestAccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts are created by your office. Email or call them with the details below.'**
  String get requestAccessSubtitle;

  /// No description provided for @pleaseInclude.
  ///
  /// In en, this message translates to:
  /// **'Please include'**
  String get pleaseInclude;

  /// No description provided for @includeName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get includeName;

  /// No description provided for @includeOrganisation.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get includeOrganisation;

  /// No description provided for @includePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get includePhone;

  /// No description provided for @includeEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get includeEmail;

  /// No description provided for @includeReason.
  ///
  /// In en, this message translates to:
  /// **'Reason for access'**
  String get includeReason;

  /// No description provided for @includeJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get includeJobTitle;

  /// No description provided for @emailTeamButton.
  ///
  /// In en, this message translates to:
  /// **'Email the office'**
  String get emailTeamButton;

  /// No description provided for @callTeamButton.
  ///
  /// In en, this message translates to:
  /// **'Call the office'**
  String get callTeamButton;

  /// No description provided for @accessRequestSubject.
  ///
  /// In en, this message translates to:
  /// **'Access request'**
  String get accessRequestSubject;

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
  /// **'Verify'**
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

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'This part of the app is being built.'**
  String get comingSoon;

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
  /// **'Not verified'**
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

  /// Pill title of the Request access steps; shown in capitals.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get howItWorks;

  /// No description provided for @requestStepSendTitle.
  ///
  /// In en, this message translates to:
  /// **'Send your request'**
  String get requestStepSendTitle;

  /// No description provided for @requestStepSendBody.
  ///
  /// In en, this message translates to:
  /// **'Email or call the office with the details below.'**
  String get requestStepSendBody;

  /// Step 1 when the office has no phone number configured.
  ///
  /// In en, this message translates to:
  /// **'Email the office with the details below.'**
  String get requestStepSendBodyEmailOnly;

  /// No description provided for @requestStepCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Your office checks it'**
  String get requestStepCheckTitle;

  /// No description provided for @requestStepCheckBody.
  ///
  /// In en, this message translates to:
  /// **'An administrator checks your request and creates your account.'**
  String get requestStepCheckBody;

  /// No description provided for @requestStepLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive your login'**
  String get requestStepLoginTitle;

  /// No description provided for @requestStepLoginBody.
  ///
  /// In en, this message translates to:
  /// **'Your first password is emailed to you or given to you in person. You change it at your first login.'**
  String get requestStepLoginBody;

  /// No description provided for @verifyItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify an item'**
  String get verifyItemTitle;

  /// No description provided for @verifyItemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Type the serial or the hidden code, or scan the QR code.'**
  String get verifyItemSubtitle;

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

  /// No description provided for @serialHint.
  ///
  /// In en, this message translates to:
  /// **'Up to {digits} digits'**
  String serialHint(int digits);

  /// No description provided for @hiddenCodeHint.
  ///
  /// In en, this message translates to:
  /// **'The code under the scratch layer'**
  String get hiddenCodeHint;

  /// No description provided for @verifyButtonLookup.
  ///
  /// In en, this message translates to:
  /// **'Verify product'**
  String get verifyButtonLookup;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @scanQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scanQrTitle;

  /// No description provided for @scanQrSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at the product\'s QR code'**
  String get scanQrSubtitle;

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

  /// Scanner button: back to the Verify tab with the field focused, to type the serial or hidden code.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get enterManually;

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

  /// No description provided for @inputWrongHiddenCode.
  ///
  /// In en, this message translates to:
  /// **'This is not a hidden code of this company. Check each character.'**
  String get inputWrongHiddenCode;

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
  /// **'Unable to verify. Check the connection and try again.'**
  String get lookupNetworkError;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying…'**
  String get verifying;

  /// No description provided for @toolsTitle.
  ///
  /// In en, this message translates to:
  /// **'MORE'**
  String get toolsTitle;

  /// No description provided for @toolBulk.
  ///
  /// In en, this message translates to:
  /// **'Bulk lookup'**
  String get toolBulk;

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

  /// No description provided for @toolRetailUsers.
  ///
  /// In en, this message translates to:
  /// **'Retail users'**
  String get toolRetailUsers;

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
  /// **'Verification result'**
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
  /// **'No product of this company has this code.'**
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
  /// **'Unable to verify'**
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
  /// **'Verify another item'**
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

  /// No description provided for @copyPassword.
  ///
  /// In en, this message translates to:
  /// **'Copy password'**
  String get copyPassword;

  /// No description provided for @bulkTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk lookup'**
  String get bulkTitle;

  /// No description provided for @bulkCount.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max} items'**
  String bulkCount(int count, int max);

  /// No description provided for @bulkScanStart.
  ///
  /// In en, this message translates to:
  /// **'Scan QR codes'**
  String get bulkScanStart;

  /// No description provided for @bulkScanStop.
  ///
  /// In en, this message translates to:
  /// **'Stop scanning'**
  String get bulkScanStop;

  /// No description provided for @bulkAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get bulkAdd;

  /// No description provided for @bulkAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {label}'**
  String bulkAdded(String label);

  /// No description provided for @bulkDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This item is already in the list.'**
  String get bulkDuplicate;

  /// No description provided for @bulkFull.
  ///
  /// In en, this message translates to:
  /// **'The list is full ({max} items).'**
  String bulkFull(int max);

  /// No description provided for @bulkEmpty.
  ///
  /// In en, this message translates to:
  /// **'Scan QR codes or type serials and hidden codes to build the list.'**
  String get bulkEmpty;

  /// No description provided for @bulkClearList.
  ///
  /// In en, this message translates to:
  /// **'Clear list'**
  String get bulkClearList;

  /// No description provided for @bulkSend.
  ///
  /// In en, this message translates to:
  /// **'Check {count} items'**
  String bulkSend(int count);

  /// No description provided for @bulkSending.
  ///
  /// In en, this message translates to:
  /// **'Checking {count} items…'**
  String bulkSending(int count);

  /// No description provided for @bulkNothingChecked.
  ///
  /// In en, this message translates to:
  /// **'Nothing was checked. Send the same list again.'**
  String get bulkNothingChecked;

  /// No description provided for @bulkSendAgain.
  ///
  /// In en, this message translates to:
  /// **'Send again'**
  String get bulkSendAgain;

  /// No description provided for @bulkSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get bulkSummaryTitle;

  /// No description provided for @bulkTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get bulkTotal;

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

  /// No description provided for @bulkOnlyAttention.
  ///
  /// In en, this message translates to:
  /// **'Only items that need attention'**
  String get bulkOnlyAttention;

  /// No description provided for @bulkNewList.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get bulkNewList;

  /// No description provided for @bulkNoAttention.
  ///
  /// In en, this message translates to:
  /// **'No item needs attention.'**
  String get bulkNoAttention;

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

  /// No description provided for @historyScopeAll.
  ///
  /// In en, this message translates to:
  /// **'Everyone\'s checks'**
  String get historyScopeAll;

  /// No description provided for @historyScopeAllHint.
  ///
  /// In en, this message translates to:
  /// **'Include the checks of every official'**
  String get historyScopeAllHint;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No checks'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No check matches these filters.'**
  String get historyEmptyBody;

  /// No description provided for @historyBy.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String historyBy(String name);

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
  /// **'Every check of serial {serial}'**
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

  /// No description provided for @reportPhotosSending.
  ///
  /// In en, this message translates to:
  /// **'Sending photos…'**
  String get reportPhotosSending;

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

  /// No description provided for @reportNotFound.
  ///
  /// In en, this message translates to:
  /// **'The check or the retail user was not found. Remove it and try again.'**
  String get reportNotFound;

  /// No description provided for @reportUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'The connection dropped. The report may have been filed: check My reports before filing it again.'**
  String get reportUnconfirmed;

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

  /// No description provided for @retailUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Retail users'**
  String get retailUsersTitle;

  /// No description provided for @retailUsersAdd.
  ///
  /// In en, this message translates to:
  /// **'Add retail user'**
  String get retailUsersAdd;

  /// No description provided for @retailUsersSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Part of a name, or a whole email'**
  String get retailUsersSearchHint;

  /// No description provided for @retailUsersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No retail user yet.'**
  String get retailUsersEmpty;

  /// No description provided for @retailUserEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Email a new first password'**
  String get retailUserEmailPassword;

  /// No description provided for @retailUserEmailPasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'A new first password is emailed to {name}. The old one stops working at once.'**
  String retailUserEmailPasswordConfirm(String name);

  /// No description provided for @retailUserEmailPasswordSend.
  ///
  /// In en, this message translates to:
  /// **'Email it'**
  String get retailUserEmailPasswordSend;

  /// No description provided for @retailUserPasswordEmailed.
  ///
  /// In en, this message translates to:
  /// **'A new first password was emailed to {name}.'**
  String retailUserPasswordEmailed(String name);

  /// No description provided for @retailUserOwnPassword.
  ///
  /// In en, this message translates to:
  /// **'{name} has set their own password. Only your office can change it now.'**
  String retailUserOwnPassword(String name);

  /// No description provided for @retailUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'This retail user was not found or is blocked.'**
  String get retailUserNotFound;

  /// No description provided for @addRetailUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Add retail user'**
  String get addRetailUserTitle;

  /// No description provided for @addRetailUserName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get addRetailUserName;

  /// No description provided for @addRetailUserNameHint.
  ///
  /// In en, this message translates to:
  /// **'Shop or person name'**
  String get addRetailUserNameHint;

  /// No description provided for @addRetailUserEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get addRetailUserEmail;

  /// No description provided for @addRetailUserEmailHint.
  ///
  /// In en, this message translates to:
  /// **'The address they log in with and read mail at'**
  String get addRetailUserEmailHint;

  /// No description provided for @addRetailUserRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get addRetailUserRole;

  /// No description provided for @addRetailUserPassword.
  ///
  /// In en, this message translates to:
  /// **'First password'**
  String get addRetailUserPassword;

  /// No description provided for @addRetailUserPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Used once; they change it at the first login'**
  String get addRetailUserPasswordHint;

  /// No description provided for @addRetailUserSendEmail.
  ///
  /// In en, this message translates to:
  /// **'Email the login details'**
  String get addRetailUserSendEmail;

  /// No description provided for @addRetailUserSendEmailOff.
  ///
  /// In en, this message translates to:
  /// **'Give the password to the retail user yourself.'**
  String get addRetailUserSendEmailOff;

  /// No description provided for @addRetailUserSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add retail user'**
  String get addRetailUserSubmit;

  /// No description provided for @addRetailUserNoRoles.
  ///
  /// In en, this message translates to:
  /// **'Your office has not marked any role as a retail role yet, so no retail user can be added.'**
  String get addRetailUserNoRoles;

  /// No description provided for @addRetailUserEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An official with this email already exists.'**
  String get addRetailUserEmailInUse;

  /// No description provided for @addRetailUserRoleGone.
  ///
  /// In en, this message translates to:
  /// **'This role is no longer a retail role. Choose another.'**
  String get addRetailUserRoleGone;

  /// No description provided for @addRetailUserDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} was added'**
  String addRetailUserDoneTitle(String name);

  /// No description provided for @addRetailUserEmailed.
  ///
  /// In en, this message translates to:
  /// **'The login details were emailed to {email}.'**
  String addRetailUserEmailed(String email);

  /// No description provided for @addRetailUserMailFailed.
  ///
  /// In en, this message translates to:
  /// **'The account was made, but the email could not be sent. Give them the password below, or use \"Email a new first password\" a little later.'**
  String get addRetailUserMailFailed;

  /// No description provided for @addRetailUserGiveYourself.
  ///
  /// In en, this message translates to:
  /// **'Give the password to the retail user yourself.'**
  String get addRetailUserGiveYourself;

  /// No description provided for @addRetailUserPasswordOnce.
  ///
  /// In en, this message translates to:
  /// **'Password (shown once):'**
  String get addRetailUserPasswordOnce;

  /// No description provided for @addRetailUserFirstLogin.
  ///
  /// In en, this message translates to:
  /// **'They change it at the first login, and their phone needs the emailed code.'**
  String get addRetailUserFirstLogin;

  /// No description provided for @addAnother.
  ///
  /// In en, this message translates to:
  /// **'Add another'**
  String get addAnother;

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

  /// No description provided for @detailsTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking details'**
  String get detailsTrackingTitle;

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

  /// No description provided for @hintHiddenCodeLength.
  ///
  /// In en, this message translates to:
  /// **'A hidden code has {lengths} characters.'**
  String hintHiddenCodeLength(String lengths);

  /// No description provided for @lengthsOr.
  ///
  /// In en, this message translates to:
  /// **'{first} or {last}'**
  String lengthsOr(String first, String last);

  /// No description provided for @hintScratch.
  ///
  /// In en, this message translates to:
  /// **'Scratch the panel off fully before typing the hidden code.'**
  String get hintScratch;

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
  /// **'Back to Verify'**
  String get backToVerify;

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
