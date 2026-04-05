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

      // Onboarding
      'onboardingTitle': 'Welcome',
      'onboardingSubtitle':
          'Set up your profile so we can personalize Money Mansion for you.',
      'onboardingNameLabel': 'Name or nickname',
      'onboardingAgeLabel': 'Age',
      'onboardingIncomeLabel': 'Monthly income',
      'onboardingLanguageLabel': 'Language',
      'onboardingContinue': 'Continue',
      'onboardingNameError': 'Please enter your name.',
      'onboardingAgeError': 'Enter a valid age greater than 0.',
      'onboardingIncomeError': 'Enter a monthly income of 0 or more.',
      'onboardingExperienceLabel': 'Financial experience',
      'onboardingGoalLabel': 'Main goal',
      'onboardingExpensesLabel': 'Estimated monthly expenses (optional)',
      'onboardingIncomeTypeLabel': 'Income type',
      'experienceBeginner': 'Beginner',
      'experienceIntermediate': 'Intermediate',
      'goalSaving': 'Saving',
      'goalLearning': 'Learning',
      'goalTracking': 'Tracking spending',
      'incomeTypeStudent': 'Student',
      'incomeTypePartTime': 'Part-time',
      'incomeTypeFullTime': 'Full-time',
      'onboardingExpensesError': 'Enter monthly expenses of 0 or more.',

      // Tutorial
      'tutorialNext': 'Next',
      'tutorialSkip': 'Skip tutorial',
      'tutorialRestart': 'Restart tutorial',
      'tutorialNavigateHint': '',
      'tutorialTapHere': 'Tap here',
      'tutorialTapToContinue': 'tap to continue →',
      'tutorialTapToFinish': 'tap to finish 🎉',
      'tutorialSpeakerName': 'Chrumko',
      'tutorialTopBar':
          'At the top you can see your Coins 🪙, Money 💶 and Chrumky 🐾. Coins are earned in-game; money tracks your real finances!',
      'tutorialFinancialIntro':
          'Welcome to my favourite tab — Finances! Here I track every euro that comes in or goes out. The chart shows your balance over time.',
      'tutorialFinancialTabs':
          'Use the tabs at the top: Total shows everything, Income shows gains, and Expense shows purchases. I always review all three!',
      'tutorialShopCategories':
          'I love browsing the categories — Furniture, Decor, Doors, Walls, Floors. Each one has different items to upgrade your mansion!',
      'tutorialGoalsIntro':
          'Here are your saving goals! Each goal has a target amount, a deadline and a difficulty that I set automatically using AI. Pretty smart, right?',
      'tutorialGoalsAssign':
          'Tap any goal card to assign money from your balance to it. I always put a little aside each week — small steps, big results! 💪',
      'tutorialGoalsReassign':
          'See the ⇄ button in the top right? That lets me move money between goals if my priorities change. Very handy!',
      'tutorialGoalsComplete':
          'Once a goal reaches 100%, tick the checkbox to complete it and claim your coin reward. Completing goals also earns you a Chrumka! 🐾',
      'tutorialRoomExplain':
          'This is your mansion! You already have a few starter pieces in your inventory — we\'ll place some in a moment. As you earn coins and buy more, your room keeps growing. The better your finances, the better your home!',
      'tutorialSettingsInfo':
          'In Settings you can change the language, toggle background music, adjust the volume, and update your personal profile. Feel free to explore everything!',
      'tutorialHomeWelcome':
          'Hey there! I\'m Chrumko, your financial guide. Welcome to your very own mansion — let me show you around!',
      'tutorialHomeBalance':
          'Up here you can see your coins and money. These are your most important resources — spend them wisely!',
      'tutorialFinancialNav':
          'First things first — let me show you the Financial tab. That\'s where I keep track of all income and expenses!',
      'tutorialFinancialAction':
          'Great! Now tap the + button to add your first transaction. I always log everything — it\'s the key to good finances!',
      'tutorialGoalsNav':
          'Next up — the Goals tab! I love setting saving targets. Let me show you where to find them.',
      'tutorialGoalsAction':
          'Tap + to create a goal. I recommend starting with something achievable — small wins build great habits!',
      'tutorialInventoryNav':
          'Let\'s check out your Inventory! That\'s where all the items you own are stored.',
      'tutorialInventoryAction':
          'Here are all your owned items. I always keep track of what I have — knowledge is power!',
      'tutorialSettings':
          'In Settings you can change the language, toggle music, and even restart this tutorial if you want a refresher from me!',
      'tutorialDoAction': 'Do this action to continue.',
      'tutorialAddGoal':
          'Tap + to create a goal. I always set a target amount — it keeps me motivated!',
      'tutorialCalendar':
          'This is the Calendar! I use it to plan ahead and never miss important financial dates.',
      'tutorialLessons':
          'And here\'s my favourite spot — the Learning section! Come back here to find lessons and quizzes I\'ve prepared for you.',
      'tutorialLessonsReturn':
          'Browse lessons or quizzes if you like. When you\'re ready, tap Return in the bottom-left corner to close this — then we\'ll continue!',
      'tutorialRoomEdit':
          'You can customise your mansion right here! I believe a good environment motivates better financial decisions.',
      'tutorialRoomEditIntro':
          'Welcome to edit mode! Drag with two fingers to move the view, pinch to zoom, and use the purple inventory button when you\'re ready to pull items into the room.',
      'tutorialRoomEditInventory':
          'Tap the inventory button — you\'ll see everything you own. Pick any item that isn\'t already placed and tap it to drop it into your room.',
      'tutorialRoomEditPlace':
          'Nice! Drag the item to move it, or tap empty space to deselect. When you\'re happy with the layout, we\'ll save it next.',
      'tutorialRoomEditSave':
          'Tap the checkmark to save your layout and return home. You can always come back to edit again later!',
      'tutorialFinish':
          'You made it! I\'m proud of you. You\'re all set to take control of your finances. Remember — I\'m always here to help! 💪',
      'tutorialShopNav':
          'Now let\'s visit the Shop! I always browse before buying — smart shopping starts with knowing your options.',
      'tutorialShopAction':
          'Browse the items and buy what you like. Just remember — only spend what you can afford! I always do. 😄',
      'tutorialCalendarAction': 'Tap the calendar to see dates.',
      'tutorialSettingsAction': 'Open settings to adjust language and music.',
      'tutorialBack':
          'Nicely done! Now tap the back button and let\'s continue our tour.',

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
      'rewardAiInfo':
          'Reward is based on AI difficulty (Easy: 50, Medium: 100, Hard: 200).',
      'needMoreGoalDetails': 'Please provide more details about the goal.',
      'aiSetDifficulty': 'Difficulty set to {difficulty}: {reason}',
      'refreshGoals': 'Refresh goals',
      'loadingGoals': 'Loading goals...',
      'goalsActive': 'Active Goals',
      'goalsCompleted': 'Completed Goals',
      'goalRewardLabel': 'Reward {coins}',
      'goalCompleteProgressError':
          'Goal can only be completed at 100% progress.',
      'goalCompletedCoinsChrumka':
          'Goal completed! +{coins} coins & +1 Chrumka',
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
      'incomeGoalDisabledHelper':
          'Income goes to balance. Assign it to goals later.',
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
      'completedGoalsCannotAccept':
          'Completed goals cannot accept more progress.',

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

      // Onboarding
      'onboardingTitle': 'Vitajte',
      'onboardingSubtitle':
          'Nastavte si profil, aby sme prispôsobili Money Mansion.',
      'onboardingNameLabel': 'Meno alebo prezývka',
      'onboardingAgeLabel': 'Vek',
      'onboardingIncomeLabel': 'Mesačný príjem',
      'onboardingLanguageLabel': 'Jazyk',
      'onboardingContinue': 'Pokračovať',
      'onboardingNameError': 'Zadajte svoje meno alebo prezývku.',
      'onboardingAgeError': 'Zadajte platný vek väčší ako 0.',
      'onboardingIncomeError': 'Zadajte mesačný príjem minimálne 0.',
      'onboardingExperienceLabel': 'Finančné skúsenosti',
      'onboardingGoalLabel': 'Hlavný cieľ',
      'onboardingExpensesLabel': 'Odhad mesačných výdavkov (voliteľné)',
      'onboardingIncomeTypeLabel': 'Typ príjmu',
      'experienceBeginner': 'Začiatočník',
      'experienceIntermediate': 'Stredne pokročilý',
      'goalSaving': 'Sporenie',
      'goalLearning': 'Vzdelávanie',
      'goalTracking': 'Sledovanie výdavkov',
      'incomeTypeStudent': 'Študent',
      'incomeTypePartTime': 'Polovičný úväzok',
      'incomeTypeFullTime': 'Plný úväzok',
      'onboardingExpensesError': 'Zadajte mesačné výdavky aspoň 0.',

      // Tutorial
      'tutorialNext': 'Ďalej',
      'tutorialSkip': 'Preskočiť návod',
      'tutorialRestart': 'Spustiť návod znova',
      'tutorialNavigateHint': '',
      'tutorialTapHere': 'Klepni sem',
      'tutorialTapToContinue': 'klepni pre pokračovanie →',
      'tutorialTapToFinish': 'klepni pre ukončenie 🎉',
      'tutorialSpeakerName': 'Chrumko',
      'tutorialTopBar':
          'Hore vidíš Mince 🪙, Peniaze 💶 a Chrumky 🐾. Mince zarábam v hre; peniaze sledujú moje skutočné financie!',
      'tutorialFinancialIntro':
          'Vitaj na mojej obľúbenej karte — Financie! Tu sledujem každé euro, ktoré príde alebo odíde. Graf ukazuje zostatok v čase.',
      'tutorialFinancialTabs':
          'Použi karty hore: Spolu ukazuje všetko, Príjem ukazuje zisky a Výdaj ukazuje nákupy. Ja si vždy prezerám všetky tri!',
      'tutorialShopCategories':
          'Milujem prezeranie kategórií — Nábytok, Dekor, Dvere, Steny, Podlahy. Každá má iné predmety na vylepšenie sídla!',
      'tutorialGoalsIntro':
          'Tu sú tvoje ciele sporenia! Každý cieľ má cieľovú sumu, termín a náročnosť, ktorú nastavujem automaticky pomocou AI. Šikovné, nie?',
      'tutorialGoalsAssign':
          'Klepni na kartu ľubovoľného cieľa a priraď mu peniaze zo zostatku. Ja si vždy odložím trochu každý týždeň — malé kroky, veľké výsledky! 💪',
      'tutorialGoalsReassign':
          'Vidíš tlačidlo ⇄ vpravo hore? To mi umožňuje presúvať peniaze medzi cieľmi, keď sa zmenia moje priority. Veľmi užitočné!',
      'tutorialGoalsComplete':
          'Keď cieľ dosiahne 100%, zaškrtni políčko a dostaň mincovú odmenu. Splnenie cieľa ti tiež prinesie Chrumku! 🐾',
      'tutorialRoomExplain':
          'Toto je tvoje sídlo! Už máš v inventári pár štartových predmetov — o chvíľu ich spolu umiestnime. Keď budeš zarábať mince a nakupovať viac, izba porastie. Čím lepšie sú tvoje financie, tým krajší je domov!',
      'tutorialSettingsInfo':
          'V Nastaveniach môžeš zmeniť jazyk, zapnúť/vypnúť hudbu na pozadí, nastaviť hlasitosť a aktualizovať svoj profil. Pokojne si všetko prezri!',
      'tutorialHomeWelcome':
          'Ahoj! Som Chrumko, tvoj finančný sprievodca. Vitaj vo svojom sídle — ukážem ti, ako tu všetko funguje!',
      'tutorialHomeBalance':
          'Hore vidíš svoje mince a peniaze. To sú tvoje najdôležitejšie zdroje — narábaj s nimi múdro!',
      'tutorialShop':
          'V obchode si môžeš kúpiť nábytok a predmety. Ja vždy premýšľam, než niečo kúpim!',
      'tutorialFinancial':
          'Vo Financiách sledujem všetky príjmy a výdavky. Vďaka tomu mám peniaze vždy pod kontrolou!',
      'tutorialFinancialNav':
          'Prvá zastávka — karta Financie! Tam si evidujem všetky príjmy a výdavky. Poďme sa pozrieť!',
      'tutorialFinancialAction':
          'Skvelé! Klepni na + a pridaj svoju prvú transakciu. Ja si zaznamenávam každú — je to základ dobrých financií!',
      'tutorialGoals':
          'Rád si stanovujem ciele sporenia. Odporúčam začať niečím dosiahnuteľným — malé úspechy budujú skvelé návyky!',
      'tutorialGoalsAction':
          'Klepni na + a vytvor cieľ. Ja odporúčam začať niečím dosiahnuteľným — malé víťazstvá budujú skvelé návyky!',
      'tutorialGoalsNav':
          'Ďalej — karta Ciele! Zbožňujem stanovovať si ciele sporenia. Ukážem ti kde ich nájdeš.',
      'tutorialInventory':
          'V inventári mám prehľad o všetkom, čo vlastním. Prehľad je základ!',
      'tutorialInventoryNav':
          'Pozrime sa do Inventára! Tam sú uložené všetky predmety, ktoré vlastníš.',
      'tutorialInventoryAction':
          'Tu sú tvoje vlastnené predmety. Ja si vždy sledujem, čo mám — vedomosti sú sila!',
      'tutorialSettings':
          'V nastaveniach môžeš zmeniť jazyk, zapnúť hudbu a dokonca reštartovať tento návod, ak si chceš zopakovať moje rady!',
      'tutorialDoAction': 'Vykonaj túto akciu, aby si pokračoval.',
      'tutorialAddTransaction':
          'Klepni na + a pridaj transakciu. Ja si zaznamenávam každú — je to základ!',
      'tutorialAddGoal':
          'Klepni na + a vytvor cieľ. Ja si vždy stanovujem cieľovú sumu — motivuje ma to!',
      'tutorialCalendar':
          'Tu je Kalendár! Ja ho používam na plánovanie a nikdy nezabudnem na dôležité finančné dátumy.',
      'tutorialCalendarAction': 'Klepni na kalendár a pozri dátumy.',
      'tutorialLessons':
          'A toto je moje obľúbené miesto — sekcia Učenia! Vrať sa sem pre lekcie a kvízy, ktoré som pre teba pripravil.',
      'tutorialLessonsReturn':
          'Môžeš si pozrieť lekcie alebo kvízy. Keď budeš pripravený, klepni v ľavom dolnom rohu na Späť a zatvor to — potom pokračujeme!',
      'tutorialRoomEdit':
          'Tu si môžeš prispôsobiť svoje sídlo! Verím, že dobré prostredie motivuje k lepším finančným rozhodnutiam.',
      'tutorialRoomEditIntro':
          'Vitaj v režime úprav! Potiahnutím dvoma prstami posunieš pohľad, štipnutím priblížiš alebo oddiališ, a keď budeš pripravený, použi fialové tlačidlo inventára.',
      'tutorialRoomEditInventory':
          'Klepni na inventár — uvidíš všetko, čo vlastníš. Vyber predmet, ktorý ešte nie je v miestnosti, a klepni naň, aby si ho pridal do izby.',
      'tutorialRoomEditPlace':
          'Super! Predmet potiahni, aby si ho presunul, alebo klepni na prázdne miesto, aby si zrušil výber. Keď budeš spokojný s rozložením, uložíme ho.',
      'tutorialRoomEditSave':
          'Klepni na fajku a ulož rozloženie a vráť sa domov. K úpravám sa môžeš kedykoľvek vrátiť!',
      'tutorialBack':
          'Výborne! Teraz klepni na tlačidlo späť a pokračujme v prehliadke.',
      'tutorialFinish':
          'Zvládol si to! Som na teba hrdý. Teraz si pripravený prevziať kontrolu nad svojimi financiami. Pamätaj — vždy som tu pre teba! 💪',
      'tutorialShopNav':
          'Poďme sa pozrieť do Obchodu! Ja vždy prehliadam pred nákupom — múdre nakupovanie začína poznaním možností.',
      'tutorialShopAction':
          'Prezri si tovar a kúp, čo sa ti páči. Len pamätaj — míňaj len to, čo si môžeš dovoliť! Ja sa vždy riadim týmto pravidlom. 😄',
      'tutorialSettingsAction': 'Otvor nastavenia a uprav jazyk alebo hudbu.',

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
      'rewardAiInfo':
          'Odmena závisí od AI náročnosti (Ľahký: 50, Stredný: 100, Ťažký: 200).',
      'needMoreGoalDetails': 'Prosím, pridajte viac detailov o cieli.',
      'aiSetDifficulty': 'Náročnosť nastavená na {difficulty}: {reason}',
      'refreshGoals': 'Obnoviť ciele',
      'loadingGoals': 'Načítavam ciele...',
      'goalsActive': 'Aktívne ciele',
      'goalsCompleted': 'Dokončené ciele',
      'goalRewardLabel': 'Odmena {coins}',
      'goalCompleteProgressError':
          'Cieľ možno dokončiť len pri 100 % progrese.',
      'goalCompletedCoinsChrumka':
          'Cieľ dokončený! +{coins} mincí a +1 Chrumka',
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
      'incomeGoalDisabledHelper':
          'Príjem ide do zostatku. Priraďte ho k cieľom neskôr.',
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
      'createdAt': 'Vytvorené',
      'noTransactionsYet': 'Zatiaľ žiadne transakcie. Klepni + a pridaj jednu!',
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
      'completedGoalsCannotAccept':
          'Splnené ciele nemôžu prijímať ďalší pokrok.',

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
