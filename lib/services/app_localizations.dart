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
      'gameInfo': 'Game Info',
      'moreSettingsComingSoon': 'More settings coming soon...',
      
      // Music settings
      'backgroundMusic': 'Background Music',
      'enableBackgroundMusic': 'Enable Background Music',
      'disableBackgroundMusic': 'Disable Background Music',
      'musicVolume': 'Music Volume',
      'volumeControl': 'Volume Control',
      
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
      'total': 'Total',
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
      'noGoalsYet': 'No goals yet',
      'createYourFirstGoal': 'Create your first goal to get started',
      'reward': 'Reward',
      'difficulty': 'Difficulty',
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'goalAmount': 'Goal Amount',
      'enterMoneyTarget': 'Enter money target',
      'coinsLabel': 'coins',
      'dueDate': 'Due Date',
      'enterGoalDescription': 'Enter goal description',
      'enterGoalTitleHint': 'Enter goal title',
      'goalLoadFail': 'Failed to load goals.',
      'rewardAiInfo': 'Reward is based on AI difficulty (Easy: 50, Medium: 100, Hard: 200).',
      'needMoreGoalDetails': 'Please provide more details about the goal.',
      'aiSetDifficulty': 'Difficulty set to {difficulty}: {reason}',
      'refreshGoals': 'Refresh goals',
      'loadingGoals': 'Loading goals...',
      'goalsActive': 'Active Goals',
      'goalsCompleted': 'Completed Goals',
      'goalRewardLabel': 'Reward {coins}',
      'goalCompleteProgressError': 'Goal can only be completed at 100% progress.',
      'goalCompletedCoinsChrumka': 'Goal completed! +{coins} coins & +1 Chrumka',
      'goalCompletedChrumka': 'Goal completed! +1 Chrumka',
      'failedToCompleteGoal': 'Failed to complete goal',
      'goalDeleted': 'Goal deleted',
      'failedToDeleteGoal': 'Failed to delete goal',
      'savedProgress': 'Saved {saved} / {target}',
      'amountExceedsGoalFunds': 'Amount exceeds available goal funds.',
      'difficultyChosenByAi': 'Difficulty will be chosen automatically by AI.',
      'assignMoney': 'Assign money',
      'assignMoneyToGoal': 'Assign money to {goal}',
      'enterAmount': 'Enter amount',
      'amountExceedsBalance': 'Amount exceeds current balance.',
      'amountExceedsGoalTarget': 'Amount exceeds goal target.',
      'moneyAssignedSuccess': 'Money assigned to goal.',
      'notEnoughBalance': 'Not enough balance to assign.',
      'incomeGoalDisabledHelper': 'Income goes to balance. Assign it to goals later.',
      'reassignFundsTitle': 'Reassign Funds',
      'fromGoal': 'From goal',
      'toGoal': 'To goal',
      'fundsReassignedSuccess': 'Funds reassigned successfully',
      'reassignMove': 'Move',
      'reassignedToAnother': 'Reassigned to another goal',
      'reassignedFromAnother': 'Reassigned from another goal',
      'reassignTooltip': 'Reassign funds between goals',
      
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
      'comingSoon': 'Coming soon...',
      
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
      'noTransactionsYet': 'No transactions yet. Tap + to add one!',
      'noDataForMonth': 'No data yet',
      
      // Additional missing texts
      'pickDate': 'Pick Date',
      'enterGoalTitle': 'Please enter a goal title',
      'goalCreatedSuccessfully': 'Goal created successfully',
      'failedToCreateGoal': 'Failed to create goal',
      'createGoal': 'Create Goal',
      'noGoalAllocation': 'No goal allocation',
      'refresh': 'Refresh',
      'noGoal': 'No goal',
      'plus': '+',
      'minus': '-',
      'statistics': 'Statistics',
      'gain': 'Gain',
      'purchase': 'Purchase',
      'addGainOrPurchase': 'Add Gain / Purchase',
      'editTransaction': 'Edit Transaction',
      'allocateToGoal': 'Allocate to Goal',
      'amount': 'Amount',
      'note': 'Note',
      'completedGoalsCannotAccept': 'Completed goals cannot accept more progress.',
      
      // Transaction categories
      'category': 'Category',
      'categoryAuto': 'Auto',
      'categoryRestaurants': 'Restaurants',
      'categoryHealth': 'Health and care',
      'categorySupermarket': 'Supermarket',
      'categoryLeisure': 'Leisure',
      'categoryOther': 'Other',
      'categoryUnassigned': 'Unassigned',
      'categoryPocketMoney': 'Pocket money',

      // Chrumko learning
      'quizes': 'Quizes',
      'lessons': 'Lessons',

      // Chrumko tips bubble
      'chrumkoTipLabel': "Chrumko's Tip 💡",
      'chrumkoTipDismiss': 'Tap to dismiss',
      'chrumkoTip0': 'I always set aside part of my money. Try it too! 💰',
      'chrumkoTip1': 'Chrumko advises: think first, then buy. 🛍️',
      'chrumkoTip2': 'I track my expenses. That way I know where my money goes! 📊',
      'chrumkoTip3': 'Even small savings grow into something big over time. 📈',
      'chrumkoTip4': 'When I plan my purchases, I save more money. 📝',
      'chrumkoTip5': 'I always keep a reserve for unexpected things! 🎁',
      'chrumkoTip6': 'A budget helps me stay in control of my money! 📋',
      'chrumkoTip7': 'I don\'t have to buy everything right away. Sometimes it pays to wait! ⏳',
      'chrumkoTip8': 'Every saved euro is a step towards my goals! 🎯',
      'chrumkoTip9': 'Thoughtful decisions make money a great helper! 🤝',
      'chrumkoTip10': 'I save up for things that are truly important to me! 🌟',
      'chrumkoTip11': 'When I save regularly, my savings grow faster! 📈',
      'chrumkoTip12': 'Before buying, I always ask myself: do I really need this? 🛒',
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
      'gameInfo': 'Informácie o hre',
      'moreSettingsComingSoon': 'Ďalšie nastavenia čoskoro...',
      
      // Music settings
      'backgroundMusic': 'Hudba na pozadí',
      'enableBackgroundMusic': 'Zapnúť hudbu na pozadí',
      'disableBackgroundMusic': 'Vypnúť hudbu na pozadí',
      'musicVolume': 'Hlasitosť hudby',
      'volumeControl': 'Ovládanie hlasitosti',
      
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
      'total': 'Spolu',
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
      'noGoalsYet': 'Zatiaľ bez cieľov',
      'createYourFirstGoal': 'Vytvor svoj prvý cieľ a začni',
      'reward': 'Odmena',
      'difficulty': 'Ťažkosť',
      'easy': 'Ľahký',
      'medium': 'Stredný',
      'hard': 'Ťažký',
      'goalAmount': 'Cieľová suma',
      'enterMoneyTarget': 'Zadaj cieľovú sumu',
      'coinsLabel': 'mincí',
      'dueDate': 'Termín',
      'enterGoalDescription': 'Zadaj popis cieľa',
      'enterGoalTitleHint': 'Zadaj názov cieľa',
      'goalLoadFail': 'Nepodarilo sa načítať ciele.',
      'rewardAiInfo': 'Odmena závisí od AI náročnosti (Ľahký: 50, Stredný: 100, Ťažký: 200).',
      'needMoreGoalDetails': 'Prosím, pridajte viac detailov o cieli.',
      'aiSetDifficulty': 'Náročnosť nastavená na {difficulty}: {reason}',
      'refreshGoals': 'Obnoviť ciele',
      'loadingGoals': 'Načítavam ciele...',
      'goalsActive': 'Aktívne ciele',
      'goalsCompleted': 'Dokončené ciele',
      'goalRewardLabel': 'Odmena {coins}',
      'goalCompleteProgressError': 'Cieľ možno dokončiť len pri 100 % progrese.',
      'goalCompletedCoinsChrumka': 'Cieľ dokončený! +{coins} mincí a +1 Chrumka',
      'goalCompletedChrumka': 'Cieľ dokončený! +1 Chrumka',
      'failedToCompleteGoal': 'Cieľ sa nepodarilo dokončiť',
      'goalDeleted': 'Cieľ bol odstránený',
      'failedToDeleteGoal': 'Cieľ sa nepodarilo odstrániť',
      'savedProgress': 'Ušetrené {saved} / {target}',
      'amountExceedsGoalFunds': 'Suma presahuje dostupné prostriedky cieľa.',
      'difficultyChosenByAi': 'Náročnosť vyberie automaticky AI.',
      'assignMoney': 'Priradiť peniaze',
      'assignMoneyToGoal': 'Priradiť peniaze k cieľu {goal}',
      'enterAmount': 'Zadajte sumu',
      'amountExceedsBalance': 'Suma presahuje aktuálny zostatok.',
      'amountExceedsGoalTarget': 'Suma presahuje cieľovú hodnotu.',
      'moneyAssignedSuccess': 'Peniaze boli priradené k cieľu.',
      'notEnoughBalance': 'Nedostatočný zostatok na priradenie.',
      'incomeGoalDisabledHelper': 'Príjem ide do zostatku. Priraďte ho k cieľom neskôr.',
      'reassignFundsTitle': 'Presunúť prostriedky',
      'fromGoal': 'Z cieľa',
      'toGoal': 'Do cieľa',
      'fundsReassignedSuccess': 'Prostriedky boli presunuté.',
      'reassignMove': 'Presunúť',
      'reassignedToAnother': 'Presunuté do iného cieľa',
      'reassignedFromAnother': 'Presunuté z iného cieľa',
      'reassignTooltip': 'Presuňte peniaze medzi cieľmi',
      
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
      'comingSoon': 'Čoskoro...',
      
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
      'createdAt': 'Vytvorené',      'noTransactionsYet': 'Zatiaľ žiadne transakcie. Klepni + a pridaj jednu!',
      'noDataForMonth': 'Zatiaľ žiadne dáta',      
      // Additional missing texts
      'pickDate': 'Vyberte dátum',
      'enterGoalTitle': 'Prosím zadajte názov cieľa',
      'goalCreatedSuccessfully': 'Cieľ bol úspešne vytvorený',
      'failedToCreateGoal': 'Chyba pri vytváraní cieľa',
      'createGoal': 'Vytvoriť cieľ',
      'noGoalAllocation': 'Bez pridelenia cieľu',
      'refresh': 'Obnoviť',
      'noGoal': 'Bez cieľa',
      'plus': '+',
      'minus': '-',
      'statistics': 'Štatistika',
      'gain': 'Príjem',
      'purchase': 'Nákup',
      'addGainOrPurchase': 'Pridať príjem / nákup',
      'editTransaction': 'Upraviť transakciu',
      'allocateToGoal': 'Prideliť k cieľu',
      'amount': 'Suma',
      'note': 'Poznámka',
      'completedGoalsCannotAccept': 'Splnené ciele nemôžu prijímať ďalší pokrok.',

      // Transaction categories
      'category': 'Kategória',
      'categoryAuto': 'Auto',
      'categoryRestaurants': 'Reštaurácie',
      'categoryHealth': 'Zdravie a starostlivosť',
      'categorySupermarket': 'Supermarket',
      'categoryLeisure': 'Voľný čas',
      'categoryOther': 'Ostatné',
      'categoryUnassigned': 'Nezaradené',
      'categoryPocketMoney': 'Vreckové',

      // Chrumko learning
      'quizes': 'Kvízy',
      'lessons': 'Lekcie',

      // Chrumko tips bubble
      'chrumkoTipLabel': 'Tip od Chrumka 💡',
      'chrumkoTipDismiss': 'Klepni pre zavretie',
      'chrumkoTip0': 'Ja si vždy časť peňazí odložím. Skús to aj ty! 💰',
      'chrumkoTip1': 'Chrumko radí: najprv premýšľaj, až potom nakupuj! 🛍️',
      'chrumkoTip2': 'Ja si sledujem výdavky. Vďaka tomu viem, kam moje peniaze idú! 📊',
      'chrumkoTip3': 'Keď plánujem nákupy, ušetrím viac peňazí. 📝',
      'chrumkoTip4': 'Aj malé úspory sa časom zmenia na veľké! 📈',
      'chrumkoTip5': 'Ja si vždy nechám rezervu na nečakané veci! 🎁',
      'chrumkoTip6': 'Nemusím kúpiť všetko hneď. Niekedy sa oplatí počkať! ⏳',
      'chrumkoTip7': 'Každé ušetrené euro je krok k mojim cieľom! 🎯',
      'chrumkoTip8': 'Premyslené rozhodnutia robia z peňazí dobrého pomocníka! 🤝',
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
