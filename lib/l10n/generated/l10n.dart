import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_he.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
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
    Locale('en'),
    Locale('he'),
  ];

  /// Generic placeholder text for undefined or empty values
  ///
  /// In en, this message translates to:
  /// **'--TBD--'**
  String get placeholder;

  /// Text for standard 'Save' buttons
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Text for standard 'Cancel' buttons
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Text for standard 'Add' buttons
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Text for standard 'Edit' buttons
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Form validation error message for empty mandatory fields
  ///
  /// In en, this message translates to:
  /// **'This field is required!'**
  String get required;

  /// Form validation error message for numeric inputs exceeding the 0-100 range
  ///
  /// In en, this message translates to:
  /// **'The value must be between 0 to 100'**
  String get outOfRange;

  /// Preposition used in ranges, e.g., '1 to 10' or 'A to B'
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// Preposition used in sorters, e.g., 'by order' or 'by semester'
  ///
  /// In en, this message translates to:
  /// **'by'**
  String get by;

  /// Label for a standard name input field
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Label for a website URL input field
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Title for the application settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for the setting that controls the application's visual theme
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// Option for the light theme mode
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Option for the dark theme mode
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// Option to follow the system's default theme mode
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// Label for the setting that controls the application's language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;
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
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
