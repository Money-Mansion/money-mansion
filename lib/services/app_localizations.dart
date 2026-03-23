import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  static const String _languageKey = 'app_language';
  static const String _languageEn = 'en';
  static const String _languageSk = 'sk';

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // Main app
      'appTitle': 'Money Mansion',
      'settings': 'Settings',
      'gamePreferences': 'Game preferences and options',
      'language': 'Language',

      // Bottom navigation
      'gameTab': 'Game',
      'inventoryTab': 'Inventory',
      'shopTab': 'Shop',
      'goalsTab': 'Goals',
      'calendarTab': 'Calendar',
      'financialTab': 'Financial',
      'settingsTab': 'Settings',

      // Game screen
      'coins': 'Coins',
      'money': 'Money',
      'date': 'Date',

      // Room viewer
      'room': 'Room',
      'editRoom': 'Edit Room',

      // Settings
      'languageEnglish': 'English',
      'languageSlovak': 'Sloven─ìina',
      'selectLanguage': 'Select Language',
      'unsavedChanges': 'Unsaved changes',
      'saveChanges': 'Save changes',
      'discardChanges': 'Discard changes',

      // Common actions
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'back': 'Back',
      'ok': 'OK',

      // Screens
      'inventory': 'Inventory',
      'shop': 'Shop',
      'goals': 'Goals',
      'calendar': 'Calendar',
      'financial': 'Financial',

      // Financial
      'balance': 'Balance',
      'income': 'Income',
      'expense': 'Expense',
      'transactions': 'Transactions',
      'addTransaction': 'Add Transaction',

      // Goals
      'goalName': 'Goal Name',
      'goalDescription': 'Description',
      'targetAmount': 'Target Amount',
      'currentAmount': 'Current Amount',
      'rewardCoins': 'Reward Coins',
      'addGoal': 'Add Goal',
      'goalCompleted': 'Goal Completed!',
      'completeGoal': 'Complete Goal',

      // Items
      'itemName': 'Item Name',
      'itemPrice': 'Price',
      'buy': 'Buy',
      'sell': 'Sell',
      'owned': 'Owned',

      // Calendar
      'month': 'Month',
      'year': 'Year',
      'today': 'Today',

      // Confirmation dialogs
      'areYouSure': 'Are you sure?',
      'confirmation': 'Confirmation',

      // Inventory
      'noItemsYet': 'No Items Yet',
      'yourItemsWillAppearHere': 'Your items will appear here',

      // Shop
      'notEnoughCoins': 'Not enough coins!',
      'needCoinsHave': 'Need {need}, have {have}',
      'purchasedFor': '{item} purchased for {cost} coins!',
      'itemPurchasedSuccessfully': 'Item purchased successfully!',
      'furniture': 'Furniture',
      'realEstate': 'Real Estate',

      // Calendar months
      'january': 'January',
      'february': 'February',
      'march': 'March',
      'april': 'April',
      'may': 'May',
      'june': 'June',
      'july': 'July',
      'august': 'August',
      'september': 'September',
      'october': 'October',
      'november': 'November',
      'december': 'December',

      // Calendar weekdays
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      'saturday': 'Sat',
      'sunday': 'Sun',

      // Dialog labels
      'todayLabel': 'Today',
      'errorLoadingGoals': 'Error loading goals',
      'createNewGoal': 'Create New Goal',
      'goalTitle': 'Goal Title',
      'coinsReward': 'Coins Reward',
      'targetMoneyAmount': 'Target Money Amount (Γé¼)',
      'selectDeadline': 'Select Deadline',
      'addNew': 'Add New',
      'noTransactions': 'No transactions yet',
      'addTransactionLabel': 'Add Transaction',
      'amountEuro': 'Amount (Γé¼)',
      'selectType': 'Select Type',
      'selectGoal': 'Select Goal (optional)',
      'createdAt': 'Created at',

      // Additional missing texts
      'pickDate': 'Pick Date',
      'enterGoalTitle': 'Please enter a goal title',
      'goalCreatedSuccessfully': 'Goal created successfully',
      'failedToCreateGoal': 'Failed to create goal',
      'createGoal': 'Create Goal',
      'refreshGoals': 'Refresh goals',
      'failedToCompleteGoal': 'Failed to complete goal',
      'goalDeleted': 'Goal deleted',
      'failedToDeleteGoal': 'Failed to delete goal',
      'noGoalAllocation': 'No goal allocation',
      'refresh': 'Refresh',
      'noGoal': 'No goal',
      'plus': '+',
      'minus': '-',
      'statistics': 'Statistics',
      'gain': 'Gain',
      'purchase': 'Purchase',
      'reassignFunds': 'Reassign Funds',
      'fromGoal': 'From goal',
      'toGoal': 'To goal',
      'amount': 'Amount',
      'note': 'Note',
      'amountExceedsAvailableGoalFunds': 'Amount exceeds available goal funds.',
      'amountExceedsGoalTarget': 'Amount would exceed the target goal.',
      'fundsReassignedSuccessfully': 'Funds reassigned successfully',
      'addGainOrPurchase': 'Add Gain / Purchase',
      'editTransaction': 'Edit Transaction',
      'noTransactionsYetTapAdd': 'No transactions yet. Tap + to add one!',
      'moneyAssignedAndGoalCompleted': 'Money assigned and goal completed!',
      'moneyAssignedToGoal': 'Money assigned to goal',
      'assignMoneyToGoal': 'Assign money to {goal}',
      'availableBalance': 'Available balance: {amount}',
      'amountExceedsCurrentAppBalance': 'Amount exceeds current app balance.',
      'assignMoney': 'Assign money',
      'goalAmount': 'Goal Amount',
      'goalCompletedChrumkaOnly': 'Goal completed! +1 Chrumka',
      'goalCompletedCoinsAndChrumka':
          'Goal completed! +{coins} coins & +1 Chrumka',
      'goalDeletedAndMoneyReturned':
          'Goal deleted and money returned to balance',
      'difficultyEasy': 'Easy',
      'difficultyMedium': 'Medium',
      'difficultyHard': 'Hard',
      'difficulty': 'Difficulty',
      'rewardLabel': 'Reward',

      // Chrumko tips bubble
      'chrumkoTipLabel': "Chrumko's Tip ≡ƒÆí",
      'chrumkoTipDismiss': 'Tap to dismiss',
      'chrumkoTip0': 'I always set aside part of my money. Try it too! ≡ƒÆ░',
      'chrumkoTip1': 'Chrumko advises: think first, then buy. ≡ƒ¢ì∩╕Å',
      'chrumkoTip2':
          'I track my expenses. That way I know where my money goes! ≡ƒôè',
      'chrumkoTip3': 'Even small savings grow into something big over time. ≡ƒôê',
      'chrumkoTip4': 'When I plan my purchases, I save more money. ≡ƒô¥',
      'chrumkoTip5': 'I always keep a reserve for unexpected things! ≡ƒÄü',
      'chrumkoTip6': 'A budget helps me stay in control of my money! ≡ƒôï',
      'chrumkoTip7':
          'I don\'t have to buy everything right away. Sometimes it pays to wait! ΓÅ│',
      'chrumkoTip8': 'Every saved euro is a step towards my goals! ≡ƒÄ»',
      'chrumkoTip9': 'Thoughtful decisions make money a great helper! ≡ƒñ¥',
      'chrumkoTip10': 'I save up for things that are truly important to me! ≡ƒîƒ',
      'chrumkoTip11': 'When I save regularly, my savings grow faster! ≡ƒôê',
      'chrumkoTip12':
          'Before buying, I always ask myself: do I really need this? ≡ƒ¢Æ',
      'chrumkoTip13': 'Financial discipline helps me fulfil my dreams! ≡ƒÆ¡',
      'chrumkoTip14': 'Remember: money is a tool, not a goal! ≡ƒîì',
    },
    'sk': {
      // Main app
      'appTitle': 'Money Mansion',
      'settings': 'Nastavenia',
      'gamePreferences': 'Hern├⌐ preferencie a mo┼╛nosti',
      'language': 'Jazyk',

      // Bottom navigation
      'gameTab': 'Hra',
      'inventoryTab': 'Invent├ír',
      'shopTab': 'Obchod',
      'goalsTab': 'Ciele',
      'calendarTab': 'Kalend├ír',
      'financialTab': 'Financie',
      'settingsTab': 'Nastavenia',

      // Game screen
      'coins': 'Mince',
      'money': 'Peniaze',
      'date': 'D├ítum',

      // Room viewer
      'room': 'Izba',
      'editRoom': 'Upravi┼Ñ izbu',

      // Settings
      'languageEnglish': 'English',
      'languageSlovak': 'Sloven─ìina',
      'selectLanguage': 'Vyberte jazyk',
      'unsavedChanges': 'Neulo┼╛en├⌐ zmeny',
      'saveChanges': 'Ulo┼╛i┼Ñ zmeny',
      'discardChanges': 'Zavrhn├║┼Ñ zmeny',

      // Common actions
      'save': 'Ulo┼╛i┼Ñ',
      'cancel': 'Zru┼íi┼Ñ',
      'delete': 'Vymaza┼Ñ',
      'edit': 'Upravi┼Ñ',
      'add': 'Prida┼Ñ',
      'back': 'Sp├ñ┼Ñ',
      'ok': 'OK',

      // Screens
      'inventory': 'Invent├ír',
      'shop': 'Obchod',
      'goals': 'Ciele',
      'calendar': 'Kalend├ír',
      'financial': 'Financie',

      // Financial
      'balance': 'Zostatok',
      'income': 'Pr├¡jem',
      'expense': 'V├╜daj',
      'transactions': 'Transakcie',
      'addTransaction': 'Prida┼Ñ transakciu',

      // Goals
      'goalName': 'N├ízov cie─╛a',
      'goalDescription': 'Popis',
      'targetAmount': 'Cie─╛ov├í suma',
      'currentAmount': 'Aktu├ílna suma',
      'rewardCoins': 'Odmena v minciach',
      'addGoal': 'Prida┼Ñ cie─╛',
      'goalCompleted': 'Cie─╛ splnen├╜!',
      'completeGoal': 'Splni┼Ñ cie─╛',

      // Items
      'itemName': 'N├ízov polo┼╛ky',
      'itemPrice': 'Cena',
      'buy': 'K├║pi┼Ñ',
      'sell': 'Preda┼Ñ',
      'owned': 'Vlastn├¡',

      // Calendar
      'month': 'Mesiac',
      'year': 'Rok',
      'today': 'Dnes',

      // Confirmation dialogs
      'areYouSure': 'Ste si ist├¡?',
      'confirmation': 'Potvrdenie',

      // Inventory
      'noItemsYet': 'Zatia─╛ nie s├║ polo┼╛ky',
      'yourItemsWillAppearHere': 'Va┼íe polo┼╛ky sa objavia tu',

      // Shop
      'notEnoughCoins': 'Nedostaatok minc├¡!',
      'needCoinsHave': 'Potrebujete {need}, m├íte {have}',
      'purchasedFor': '{item} k├║pen├⌐ za {cost} minc├¡!',
      'itemPurchasedSuccessfully': 'N├íkup bol ├║spe┼ín├╜!',
      'furniture': 'N├íbytok',
      'realEstate': 'Nehnute─╛nosti',

      // Calendar months
      'january': 'Janu├ír',
      'february': 'Febru├ír',
      'march': 'Marec',
      'april': 'Apr├¡l',
      'may': 'M├íj',
      'june': 'J├║n',
      'july': 'J├║l',
      'august': 'August',
      'september': 'September',
      'october': 'Okt├│ber',
      'november': 'November',
      'december': 'December',

      // Calendar weekdays
      'monday': 'Po',
      'tuesday': 'Ut',
      'wednesday': 'St',
      'thursday': '┼át',
      'friday': 'Pi',
      'saturday': 'So',
      'sunday': 'Ne',

      // Dialog labels
      'todayLabel': 'Dnes',
      'errorLoadingGoals': 'Chyba pri na─ì├¡tan├¡ cie─╛ov',
      'createNewGoal': 'Vytvori┼Ñ nov├╜ cie─╛',
      'goalTitle': 'N├ízov cie─╛a',
      'coinsReward': 'Odmena v minciach',
      'targetMoneyAmount': 'Cie─╛ov├í suma pe┼êaz├¡ (Γé¼)',
      'selectDeadline': 'Vyberte deadline',
      'addNew': 'Prida┼Ñ nov├╜',
      'noTransactions': 'Zatia─╛ bez transakci├¡',
      'addTransactionLabel': 'Prida┼Ñ transakciu',
      'amountEuro': 'Suma (Γé¼)',
      'selectType': 'Vyberte typ',
      'selectGoal': 'Vyberte cie─╛ (volite─╛n├⌐)',
      'createdAt': 'Vytvoren├⌐',

      // Additional missing texts
      'pickDate': 'Vyberte d├ítum',
      'enterGoalTitle': 'Pros├¡m zadajte n├ízov cie─╛a',
      'goalCreatedSuccessfully': 'Cie─╛ bol ├║spe┼íne vytvoren├╜',
      'failedToCreateGoal': 'Chyba pri vytv├íran├¡ cie─╛a',
      'createGoal': 'Vytvori┼Ñ cie─╛',
      'refreshGoals': 'Obnovi┼Ñ ciele',
      'failedToCompleteGoal': 'Chyba pri splnen├¡ cie─╛a',
      'goalDeleted': 'Cie─╛ bol vymazan├╜',
      'failedToDeleteGoal': 'Chyba pri vymaz├ívan├¡ cie─╛a',
      'noGoalAllocation': 'Bez pridelenia cie─╛u',
      'refresh': 'Obnovi┼Ñ',
      'noGoal': 'Bez cie─╛a',
      'plus': '+',
      'minus': '-',
      'statistics': '┼átatistika',
      'gain': 'Pr├¡jem',
      'purchase': 'N├íkup',
      'reassignFunds': 'Presun├║┼Ñ peniaze',
      'fromGoal': 'Z cie─╛a',
      'toGoal': 'Do cie─╛a',
      'amount': 'Suma',
      'note': 'Pozn├ímka',
      'amountExceedsAvailableGoalFunds':
          'Suma prekra─ìuje dostupn├⌐ peniaze cie─╛a.',
      'amountExceedsGoalTarget': 'Suma by prekro─ìila cie─╛ov├║ sumu.',
      'fundsReassignedSuccessfully': 'Peniaze boli ├║spe┼íne presunut├⌐',
      'addGainOrPurchase': 'Prida┼Ñ pr├¡jem / n├íkup',
      'editTransaction': 'Upravi┼Ñ transakciu',
      'noTransactionsYetTapAdd':
          'Zatia─╛ nie s├║ ┼╛iadne transakcie. Klepnite na + a pridajte jednu!',
      'moneyAssignedAndGoalCompleted': 'Peniaze priraden├⌐ a cie─╛ splnen├╜!',
      'moneyAssignedToGoal': 'Peniaze boli priraden├⌐ k cie─╛u',
      'assignMoneyToGoal': 'Priradi┼Ñ peniaze k cie─╛u {goal}',
      'availableBalance': 'Dostupn├╜ zostatok: {amount}',
      'amountExceedsCurrentAppBalance':
          'Suma prekra─ìuje aktu├ílny zostatok aplik├ície.',
      'assignMoney': 'Priradi┼Ñ peniaze',
      'goalAmount': 'Suma cie─╛a',
      'goalCompletedChrumkaOnly': 'Cie─╛ splnen├╜! +1 Chrumka',
      'goalCompletedCoinsAndChrumka':
          'Cie─╛ splnen├╜! +{coins} minc├¡ & +1 Chrumka',
      'goalDeletedAndMoneyReturned':
          'Cie─╛ bol vymazan├╜ a peniaze sa vr├ítili do zostatku',
      'difficultyEasy': '─╜ahk├í',
      'difficultyMedium': 'Stredn├í',
      'difficultyHard': '┼ña┼╛k├í',
      'difficulty': 'N├íro─ìnos┼Ñ',
      'rewardLabel': 'Odmena',

      // Chrumko tips bubble
      'chrumkoTipLabel': 'Tip od Chrumka ≡ƒÆí',
      'chrumkoTipDismiss': 'Klepni pre zavretie',
      'chrumkoTip0': 'Ja si v┼╛dy ─ìas┼Ñ pe┼êaz├¡ odlo┼╛├¡m. Sk├║s to aj ty! ≡ƒÆ░',
      'chrumkoTip1': 'Chrumko rad├¡: najprv prem├╜┼í─╛aj, a┼╛ potom nakupuj! ≡ƒ¢ì∩╕Å',
      'chrumkoTip2':
          'Ja si sledujem v├╜davky. V─Åaka tomu viem, kam moje peniaze id├║! ≡ƒôè',
      'chrumkoTip3': 'Ke─Å pl├ínujem n├íkupy, u┼íetr├¡m viac pe┼êaz├¡. ≡ƒô¥',
      'chrumkoTip4': 'Aj mal├⌐ ├║spory sa ─ìasom zmenia na ve─╛k├⌐! ≡ƒôê',
      'chrumkoTip5': 'Ja si v┼╛dy nech├ím rezervu na ne─ìakan├⌐ veci! ≡ƒÄü',
      'chrumkoTip6': 'Nemus├¡m k├║pi┼Ñ v┼íetko hne─Å. Niekedy sa oplat├¡ po─ìka┼Ñ! ΓÅ│',
      'chrumkoTip7': 'Ka┼╛d├⌐ u┼íetren├⌐ euro je krok k mojim cie─╛om! ≡ƒÄ»',
      'chrumkoTip8':
          'Premyslen├⌐ rozhodnutia robia z pe┼êaz├¡ dobr├⌐ho pomocn├¡ka! ≡ƒñ¥',
      'chrumkoTip9': 'Rozpo─ìet mi pom├íha ma┼Ñ peniaze pod kontrolou! ≡ƒöì',
      'chrumkoTip10': 'Ja ┼íetr├¡m na veci, ktor├⌐ s├║ pre m┼êa naozaj d├┤le┼╛it├⌐! ≡ƒîƒ',
      'chrumkoTip11': 'Ke─Å ┼íetr├¡m pravidelne, moje ├║spory rast├║ r├╜chlej┼íie! ≡ƒôê',
      'chrumkoTip12': 'Pred n├íkupom si v┼╛dy polo┼╛├¡m ot├ízku: potrebujem to? ≡ƒ¢Æ',
      'chrumkoTip13': 'Finan─ìn├í discipl├¡na mi pom├íha plni┼Ñ si sny! ≡ƒÆ¡',
      'chrumkoTip14': 'Pam├ñtaj: peniaze s├║ n├ístroj, nie cie─╛! ≡ƒîì',
    },
  };

  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? _languageEn;
  }

  static String translate(String key, {String language = _languageEn}) {
    return _translations[language]?[key] ?? _translations[_languageEn]![key]!;
  }

  /// Returns all 15 Chrumko tips for the given language.
  static List<String> getChrumkoTips(String language) {
    return List.generate(
      15,
      (i) => translate('chrumkoTip$i', language: language),
    );
  }

  static List<String> getSupportedLanguages() {
    return [_languageEn, _languageSk];
  }

  static String getLanguageName(String languageCode) {
    return languageCode == _languageSk ? 'Sloven─ìina' : 'English';
  }
}
