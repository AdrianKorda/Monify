import 'language.dart';

class AppStrings {
  static AppLanguage current = AppLanguage.hu;

  static void setLanguage(AppLanguage lang) {
    current = lang;
  }

  static String get home => _localized('Home', 'Kezdőlap');
  static String get expenses => _localized('Expenses', 'Költségek');
  static String get analytics => _localized('Analytics', 'Elemzés');
  static String get profile => _localized('Profile', 'Fiók');

  // First run
  static String get appTitle => _localized('Expense Tracker', 'Költségkövető');

  static String get title1 => _localized(
    'Make it easy to track your expenses',
    'Tedd egyszerűvé a kiadásaid követését',
  );
  static String get title2 => _localized('Tracking', 'Nyomon követés');
  static String get title3 => _localized('Analyzes', 'Elemzések');
  static String get title4 => _localized('Budgets', 'Költségkeretek');
  static String get title5 => _localized("Let's start!", 'Kezdjük!');

  static String get descript1 => _localized(
    'Start tracking expenses quickly and easily',
    'Kezdd el a költségkövetést egyszerűen és gyorsan',
  );
  static String get descript2 => _localized(
    'Record your daily expenses',
    'Rögzítsd könnyedén a napi kiadásaidat',
  );
  static String get descript3 => _localized(
    'See what you spend the most on',
    'Lásd át egyszerűen, mire költesz a legtöbbet',
  );
  static String get descript4 => _localized(
    'Set daily, weekly or monthly limits and stay on top of your spending',
    'Állíts be napi, heti vagy havi limiteket, és tartsd kézben a kiadásaidat',
  );
  static String get descript5 => _localized(
    'Take control of your expenses today',
    'Vedd kézbe a kiadásaidat már ma',
  );

  static String get skip => _localized('skip', 'kihagy');

  // Login
  static String get pleaseFill => _localized(
    'Please fill in all fields!',
    'Kérlek, töltsd ki az összes mezőt!',
  );
  static String get loginFailed =>
      _localized('Login failed', 'Sikertelen bejelentkezés');
  static String get unknownError =>
      _localized('An unknown error has occurred', 'Ismeretlen hiba történt');
  static String get login => _localized('Login', 'Bejelentkezés');
  static String get pleaseSignIn => _localized(
    'Please Sign in to continue',
    'Kérjük, jelentkezzen be a folytatáshoz',
  );
  static String get password => _localized('Password', 'Jelszó');
  static String get rememberMe =>
      _localized('Remember me next time', 'Emlékezz rám legközelebb');
  static String get signIn => _localized('Sign in', 'Bejelentkezés');
  static String get dontHaveAcc =>
      _localized("Don't have account", 'Nincs fiókod?');
  static String get signUp => _localized('Sign up', 'Regisztrálj');
  static String get signUp2 => _localized('Sign up', 'Regisztrálás');

  // Registration
  static String get enterYourEmail =>
      _localized('Enter your email address', 'Add meg az e-mail címed');
  static String get enterValidEmail => _localized(
    'Please enter a valid email address',
    'Érvényes e-mail címet adj meg',
  );
  static String get enterYourPassword =>
      _localized('Enter your password', 'Add meg a jelszavad');
  static String get minimumCharacters => _localized(
    'A password of at least 8 characters is required',
    'Minimum 8 karakteres jelszó kell',
  );
  static String get confirmPassword =>
      _localized('Confirm your password', 'Erősítsd meg a jelszavad');
  static String get confirmPassword2 =>
      _localized('Confirm your password', 'Jelszó megerősítése');
  static String get passwordsDontMatch =>
      _localized('Passwords do not match', 'A jelszavak nem egyeznek');
  static String get registrationSucces => _localized(
    'Registration is successful! You can now log in',
    'A regisztráció sikeres! Most már bejelentkezhetsz',
  );
  static String get registration => _localized('Registration', 'Regisztráció');
  static String get pleaseRegister => _localized(
    'Please register to login',
    'Kérjük, regisztráljon a bejelentkezéshez',
  );
  static String get enterYourName =>
      _localized('Enter your name.', 'Add meg a neved');
  static String get haveAcc =>
      _localized('Already have account?', 'Már van fiókod?');

  // Profil oldal
  static String get editProfile =>
      _localized('Edit profile', 'Profil szerkesztése');

  static String get settings => _localized('Settings', 'Beállítások');

  static String get currency => _localized('Currency', 'Valuta');

  static String get language => _localized('Language', 'Nyelv');

  static String get fullName => _localized('Name', 'Név');

  static String get email => _localized('Email', 'Email');

  static String get save => _localized('Save', 'Mentés');

  static String get logout => _localized('Logout', 'Kijelentkezés');

  static String get profileUpdated =>
      _localized('Profile updated', 'Profiladatok frissítve');

  static String get profileImageUpdated =>
      _localized('Profile image updated', 'Profilkép frissítve!');

  static String get cannotBeEmpty =>
      _localized('cannot be empty', 'nem lehet üres');

  static String get camera => _localized('Camera', 'Kamera');

  static String get gallery => _localized('Gallery', 'Galéria');

  // Hibaüzenetek
  static String get errorOccurred =>
      _localized('Error occurred', 'Hiba történt');

  static String get errorUploading =>
      _localized('Error uploading file', 'Hiba történt a feltöltéskor');

  // Rövidített error (ProfilPage-hez kompatibilis)
  static String get error => errorOccurred;

  // Nyelv kiválasztás
  static String get hungarian => _localized('Hungarian', 'Magyar');

  static String get english => _localized('English', 'Angol');

  // Általános
  static String get hello => _localized('Hello', 'Szia');
  static String get user => _localized('User', 'Felhasználó');
  static String get unknown => _localized('Unknown', 'Ismeretlen');

  // Home
  static String get balance => _localized('Balance', 'Egyenleg');
  static String get editBalance =>
      _localized('Edit balance', 'Egyenleg módosítása');
  static String get newBalance => _localized('New balance', 'Új egyenleg');
  static String get balanceUpdated =>
      _localized('Balance updated', 'Egyenleg frissítve');
  static String get recentExpenses =>
      _localized('Recent expenses', 'Legutóbbi költségek');
  static String get noExpenses =>
      _localized('No expenses yet', 'Még nincs költséged');
  static String get noExpensesSubtitle => _localized(
    'Once you add an expense, it will appear here.',
    'Amint rögzítesz egy kiadást, itt fog megjelenni.',
  );
  static String get addExpense =>
      _localized('Add expense', 'Költség hozzáadása');
  static String get exampleName =>
      _localized('e.g. Shopping', 'pl. Bevásárlás');
  static String get expensesByCategory =>
      _localized('Expenses by category', 'Kategóriák szerinti költségek');
  static String get noData => _localized('No data', 'Nincs adat');
  static String get noDataInTimeStamp => _localized(
    'There are currently no recorded spending in the selected period',
    'Jelenleg nincs rögzített költés a kiválasztott időszakban',
  );
  static String get expenseStatistics =>
      _localized('Spending statistics', 'Költési statisztika');
  static String get topExpenses =>
      _localized('Top expenses', 'Legnagyobb költségek');
  static String get expenseSaved => _localized(
    'The expense has been saved succesfully',
    'A költség sikeresen mentve',
  );

  // Gombok
  static String get cancel => _localized('Cancel', 'Mégse');
  static String get less => _localized('Less', 'Kevesebb');
  static String get more => _localized('More', 'Tovább');

  // Költség lista – szűrők
  static String get filterAll => _localized('All', 'Összes');
  static String get filterDaily => _localized('Daily', 'Napi');
  static String get filterWeekly => _localized('Weekly', 'Heti');
  static String get filterMonthly => _localized('Monthly', 'Havi');

  // Költség lista - egyelneg
  static String get hasLeft => _localized('remaining', 'van hátra');
  static String get missing => _localized('deficit', 'hiány');
  static String get pastLimit => _localized('exceeded', 'túllépve');
  static String get spent => _localized('spent', 'költve');

  // Limitek
  static String get editLimits =>
      _localized('Edit expense limits', 'Költség limitek módosítása');
  static String get dailyLimit => _localized('Daily limit', 'Napi limit');
  static String get weeklyLimit => _localized('Weekly limit', 'Heti limit');
  static String get monthlyLimit => _localized('Monthly limit', 'Havi limit');
  static String get limitsUpdated =>
      _localized('Limits updated', 'Limitek frissítve');

  // Üres állapot
  static String get noExpensesAll => _localized(
    'You have not added any expenses yet',
    'Még nem rögzítettél egyetlen kiadást sem',
  );
  static String get noExpensesFiltered => _localized(
    'No expenses in this period',
    'Ebben az időszakban nincs rögzített kiadás',
  );

  // Törlés
  static String get delete => _localized('Delete', 'Törlés');
  static String get deleteConfirm => _localized(
    'Are you sure you want to delete this expense?',
    'Biztosan törlöd ezt a költséget?',
  );

  // Részletek
  static String get name => _localized('Name', 'Megnevezés');
  static String get category => _localized('Category', 'Kategória');
  static String get date => _localized('Date', 'Időpont');
  static String get unitPrice => _localized('Unit price', 'Egységár');
  static String get quantity => _localized('Quantity', 'Mennyiség');
  static String get total => _localized('Total', 'Összesen');
  static String get other => _localized('Other', 'Egyéb');

  // ===== KATEGÓRIÁK =====

  static String get categoryFood => _localized('Food', 'Élelmiszer');

  static String get categoryTransport => _localized('Transport', 'Közlekedés');

  static String get categoryFun => _localized('Entertainment', 'Szórakozás');

  static String get categoryHousing => _localized('Housing', 'Lakhatás');

  static String get categoryHealth => _localized('Health', 'Egészség');

  static String get categoryClothing => _localized('Clothing', 'Ruházat');

  static String get categoryTravel => _localized('Travel', 'Utazás');

  static String get categoryEducation => _localized('Education', 'Oktatás');

  static String get categoryOther => _localized('Other', 'Egyéb');

  // Segéd metódus
  static String _localized(String en, String hu) {
    return current == AppLanguage.en ? en : hu;
  }
}
