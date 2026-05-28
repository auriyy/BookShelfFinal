import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('pl'),
    Locale('uk'),
  ];

  /// No description provided for @app_name.
  ///
  /// In uk, this message translates to:
  /// **'Книжкова Полиця'**
  String get app_name;

  /// No description provided for @loading.
  ///
  /// In uk, this message translates to:
  /// **'Завантаження...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In uk, this message translates to:
  /// **'Помилка: '**
  String get error;

  /// No description provided for @save.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In uk, this message translates to:
  /// **'Видалити'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In uk, this message translates to:
  /// **'Скасувати'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In uk, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @auth_welcome.
  ///
  /// In uk, this message translates to:
  /// **'Ласкаво просимо!'**
  String get auth_welcome;

  /// No description provided for @auth_sign_in_title.
  ///
  /// In uk, this message translates to:
  /// **'Вхід в акаунт'**
  String get auth_sign_in_title;

  /// No description provided for @auth_sign_up_title.
  ///
  /// In uk, this message translates to:
  /// **'Реєстрація'**
  String get auth_sign_up_title;

  /// No description provided for @email_label.
  ///
  /// In uk, this message translates to:
  /// **'Електронна пошта'**
  String get email_label;

  /// No description provided for @password_label.
  ///
  /// In uk, this message translates to:
  /// **'Пароль'**
  String get password_label;

  /// No description provided for @name_label.
  ///
  /// In uk, this message translates to:
  /// **'Ваше ім\'я'**
  String get name_label;

  /// No description provided for @btn_sign_in.
  ///
  /// In uk, this message translates to:
  /// **'Увійти'**
  String get btn_sign_in;

  /// No description provided for @btn_sign_up.
  ///
  /// In uk, this message translates to:
  /// **'Зареєструватися'**
  String get btn_sign_up;

  /// No description provided for @no_account.
  ///
  /// In uk, this message translates to:
  /// **'Немає акаунту? Створити'**
  String get no_account;

  /// No description provided for @has_account.
  ///
  /// In uk, this message translates to:
  /// **'Вже є акаунт? Увійти'**
  String get has_account;

  /// No description provided for @auth_error.
  ///
  /// In uk, this message translates to:
  /// **'Не вдалося авторизуватися'**
  String get auth_error;

  /// No description provided for @search_hint.
  ///
  /// In uk, this message translates to:
  /// **'Пошук книг за назвою або автором...'**
  String get search_hint;

  /// No description provided for @search_empty.
  ///
  /// In uk, this message translates to:
  /// **'Введіть запит для початку пошуку'**
  String get search_empty;

  /// No description provided for @search_empty_welcome.
  ///
  /// In uk, this message translates to:
  /// **'Введіть щось у пошуку, щоб знайти неймовірні книги'**
  String get search_empty_welcome;

  /// No description provided for @search_no_results.
  ///
  /// In uk, this message translates to:
  /// **'Нічого не знайдено'**
  String get search_no_results;

  /// No description provided for @search_data_section.
  ///
  /// In uk, this message translates to:
  /// **'Дані пошуку'**
  String get search_data_section;

  /// No description provided for @last_search_label.
  ///
  /// In uk, this message translates to:
  /// **'Останній пошук'**
  String get last_search_label;

  /// No description provided for @history_empty.
  ///
  /// In uk, this message translates to:
  /// **'Історія порожня'**
  String get history_empty;

  /// No description provided for @book_author.
  ///
  /// In uk, this message translates to:
  /// **'Автор: '**
  String get book_author;

  /// No description provided for @book_no_author.
  ///
  /// In uk, this message translates to:
  /// **'Невідомий автор'**
  String get book_no_author;

  /// No description provided for @book_status_label.
  ///
  /// In uk, this message translates to:
  /// **'Статус читання:'**
  String get book_status_label;

  /// No description provided for @book_rating_label.
  ///
  /// In uk, this message translates to:
  /// **'Ваша оцінка:'**
  String get book_rating_label;

  /// No description provided for @add_to_library.
  ///
  /// In uk, this message translates to:
  /// **'Додати до бібліотеки'**
  String get add_to_library;

  /// No description provided for @remove_from_library.
  ///
  /// In uk, this message translates to:
  /// **'Видалити з бібліотеки'**
  String get remove_from_library;

  /// No description provided for @status_changed.
  ///
  /// In uk, this message translates to:
  /// **'Статус книги успешно змінено!'**
  String get status_changed;

  /// No description provided for @book_data_missing.
  ///
  /// In uk, this message translates to:
  /// **'Дані книги відсутні'**
  String get book_data_missing;

  /// No description provided for @author_unknown.
  ///
  /// In uk, this message translates to:
  /// **'Автор невідомий'**
  String get author_unknown;

  /// No description provided for @about_book.
  ///
  /// In uk, this message translates to:
  /// **'Про книгу'**
  String get about_book;

  /// No description provided for @publish_year.
  ///
  /// In uk, this message translates to:
  /// **'Рік публікації'**
  String get publish_year;

  /// No description provided for @unknown_value.
  ///
  /// In uk, this message translates to:
  /// **'Невідомо'**
  String get unknown_value;

  /// No description provided for @original_language.
  ///
  /// In uk, this message translates to:
  /// **'Мова оригіналу'**
  String get original_language;

  /// No description provided for @lang_en.
  ///
  /// In uk, this message translates to:
  /// **'Англійська (en)'**
  String get lang_en;

  /// No description provided for @change_status_btn.
  ///
  /// In uk, this message translates to:
  /// **'Змінити статус, оцінку чи рецензію'**
  String get change_status_btn;

  /// No description provided for @my_review.
  ///
  /// In uk, this message translates to:
  /// **'Мій відгук'**
  String get my_review;

  /// No description provided for @my_rating.
  ///
  /// In uk, this message translates to:
  /// **'Моя оцінка'**
  String get my_rating;

  /// No description provided for @review_label.
  ///
  /// In uk, this message translates to:
  /// **'Рецензія:'**
  String get review_label;

  /// No description provided for @manage_book_title.
  ///
  /// In uk, this message translates to:
  /// **'Керування книгою'**
  String get manage_book_title;

  /// No description provided for @add_to_library_title.
  ///
  /// In uk, this message translates to:
  /// **'Додати до бібліотеки'**
  String get add_to_library_title;

  /// No description provided for @move_to_list.
  ///
  /// In uk, this message translates to:
  /// **'Перемістити до списку:'**
  String get move_to_list;

  /// No description provided for @want_to_rate.
  ///
  /// In uk, this message translates to:
  /// **'Хочу поставити оцінку цій книзі'**
  String get want_to_rate;

  /// No description provided for @your_rating_label.
  ///
  /// In uk, this message translates to:
  /// **'Ваша оцінка:'**
  String get your_rating_label;

  /// No description provided for @review_text_field_label.
  ///
  /// In uk, this message translates to:
  /// **'Текст вашої рецензії (необов\'язково):'**
  String get review_text_field_label;

  /// No description provided for @review_hint.
  ///
  /// In uk, this message translates to:
  /// **'Поділіться враженнями від прочитаного...'**
  String get review_hint;

  /// No description provided for @save_changes_btn.
  ///
  /// In uk, this message translates to:
  /// **'Зберегти зміни'**
  String get save_changes_btn;

  /// No description provided for @delete_from_library_btn.
  ///
  /// In uk, this message translates to:
  /// **'Видалити з бібліотеки'**
  String get delete_from_library_btn;

  /// No description provided for @book_deleted_msg.
  ///
  /// In uk, this message translates to:
  /// **'Книгу видалено з вашої бібліотеки'**
  String get book_deleted_msg;

  /// No description provided for @book_updated_msg.
  ///
  /// In uk, this message translates to:
  /// **'Дані книги оновлено!'**
  String get book_updated_msg;

  /// No description provided for @book_added_msg.
  ///
  /// In uk, this message translates to:
  /// **'Книгу додано до бібліотеки!'**
  String get book_added_msg;

  /// No description provided for @save_error_msg.
  ///
  /// In uk, this message translates to:
  /// **'Помилка збереження:'**
  String get save_error_msg;

  /// No description provided for @status_backlog.
  ///
  /// In uk, this message translates to:
  /// **'У \"Хочу прочитати\"'**
  String get status_backlog;

  /// No description provided for @status_reading.
  ///
  /// In uk, this message translates to:
  /// **'Читаю зараз'**
  String get status_reading;

  /// No description provided for @status_completed.
  ///
  /// In uk, this message translates to:
  /// **'Прочитано'**
  String get status_completed;

  /// No description provided for @lib_title.
  ///
  /// In uk, this message translates to:
  /// **'Моя Бібліотека'**
  String get lib_title;

  /// No description provided for @status_reading_tab.
  ///
  /// In uk, this message translates to:
  /// **'Читаю'**
  String get status_reading_tab;

  /// No description provided for @status_completed_tab.
  ///
  /// In uk, this message translates to:
  /// **'Прочитав'**
  String get status_completed_tab;

  /// No description provided for @status_backlog_tab.
  ///
  /// In uk, this message translates to:
  /// **'Хочу'**
  String get status_backlog_tab;

  /// No description provided for @lib_empty_reading.
  ///
  /// In uk, this message translates to:
  /// **'Ви зараз нічого не читаєте'**
  String get lib_empty_reading;

  /// No description provided for @lib_empty_completed.
  ///
  /// In uk, this message translates to:
  /// **'Жодної прочитаної книги ще немає'**
  String get lib_empty_completed;

  /// No description provided for @lib_empty_backlog.
  ///
  /// In uk, this message translates to:
  /// **'Список бажань порожній'**
  String get lib_empty_backlog;

  /// No description provided for @page_from.
  ///
  /// In uk, this message translates to:
  /// **'з'**
  String get page_from;

  /// No description provided for @page_short.
  ///
  /// In uk, this message translates to:
  /// **'стор.'**
  String get page_short;

  /// No description provided for @unknown_author.
  ///
  /// In uk, this message translates to:
  /// **'Невідомий автор'**
  String get unknown_author;

  /// No description provided for @sheet_title.
  ///
  /// In uk, this message translates to:
  /// **'Керування книгою'**
  String get sheet_title;

  /// No description provided for @move_to_reading.
  ///
  /// In uk, this message translates to:
  /// **'Перемістити в \"Читаю\"'**
  String get move_to_reading;

  /// No description provided for @move_to_completed.
  ///
  /// In uk, this message translates to:
  /// **'Перемістити в \"Прочитано\"'**
  String get move_to_completed;

  /// No description provided for @move_to_backlog.
  ///
  /// In uk, this message translates to:
  /// **'Перемістити в \"Хочу прочитати\"'**
  String get move_to_backlog;

  /// No description provided for @delete_from_lib.
  ///
  /// In uk, this message translates to:
  /// **'Видалити з бібліотеки'**
  String get delete_from_lib;

  /// No description provided for @snack_deleted.
  ///
  /// In uk, this message translates to:
  /// **'Книгу видалено з вашої бібліотеки'**
  String get snack_deleted;

  /// No description provided for @snack_status_changed.
  ///
  /// In uk, this message translates to:
  /// **'Статус книги змінено!'**
  String get snack_status_changed;

  /// No description provided for @nav_search.
  ///
  /// In uk, this message translates to:
  /// **'Пошук'**
  String get nav_search;

  /// No description provided for @nav_library.
  ///
  /// In uk, this message translates to:
  /// **'Бібліотека'**
  String get nav_library;

  /// No description provided for @nav_profile.
  ///
  /// In uk, this message translates to:
  /// **'Профіль'**
  String get nav_profile;

  /// No description provided for @nav_settings.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування'**
  String get nav_settings;

  /// No description provided for @profile_title.
  ///
  /// In uk, this message translates to:
  /// **'Мій Профіль'**
  String get profile_title;

  /// No description provided for @user_default_name.
  ///
  /// In uk, this message translates to:
  /// **'Користувач Книгарні'**
  String get user_default_name;

  /// No description provided for @stats_title.
  ///
  /// In uk, this message translates to:
  /// **'Ваша статистика'**
  String get stats_title;

  /// No description provided for @stat_read.
  ///
  /// In uk, this message translates to:
  /// **'Прочитано'**
  String get stat_read;

  /// No description provided for @stat_reading.
  ///
  /// In uk, this message translates to:
  /// **'Читаю зараз'**
  String get stat_reading;

  /// No description provided for @stat_want.
  ///
  /// In uk, this message translates to:
  /// **'У \"Хочу\"'**
  String get stat_want;

  /// No description provided for @avg_rating.
  ///
  /// In uk, this message translates to:
  /// **'Середня оцінка'**
  String get avg_rating;

  /// No description provided for @no_ratings.
  ///
  /// In uk, this message translates to:
  /// **'Немає оцінок'**
  String get no_ratings;

  /// No description provided for @logout.
  ///
  /// In uk, this message translates to:
  /// **'Вийти з акаунту'**
  String get logout;

  /// No description provided for @status_reading_empty.
  ///
  /// In uk, this message translates to:
  /// **'Ви зараз нічого не читаєте'**
  String get status_reading_empty;

  /// No description provided for @avatar_success.
  ///
  /// In uk, this message translates to:
  /// **'Фото профілю успішно оновлено!'**
  String get avatar_success;

  /// No description provided for @avatar_gallery.
  ///
  /// In uk, this message translates to:
  /// **'Обрати з галереї'**
  String get avatar_gallery;

  /// No description provided for @avatar_camera.
  ///
  /// In uk, this message translates to:
  /// **'Зробити знімок камери'**
  String get avatar_camera;

  /// No description provided for @settings_title.
  ///
  /// In uk, this message translates to:
  /// **'Налаштування'**
  String get settings_title;

  /// No description provided for @appearance_section.
  ///
  /// In uk, this message translates to:
  /// **'Оформлення'**
  String get appearance_section;

  /// No description provided for @language_section.
  ///
  /// In uk, this message translates to:
  /// **'Мова додатка'**
  String get language_section;

  /// No description provided for @theme_light.
  ///
  /// In uk, this message translates to:
  /// **'Світла тема'**
  String get theme_light;

  /// No description provided for @theme_dark.
  ///
  /// In uk, this message translates to:
  /// **'Темна тема'**
  String get theme_dark;

  /// No description provided for @theme_system.
  ///
  /// In uk, this message translates to:
  /// **'Як у системі'**
  String get theme_system;

  /// No description provided for @auth_forgot_password_link.
  ///
  /// In uk, this message translates to:
  /// **'Забули пароль?'**
  String get auth_forgot_password_link;

  /// No description provided for @auth_forgot_password_title.
  ///
  /// In uk, this message translates to:
  /// **'Відновлення пароля'**
  String get auth_forgot_password_title;

  /// No description provided for @auth_forgot_password_subtitle.
  ///
  /// In uk, this message translates to:
  /// **'Введіть ваш email, і ми надішлемо вам посилання для скидання пароля'**
  String get auth_forgot_password_subtitle;

  /// No description provided for @btn_reset_password.
  ///
  /// In uk, this message translates to:
  /// **'Надіслати посилання'**
  String get btn_reset_password;

  /// No description provided for @btn_back_to_login.
  ///
  /// In uk, this message translates to:
  /// **'Назад до входу'**
  String get btn_back_to_login;

  /// No description provided for @auth_reset_email_sent.
  ///
  /// In uk, this message translates to:
  /// **'Посилання для скидання пароля надіслано на вашу електронну пошту'**
  String get auth_reset_email_sent;

  /// No description provided for @auth_error_user_not_found.
  ///
  /// In uk, this message translates to:
  /// **'Користувача з таким email не знайдено.'**
  String get auth_error_user_not_found;

  /// No description provided for @auth_error_invalid_email.
  ///
  /// In uk, this message translates to:
  /// **'Некоректний формат email.'**
  String get auth_error_invalid_email;

  /// No description provided for @auth_error_unknown.
  ///
  /// In uk, this message translates to:
  /// **'Сталася помилка. Спробуйте знову.'**
  String get auth_error_unknown;

  /// No description provided for @confirm_password_label.
  ///
  /// In uk, this message translates to:
  /// **'Підтвердження пароля'**
  String get confirm_password_label;

  /// No description provided for @validation_enter_email.
  ///
  /// In uk, this message translates to:
  /// **'Введіть email'**
  String get validation_enter_email;

  /// No description provided for @validation_correct_email.
  ///
  /// In uk, this message translates to:
  /// **'Введіть коректний email'**
  String get validation_correct_email;

  /// No description provided for @validation_enter_password.
  ///
  /// In uk, this message translates to:
  /// **'Введіть пароль'**
  String get validation_enter_password;

  /// No description provided for @validation_password_length.
  ///
  /// In uk, this message translates to:
  /// **'Пароль має бути не менше 6 символів'**
  String get validation_password_length;

  /// No description provided for @validation_confirm_password.
  ///
  /// In uk, this message translates to:
  /// **'Підтвердіть пароль'**
  String get validation_confirm_password;

  /// No description provided for @validation_passwords_match.
  ///
  /// In uk, this message translates to:
  /// **'Паролі не збігаються'**
  String get validation_passwords_match;
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
      <String>['en', 'pl', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
