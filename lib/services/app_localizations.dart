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
      'languageSlovak': 'Slovenčina',
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
      'targetMoneyAmount': 'Target Money Amount (€)',
      'selectDeadline': 'Select Deadline',
      'addNew': 'Add New',
      'noTransactions': 'No transactions yet',
      'addTransactionLabel': 'Add Transaction',
      'amountEuro': 'Amount (€)',
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
      'chrumkoTipLabel': "Chrumko's Tip 💡",
      'chrumkoTipDismiss': 'Tap to dismiss',
      'chrumkoTip0': 'I always set aside part of my money. Try it too! 💰',
      'chrumkoTip1': 'Chrumko advises: think first, then buy. 🛍️',
      'chrumkoTip2':
          'I track my expenses. That way I know where my money goes! 📊',
      'chrumkoTip3': 'Even small savings grow into something big over time. 📈',
      'chrumkoTip4': 'When I plan my purchases, I save more money. 📝',
      'chrumkoTip5': 'I always keep a reserve for unexpected things! 🎁',
      'chrumkoTip6': 'A budget helps me stay in control of my money! 📋',
      'chrumkoTip7':
          'I don\'t have to buy everything right away. Sometimes it pays to wait! ⏳',
      'chrumkoTip8': 'Every saved euro is a step towards my goals! 🎯',
      'chrumkoTip9': 'Thoughtful decisions make money a great helper! 🤝',
      'chrumkoTip10': 'I save up for things that are truly important to me! 🌟',
      'chrumkoTip11': 'When I save regularly, my savings grow faster! 📈',
      'chrumkoTip12':
          'Before buying, I always ask myself: do I really need this? 🛒',
      'chrumkoTip13': 'Financial discipline helps me fulfil my dreams! 💭',
      'chrumkoTip14': 'Remember: money is a tool, not a goal! 🌍',
    },
    'sk': {
      // Main app
      'appTitle': 'Money Mansion',
      'settings': 'Nastavenia',
      'gamePreferences': 'Herné preferencie a možnosti',
      'language': 'Jazyk',

      // Bottom navigation
      'gameTab': 'Hra',
      'inventoryTab': 'Inventár',
      'shopTab': 'Obchod',
      'goalsTab': 'Ciele',
      'calendarTab': 'Kalendár',
      'financialTab': 'Financie',
      'settingsTab': 'Nastavenia',

      // Game screen
      'coins': 'Mince',
      'money': 'Peniaze',
      'date': 'Dátum',

      // Room viewer
      'room': 'Izba',
      'editRoom': 'Upraviť izbu',

      // Settings
      'languageEnglish': 'English',
      'languageSlovak': 'Slovenčina',
      'selectLanguage': 'Vyberte jazyk',
      'unsavedChanges': 'Neuložené zmeny',
      'saveChanges': 'Uložiť zmeny',
      'discardChanges': 'Zavrhnúť zmeny',

      // Common actions
      'save': 'Uložiť',
      'cancel': 'Zrušiť',
      'delete': 'Vymazať',
      'edit': 'Upraviť',
      'add': 'Pridať',
      'back': 'Späť',
      'ok': 'OK',

      // Screens
      'inventory': 'Inventár',
      'shop': 'Obchod',
      'goals': 'Ciele',
      'calendar': 'Kalendár',
      'financial': 'Financie',

      // Financial
      'balance': 'Zostatok',
      'income': 'Príjem',
      'expense': 'Výdaj',
      'transactions': 'Transakcie',
      'addTransaction': 'Pridať transakciu',

      // Goals
      'goalName': 'Názov cieľa',
      'goalDescription': 'Popis',
      'targetAmount': 'Cieľová suma',
      'currentAmount': 'Aktuálna suma',
      'rewardCoins': 'Odmena v minciach',
      'addGoal': 'Pridať cieľ',
      'goalCompleted': 'Cieľ splnený!',
      'completeGoal': 'Splniť cieľ',

      // Items
      'itemName': 'Názov položky',
      'itemPrice': 'Cena',
      'buy': 'Kúpiť',
      'sell': 'Predať',
      'owned': 'Vlastní',

      // Calendar
      'month': 'Mesiac',
      'year': 'Rok',
      'today': 'Dnes',

      // Confirmation dialogs
      'areYouSure': 'Ste si istí?',
      'confirmation': 'Potvrdenie',

      // Inventory
      'noItemsYet': 'Zatiaľ nie sú položky',
      'yourItemsWillAppearHere': 'Vaše položky sa objavia tu',

      // Shop
      'notEnoughCoins': 'Nedostaatok mincí!',
      'needCoinsHave': 'Potrebujete {need}, máte {have}',
      'purchasedFor': '{item} kúpené za {cost} mincí!',
      'itemPurchasedSuccessfully': 'Nákup bol úspešný!',
      'furniture': 'Nábytok',
      'realEstate': 'Nehnuteľnosti',

      // Calendar months
      'january': 'Január',
      'february': 'Február',
      'march': 'Marec',
      'april': 'Apríl',
      'may': 'Máj',
      'june': 'Jún',
      'july': 'Júl',
      'august': 'August',
      'september': 'September',
      'october': 'Október',
      'november': 'November',
      'december': 'December',

      // Calendar weekdays
      'monday': 'Po',
      'tuesday': 'Ut',
      'wednesday': 'St',
      'thursday': 'Št',
      'friday': 'Pi',
      'saturday': 'So',
      'sunday': 'Ne',

      // Dialog labels
      'todayLabel': 'Dnes',
      'errorLoadingGoals': 'Chyba pri načítaní cieľov',
      'createNewGoal': 'Vytvoriť nový cieľ',
      'goalTitle': 'Názov cieľa',
      'coinsReward': 'Odmena v minciach',
      'targetMoneyAmount': 'Cieľová suma peňazí (€)',
      'selectDeadline': 'Vyberte deadline',
      'addNew': 'Pridať nový',
      'noTransactions': 'Zatiaľ bez transakcií',
      'addTransactionLabel': 'Pridať transakciu',
      'amountEuro': 'Suma (€)',
      'selectType': 'Vyberte typ',
      'selectGoal': 'Vyberte cieľ (voliteľné)',
      'createdAt': 'Vytvorené',

      // Additional missing texts
      'pickDate': 'Vyberte dátum',
      'enterGoalTitle': 'Prosím zadajte názov cieľa',
      'goalCreatedSuccessfully': 'Cieľ bol úspešne vytvorený',
      'failedToCreateGoal': 'Chyba pri vytváraní cieľa',
      'createGoal': 'Vytvoriť cieľ',
      'refreshGoals': 'Obnoviť ciele',
      'failedToCompleteGoal': 'Chyba pri splnení cieľa',
      'goalDeleted': 'Cieľ bol vymazaný',
      'failedToDeleteGoal': 'Chyba pri vymazávaní cieľa',
      'noGoalAllocation': 'Bez pridelenia cieľu',
      'refresh': 'Obnoviť',
      'noGoal': 'Bez cieľa',
      'plus': '+',
      'minus': '-',
      'statistics': 'Štatistika',
      'gain': 'Príjem',
      'purchase': 'Nákup',
      'reassignFunds': 'Presunúť peniaze',
      'fromGoal': 'Z cieľa',
      'toGoal': 'Do cieľa',
      'amount': 'Suma',
      'note': 'Poznámka',
      'amountExceedsAvailableGoalFunds':
          'Suma prekračuje dostupné peniaze cieľa.',
      'amountExceedsGoalTarget': 'Suma by prekročila cieľovú sumu.',
      'fundsReassignedSuccessfully': 'Peniaze boli úspešne presunuté',
      'addGainOrPurchase': 'Pridať príjem / nákup',
      'editTransaction': 'Upraviť transakciu',
      'noTransactionsYetTapAdd':
          'Zatiaľ nie sú žiadne transakcie. Klepnite na + a pridajte jednu!',
      'moneyAssignedAndGoalCompleted': 'Peniaze priradené a cieľ splnený!',
      'moneyAssignedToGoal': 'Peniaze boli priradené k cieľu',
      'assignMoneyToGoal': 'Priradiť peniaze k cieľu {goal}',
      'availableBalance': 'Dostupný zostatok: {amount}',
      'amountExceedsCurrentAppBalance':
          'Suma prekračuje aktuálny zostatok aplikácie.',
      'assignMoney': 'Priradiť peniaze',
      'goalAmount': 'Suma cieľa',
      'goalCompletedChrumkaOnly': 'Cieľ splnený! +1 Chrumka',
      'goalCompletedCoinsAndChrumka':
          'Cieľ splnený! +{coins} mincí & +1 Chrumka',
      'goalDeletedAndMoneyReturned':
          'Cieľ bol vymazaný a peniaze sa vrátili do zostatku',
      'difficultyEasy': 'Ľahká',
      'difficultyMedium': 'Stredná',
      'difficultyHard': 'Ťažká',
      'difficulty': 'Náročnosť',
      'rewardLabel': 'Odmena',

      // Chrumko tips bubble
      'chrumkoTipLabel': 'Tip od Chrumka 💡',
      'chrumkoTipDismiss': 'Klepni pre zavretie',
      'chrumkoTip0': 'Ja si vždy časť peňazí odložím. Skús to aj ty! 💰',
      'chrumkoTip1': 'Chrumko radí: najprv premýšľaj, až potom nakupuj! 🛍️',
      'chrumkoTip2':
          'Ja si sledujem výdavky. Vďaka tomu viem, kam moje peniaze idú! 📊',
      'chrumkoTip3': 'Keď plánujem nákupy, ušetrím viac peňazí. 📝',
      'chrumkoTip4': 'Aj malé úspory sa časom zmenia na veľké! 📈',
      'chrumkoTip5': 'Ja si vždy nechám rezervu na nečakané veci! 🎁',
      'chrumkoTip6': 'Nemusím kúpiť všetko hneď. Niekedy sa oplatí počkať! ⏳',
      'chrumkoTip7': 'Každé ušetrené euro je krok k mojim cieľom! 🎯',
      'chrumkoTip8':
          'Premyslené rozhodnutia robia z peňazí dobrého pomocníka! 🤝',
      'chrumkoTip9': 'Rozpočet mi pomáha mať peniaze pod kontrolou! 🔍',
      'chrumkoTip10': 'Ja šetrím na veci, ktoré sú pre mňa naozaj dôležité! 🌟',
      'chrumkoTip11': 'Keď šetrím pravidelne, moje úspory rastú rýchlejšie! 📈',
      'chrumkoTip12': 'Pred nákupom si vždy položím otázku: potrebujem to? 🛒',
      'chrumkoTip13': 'Finančná disciplína mi pomáha plniť si sny! 💭',
      'chrumkoTip14': 'Pamätaj: peniaze sú nástroj, nie cieľ! 🌍',
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
    return languageCode == _languageSk ? 'Slovenčina' : 'English';
  }
}
