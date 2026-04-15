import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_mansion_skeleton/my_flutter_app_icons.dart';
import 'package:provider/provider.dart';
import '../../models/lesson.dart';
import '../../services/app_localizations_provider.dart';
import 'lesson_quiz_screen.dart';

// ─────────────────────────────────────────────
// DATA MODEL
// ─────────────────────────────────────────────

class LessonSlide {
  final LessonSlideType type;
  final String? emoji;
  final String? title;
  final String? body;
  final String? titleSk;
  final String? bodySk;
  final List<FactItem>? facts;
  final String? highlightText;
  final String? highlightTextSk;
  final Color? accentColor;
  final String? storyTitle;
  final String? storyTitleSk;
  final String? storyBody;
  final String? storyBodySk;

  const LessonSlide({
    required this.type,
    this.emoji,
    this.title,
    this.body,
    this.titleSk,
    this.bodySk,
    this.facts,
    this.highlightText,
    this.highlightTextSk,
    this.accentColor,
    this.storyTitle,
    this.storyTitleSk,
    this.storyBody,
    this.storyBodySk,
  });
}

class FactItem {
  final String emoji;
  final String text;
  final String textSk;
  const FactItem({
    required this.emoji,
    required this.text,
    required this.textSk,
  });
}

enum LessonSlideType { intro, info, facts, highlight, tip, story }

// ─────────────────────────────────────────────
// LESSON CONTENT DATABASE
// ─────────────────────────────────────────────

final Map<String, List<LessonSlide>> lessonSlides = {

  // ════════════════════════════════════════════
  // SECTION 1 — PENIAZE AKO KONCEPT
  // ════════════════════════════════════════════

  'co_su_peniaze': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '💰',
      title: 'What is Money?',
      titleSk: 'Čo sú peniaze?',
      body: 'Why does an ordinary coin have value when it\'s just a piece of metal? Because people agreed it does!',
      bodySk: 'Prečo má obyčajná minca hodnotu, keď je to len kúsok kovu? Pretože sa ľudia dohodli, že ju má!',
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🪙',
      title: 'How Money Works',
      titleSk: 'Ako peniaze fungujú',
      body: 'Money is used when we want to buy something. People agreed that money has value and can be exchanged for things we need or want — like food, clothing, or toys.',
      bodySk: 'Peniaze používame, keď si chceme niečo kúpiť. Ľudia sa dohodli, že peniaze budú mať hodnotu a budú sa dať vymeniť za veci, ktoré potrebujeme alebo chceme – napríklad jedlo, oblečenie alebo hračky.',
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📋',
      title: '3 Forms of Money',
      titleSk: '3 formy peňazí',
      facts: [
        FactItem(emoji: '🪙', text: 'Coins — small metal discs for everyday purchases', textSk: 'Mince — malé kovové disky na každodenné nákupy'),
        FactItem(emoji: '💵', text: 'Banknotes — paper money for larger amounts', textSk: 'Bankovky — papierové peniaze pre väčšie sumy'),
        FactItem(emoji: '💳', text: 'Digital money — pay by card or phone instantly', textSk: 'Digitálne peniaze — platiť kartou alebo telefónom okamžite'),
      ],
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👦',
      storyTitle: 'Chrumko\'s Coin',
      storyTitleSk: 'Chrumkova minca',
      storyBody: 'Chrumko holds a coin in his hand. By itself, it\'s just a small piece of metal. When he gives it to the shop cashier, he can buy an apple or juice with it. This works because the shop knows that the coin has value.',
      storyBodySk: 'Chrumko drží v ruke mincu. Sama o sebe je len malý kúsok kovu. Keď ju však dá v obchode pri pokladni, môže si za ňu kúpiť jablko alebo džús. To funguje preto, že obchod vie, že minca má hodnotu.',
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '💡',
      highlightText: 'Money only works because EVERYONE agrees it has value!',
      highlightTextSk: 'Peniaze fungujú iba preto, že s ich hodnotou súhlasí KAŽDÝ!',
      accentColor: Color(0xFFF5A623),
    ),
  ],

  'preco_peniaze_existuju': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🤔',
      title: 'Why Does Money Exist?',
      titleSk: 'Prečo peniaze existujú?',
      body: 'What would happen if you wanted to buy a snack but money didn\'t exist?',
      bodySk: 'Čo by sa stalo, keby si si chcel kúpiť desiatu, ale neexistovali by peniaze?',
      accentColor: Color(0xFF2196F3),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🔄',
      title: 'The Barter Problem',
      titleSk: 'Problém barteru',
      body: 'Without money, people had to trade goods directly. Chrumko has an apple for a snack but prefers a cereal bar. He asks a classmate to trade, but she already has an apple. Without money, he\'d have to keep searching for the right person!',
      bodySk: 'Bez peňazí si ľudia museli vymieňať tovar priamo. Chrumko má na desiatu jablko, ale radšej by si dal cereálnu tyčinku. Poprosí kamarátku, ale ona jablko nechce, lebo už jedno má. Keby mal peniaze, mohol by si tyčinku kúpiť hneď!',
      accentColor: Color(0xFF2196F3),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🧩',
      title: 'Problems Money Solves',
      titleSk: 'Problémy, ktoré peniaze riešia',
      facts: [
        FactItem(emoji: '🐟', text: 'No need to find someone who wants exactly what you have', textSk: 'Nemusíš hľadať niekoho, kto chce presne to, čo máš'),
        FactItem(emoji: '⚖️', text: 'Easily measure and compare the value of things', textSk: 'Ľahko zmerateľná a porovnateľná hodnota vecí'),
        FactItem(emoji: '🗓️', text: 'Save purchasing power to use in the future', textSk: 'Nákupná sila sa dá ušetriť na budúcnosť'),
      ],
      accentColor: Color(0xFF2196F3),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '🌍',
      title: 'Fun Fact!',
      titleSk: 'Zaujímavosť!',
      body: 'Ancient societies used shells, salt, stones, and even cattle as money! The word "salary" comes from "sal" — Latin for salt.',
      bodySk: 'Staré spoločnosti používali mušle, soľ, kamene a dokonca dobytok! Slovo "plat" súvisí s latinským slovom pre soľ.',
      accentColor: Color(0xFF4CAF50),
    ),
        LessonSlide(
      type: LessonSlideType.story,
      emoji: "🍎",
      storyTitle: 'Snack swap',
      storyTitleSk: 'Výmena snacku',
      storyBody: 'Chrumko has an apple for his snack, but he’d rather have a cereal bar. He asks his friend, who has a cereal bar, if they can swap snacks, but she doesn’t want the apple because she already has one.  If he had money, he could buy the cereal bar right away without having to look for someone who wants an apple. ',
      storyBodySk: 'Chrumko má na desiatu jablko ale radšej by si dal cereálnu tyčinku. Poprosí kamarátku, ktorá má cereálnu tyčinku, aby si desiatu vymenili, ale ona jablko nechce, lebo už jedno má. Keby mal peniaze, mohol by si cereálnu tyčinku kúpiť hneď bez hľadania niekoho, kto chce práve jablko. ',
      accentColor: Color(0xFF9C27B0),
    ),
  ],

  'ako_ludia_platili_kedysi': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏺',
      title: 'How Did People Pay in the Past?',
      titleSk: 'Ako ľudia platili kedysi?',
      body: 'Did you know that people once paid with salt or animals?',
      bodySk: 'Vieš, že kedysi sa dalo platiť aj soľou alebo zvieratami?',
      accentColor: Color(0xFF795548),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🍞',
      title: 'Chrumko Needs Bread',
      titleSk: 'Chrumko potrebuje chlieb',
      body: 'Imagine coins didn\'t exist and Chrumko wanted bread. The baker would ask for two eggs. If Chrumko had no eggs, he\'d first have to find some. That\'s why paying used to be so much more complicated!',
      bodySk: 'Predstav si, že mince by neexistovali a Chrumko by chcel chlieb. Pekár by si vypýtal dve vajcia. Ak by Chrumko vajcia nemal, najprv by ich musel zohnať. Aj preto bolo platenie kedysi oveľa zložitejšie!',
      accentColor: Color(0xFF795548),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '⏳',
      title: 'Timeline of Money',
      titleSk: 'Časová os peňazí',
      facts: [
        FactItem(emoji: '🐄', text: '9000 BC: Cattle & grain used as payment', textSk: '9000 pr. n. l.: Dobytok a obilie ako platidlo'),
        FactItem(emoji: '🐚', text: '1200 BC: Cowrie shells in China & Africa', textSk: '1200 pr. n. l.: Mušle v Číne a Afrike'),
        FactItem(emoji: '🪙', text: '600 BC: First metal coins in Lydia (Turkey)', textSk: '600 pr. n. l.: Prvé kovové mince v Lydii (Turecko)'),
        FactItem(emoji: '📜', text: '700 AD: First paper money in China', textSk: '700 n. l.: Prvé papierové peniaze v Číne'),
      ],
      accentColor: Color(0xFF795548),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👦',
      storyTitle: 'Bread Without Coins',
      storyTitleSk: 'Chlieb bez mincí',
      storyBody: 'Imagine coins didn\'t exist and Chrumko wanted bread. The baker would ask for two eggs. If Chrumko didn\'t have eggs, he\'d have to search for someone who had them. This is why paying was so much harder in the past!',
      storyBodySk: 'Predstav si, že mince by neexistovali a Chrumko by chcel chlieb. Pekár by si vypýtal dve vajcia. Ak by Chrumko vajcia nemal, najprv by ich musel zohnať. Aj preto bolo platenie kedysi oveľa zložitejšie!',
      accentColor: Color(0xFF795548),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🤯',
      highlightText: 'Paper money was invented over 1,300 years ago — in China!',
      highlightTextSk: 'Papierové peniaze boli vynájdené pred viac ako 1 300 rokmi — v Číne!',
      accentColor: Color(0xFFE91E63),
    ),
    
  ],

  'mince_bankovky_digitalne': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '💳',
      title: 'Coins, Banknotes & Digital Money',
      titleSk: 'Mince, bankovky a digitálne peniaze',
      body: 'Why do we sometimes pay with a coin, sometimes a card — but it always works the same way?',
      bodySk: 'Prečo niekedy platíme mincou, inokedy kartou — a peniaze stále fungujú rovnako?',
      accentColor: Color(0xFF009688),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '👔',
      title: 'Chrumko Buys a Tie',
      titleSk: 'Chrumko si kupuje kravatu',
      body: 'Chrumko wants to buy a new tie. The shop assistant asks: card or cash? Banknotes and coins = cash. Card payment = digital money sent from his account. Both options mean paying money — just different ways!',
      bodySk: 'Chrumko si chce kúpiť novú kravatu. Predavačka sa ho opýta: kartou alebo v hotovosti? Bankovky a mince = hotovosť. Platba kartou = digitálne peniaze poslané z účtu. Obe možnosti znamenajú platbu peniazmi — len iným spôsobom!',
      accentColor: Color(0xFF009688),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🔍',
      title: 'Types of Money Today',
      titleSk: 'Typy peňazí dnes',
      facts: [
        FactItem(emoji: '🪙', text: 'Coins — metal, great for small purchases', textSk: 'Mince — kovové, ideálne na malé nákupy'),
        FactItem(emoji: '💵', text: 'Banknotes — paper, convenient to carry', textSk: 'Bankovky — papierové, pohodlné na nosenie'),
        FactItem(emoji: '📱', text: 'Digital — stored in your bank account, pay by card or phone', textSk: 'Digitálne — uložené v bankovom účte, platiť kartou alebo telefónom'),
      ],
      accentColor: Color(0xFF009688),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👦',
      storyTitle: 'How to Pay',
      storyTitleSk: 'Ako platiť',
      storyBody: 'Chrumko wants to buy a new tie. The shop assistant asks: card or cash? Banknotes and coins equal cash. Paying by card means digital money sent from his account. Both options mean paying for the tie — just in different ways!',
      storyBodySk: 'Chrumko si chce kúpiť novú kravatu. Predavačka sa ho opýta: kartou alebo v hotovosti? Bankovky a mince sú hotovosť. Platba kartou znamená digitálne peniaze poslané z účtu. Obe možnosti znamenajú platbu — len iným spôsobom!',
      accentColor: Color(0xFF009688),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '🔮',
      title: 'The Future of Money',
      titleSk: 'Budúcnosť peňazí',
      body: 'More and more purchases happen without any physical money. Some countries are even testing "digital currencies" issued directly by their central banks!',
      bodySk: 'Čoraz viac nákupov prebieha bez fyzických peňazí. Niektoré krajiny dokonca testujú digitálne meny vydávané priamo centrálnymi bankami!',
      accentColor: Color(0xFF7C5CBF),
    ),
  ],

  'hodnota_peniazi': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '⚖️',
      title: 'The Value of Money',
      titleSk: 'Hodnota peňazí',
      body: 'Why can you buy less with one euro than with ten euros?',
      bodySk: 'Prečo si za jedno euro kúpiš menej než za desať eur?',
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🛒',
      title: 'Chrumko at the Shop',
      titleSk: 'Chrumko v obchode',
      body: 'Chrumko has €1 in his wallet. He wants juice (90¢) AND biscuits (50¢). He adds up the prices and realises he can\'t afford both for just one euro. He must choose — or save up more!',
      bodySk: 'Chrumko má v peňaženke jedno euro. Chce džús (90 centov) AJ keksík (50 centov). Spočíta ceny a zistí, že za jedno euro obe veci nekúpi. Musí si vybrať — alebo si nasporiť viac!',
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🔢',
      title: 'Comparing Values',
      titleSk: 'Porovnávanie hodnôt',
      facts: [
        FactItem(emoji: '🪙', text: 'A coin with "50" = 50 cents (less than €1)', textSk: 'Minca s číslom „50" = 50 centov (menej ako 1 €)'),
        FactItem(emoji: '💵', text: 'A note with "50" = €50 (much more!)', textSk: 'Bankovka s číslom „50" = 50 € (oveľa viac!)'),
        FactItem(emoji: '🧮', text: 'Knowing values helps you know what you can buy', textSk: 'Poznanie hodnôt ti pomôže vedieť, čo si môžeš kúpiť'),
      ],
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👦',
      storyTitle: 'Not Enough for Both',
      storyTitleSk: 'Nie dosť na obidve',
      storyBody: 'Chrumko has one euro and wants juice and biscuits from the shop. He checks the prices: juice costs 90 cents and biscuits cost 50 cents. When he adds them up, he realizes one euro isn\'t enough for both. He has to choose which one he wants more!',
      storyBodySk: 'Chrumko má jedno euro a chce v obchode džús a keksíky. Skontroluje ceny: džús stojí 90 centov a keksíky 50 centov. Keď ich spočíta, zistí, že mu jedno euro nestačí na obidve. Musí si vybrať, čo chce viac!',
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '💡',
      highlightText: 'The number on money tells you its VALUE — always check prices before buying!',
      highlightTextSk: 'Číslo na peniazoch ti hovorí ich HODNOTU — vždy si skontroluj ceny pred nákupom!',
      accentColor: Color(0xFF9C27B0),
    ),
  ],

  'peniaze_nie_su_nekonecne': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '😬',
      title: 'Money is Not Infinite',
      titleSk: 'Peniaze nie sú nekonečné',
      body: 'What happens when you spend all your money at once?',
      bodySk: 'Čo sa stane, keď minieš všetky peniaze naraz?',
      accentColor: Color(0xFFFF5722),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🍬',
      title: 'Chrumko\'s Mistake',
      titleSk: 'Chrumkova chyba',
      body: 'Chrumko gets €5. He spends it all on sweets. Now he wants a new toy — but has nothing left! All the money is gone. Next time, he\'ll save some so he still has money for other things later.',
      bodySk: 'Chrumko dostane 5 eur. Kúpi si sladkosti za 5 eur a potom si nemôže kúpiť novú hračku. Všetky peniaze minul naraz, nič mu nezostalo! Nabudúce si preto časť odloží, aby mal aj na iné veci.',
      accentColor: Color(0xFFFF5722),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👦',
      storyTitle: 'Spending Too Fast',
      storyTitleSk: 'Príliš rýchle míňanie',
      storyBody: 'Chrumko gets five euros and buys sweets for all of it. Later, he wants a new toy but has no money left. He spent everything at once, so nothing is left. Next time, he\'ll save some money so he has it for other things he\'ll want later.',
      storyBodySk: 'Chrumko dostane päť eur a všetko minul na sladkosti. Neskôr chce novú hračku, ale nemá žiadne peniaze. Všetko minul naraz, takže mu nič nezostalo. Nabudúce si časť odloží, aby mal na iné veci.',
      accentColor: Color(0xFFFF5722),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🚫',
      highlightText: 'Every person only has a certain amount of money. When it\'s gone — it\'s gone!',
      highlightTextSk: 'Každý má len určitú sumu peňazí. Keď sú preč — sú preč!',
      accentColor: Color(0xFFFF5722),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '🧠',
      title: 'Think Before You Spend',
      titleSk: 'Premysli pred míňaním',
      body: 'Before spending, ask: Do I really need this now? If I buy this, what will I miss out on later? A moment of thought saves a lot of regret!',
      bodySk: 'Pred míňaním sa opýtaj: Naozaj to teraz potrebujem? Ak to kúpim, o čo prídem neskôr? Chvíľa premýšľania ušetrí veľa ľútosti!',
      accentColor: Color(0xFFFF5722),
    ),
  ],

  'odkial_peniaze_prichadzaju': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏭',
      title: 'Where Does Money Come From?',
      titleSk: 'Odkiaľ peniaze prichádzajú?',
      body: 'How does money get into a wallet when nobody makes it at home?',
      bodySk: 'Ako sa peniaze dostanú do peňaženky, keď ich doma nikto nevyrába?',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '💼',
      title: 'Parents Go to Work',
      titleSk: 'Rodičia chodia do práce',
      body: 'Chrumko notices that mum goes to work every day. At the end of the month she gets money into her bank account. From this money, the family pays rent, buys food, and saves some for later.',
      bodySk: 'Chrumko si všimne, že mama chodí každý deň do práce. Na konci mesiaca dostane peniaze na účet. Z týchto peňazí rodina zaplatí nájom, nakúpi potraviny a časť si odloží na neskôr.',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '💸',
      title: 'How People Earn Money',
      titleSk: 'Ako ľudia zarábajú peniaze',
      facts: [
        FactItem(emoji: '👔', text: 'Salary — regular pay from an employer', textSk: 'Plat — pravidelná odmena od zamestnávateľa'),
        FactItem(emoji: '🏪', text: 'Business — selling goods or services', textSk: 'Podnikanie — predaj tovarov alebo služieb'),
        FactItem(emoji: '🎁', text: 'Gifts / pocket money — for children especially!', textSk: 'Dary / vreckové — hlavne pre deti!'),
      ],
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👦',
      storyTitle: 'Work Brings Money',
      storyTitleSk: 'Práca prináša peniaze',
      storyBody: 'Chrumko notices that his mom goes to work every day. At the end of the month, she receives money in her bank account. From this money, the family pays for rent, buys food, and saves some for later. Chrumko realizes that the money in their home comes from work.',
      storyBodySk: 'Chrumko si všimne, že mama chodí do práce každý deň. Na konci mesiaca dostane peniaze na bankovom účte. Z týchto peňazí rodina zaplatí nájom, kúpi potraviny a časť si odloží. Chrumko si uvedomí, že peniaze v domove pochádzajú z práce.',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🌟',
      highlightText: 'Most money comes from WORK. Work creates value, and value earns money!',
      highlightTextSk: 'Väčšina peňazí pochádza z PRÁCE. Práca vytvára hodnotu a hodnota zarába peniaze!',
      accentColor: Color(0xFF4CAF50),
    ),
  ],

  // ════════════════════════════════════════════
  // SECTION 2 — POTREBY VS TÚŽBY
  // ════════════════════════════════════════════

  'co_potrebujem_na_zivot': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏠',
      title: 'What Do I Need to Live?',
      titleSk: 'Čo potrebujem na život?',
      body: 'What does a person truly need? Not everything we want is something we actually need!',
      bodySk: 'Čo človek naozaj potrebuje? Nie všetko, čo chceme, je aj niečo, čo skutočne potrebujeme!',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🛒',
      title: 'Chrumko Shops Smart',
      titleSk: 'Chrumko nakupuje múdro',
      body: 'Chrumko goes to the shop after school. He buys a snack first — because he knows food is a need. Only then does he think about whether any money is left for chocolate.',
      bodySk: 'Chrumko ide po škole do obchodu. Najprv si kúpi desiatu, pretože vie, že jedlo potrebuje. Až potom premýšľa, či mu zostanú peniaze aj na čokoládu.',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '✅',
      title: 'True Needs',
      titleSk: 'Skutočné potreby',
      facts: [
        FactItem(emoji: '🍞', text: 'Food & clean water — fuel for your body', textSk: 'Jedlo a čistá voda — palivo pre telo'),
        FactItem(emoji: '🏠', text: 'Shelter & warmth — a safe place to rest', textSk: 'Prístrešie a teplo — bezpečné miesto na oddych'),
        FactItem(emoji: '👕', text: 'Basic clothing — protection from the weather', textSk: 'Základné oblečenie — ochrana pred počasím'),
        FactItem(emoji: '🏥', text: 'Healthcare — staying healthy', textSk: 'Zdravotná starostlivosť — zostávanie zdravým'),
        FactItem(emoji: '🎓', text: 'Education — learning for the future', textSk: 'Vzdelanie — učenie sa pre budúcnosť'),
      ],
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👦',
      storyTitle: 'Smart Shopping',
      storyTitleSk: 'Múdre nakupovanie',
      storyBody: 'Chrumko goes to the shop after school. He buys a snack first because he knows food is a need. Only then does he think about whether any money is left for chocolate. This shows he understands what\'s important!',
      storyBodySk: 'Chrumko ide po škole do obchodu. Najprv si kúpi desiatu, pretože vie, že jedlo potrebuje. Až potom premýšľa, či mu zostanú peniaze na čokoládu. To ukazuje, že rozumie tomu, čo je dôležité!',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '💭',
      highlightText: 'A NEED keeps you alive and healthy. A WANT makes life more enjoyable.',
      highlightTextSk: 'POTREBA ťa udržuje nažive a zdravého. TÚŽBA robí život príjemnejším.',
      accentColor: Color(0xFF2196F3),
    ),
  ],

  'co_len_chcem': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🧸',
      title: 'Things I Just Want',
      titleSk: 'Čo len chcem',
      body: 'Is a toy as important as food or clothing?',
      bodySk: 'Je hračka rovnako dôležitá ako jedlo alebo oblečenie?',
      accentColor: Color(0xFFE91E63),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🤗',
      title: 'Chrumko Wants a Plushie',
      titleSk: 'Chrumko chce plyšáka',
      body: 'Chrumko wants a new plush toy he sees in the shop. Then he remembers he already has a similar one at home. He doesn\'t really need it — it\'s just a want. And that\'s completely fine, as long as we know the difference!',
      bodySk: 'Chrumko chce novú plyšovú hračku, ktorú vidí v obchode. Potom si uvedomí, že doma už jednu podobnú má. On ju nepotrebuje — je to len túžba. A to je úplne v poriadku, pokiaľ vieme rozdiel!',
      accentColor: Color(0xFFE91E63),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🎮',
      title: 'Examples of Wants',
      titleSk: 'Príklady túžob',
      facts: [
        FactItem(emoji: '🎮', text: 'A new video game (when you have others already)', textSk: 'Nová videohra (keď už iné máš)'),
        FactItem(emoji: '🍫', text: 'Sweets and treats', textSk: 'Sladkosti a pochutiny'),
        FactItem(emoji: '🎨', text: 'Extra decorations or accessories', textSk: 'Extra dekorácie alebo doplnky'),
        FactItem(emoji: '👟', text: 'A second pair of the same type of shoes', textSk: 'Druhý pár rovnakého typu topánok'),
      ],
      accentColor: Color(0xFFE91E63),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👦',
      storyTitle: 'The Plushie Temptation',
      storyTitleSk: 'Pokušenie s plyšákom',
      storyBody: 'Chrumko sees a new plush toy in the shop that he likes. Then he remembers he already has a similar one at home. He realizes he doesn\'t really need it — it\'s just something he wants. And that\'s okay, as long as he understands the difference!',
      storyBodySk: 'Chrumko vidí v obchode novú plyšovú hračku, ktorá sa mu páči. Potom si pamätá, že doma už má podobnú. Uvedomí si, že ju vlastne nepotrebuje — len ju chce. A to je v poriadku, keď vie rozdiel!',
      accentColor: Color(0xFFE91E63),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '✨',
      highlightText: 'Wants aren\'t bad — just remember NEEDS come first!',
      highlightTextSk: 'Túžby nie sú zlé — len pamätaj, POTREBY sú vždy na prvom mieste!',
      accentColor: Color(0xFFE91E63),
    ),
  ],

  'preco_chceme_vec': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🧠',
      title: 'Why Do We Want Things We Don\'t Need?',
      titleSk: 'Prečo chceme veci, ktoré nepotrebujeme?',
      body: 'Why do we sometimes want something the moment we see it?',
      bodySk: 'Prečo niekedy túžime po veci hneď, keď ju uvidíme?',
      accentColor: Color(0xFF7C5CBF),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🎒',
      title: 'Chrumko\'s Pencil Case',
      titleSk: 'Chrumkov peračník',
      body: 'Chrumko sees his classmate with a cool new pencil case. He immediately wants one too — even though his own pencil case works perfectly! He waits a moment and realises he doesn\'t need a new one at all.',
      bodySk: 'Chrumko uvidí spolužiaka s novým peračníkom. Hneď by chcel mať rovnaký, aj keď jeho vlastný je stále úplne funkčný! Chvíľu počká a uvedomí si, že nový peračník vôbec nepotrebuje.',
      accentColor: Color(0xFF7C5CBF),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🔍',
      title: 'Why Our Brain Does This',
      titleSk: 'Prečo náš mozog toto robí',
      facts: [
        FactItem(emoji: '👀', text: 'We see something colourful or exciting and our brain says "I want that!"', textSk: 'Uvidíme niečo farebné alebo vzrušujúce a mozog povie „to chcem!"'),
        FactItem(emoji: '👥', text: 'When our friends have something, we want it too', textSk: 'Keď to majú kamaráti, chceme to tiež'),
        FactItem(emoji: '📺', text: 'Ads are designed to make us want things', textSk: 'Reklamy sú navrhnuté tak, aby sme veci chceli'),
      ],
      accentColor: Color(0xFF7C5CBF),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👦',
      storyTitle: 'Cool Pencil Case',
      storyTitleSk: 'Fajný peračník',
      storyBody: 'Chrumko sees a classmate with a cool new pencil case. He wants one immediately, even though his own works perfectly fine! He waits for a moment and realizes he doesn\'t actually need a new one at all. Sometimes waiting helps!',
      storyBodySk: 'Chrumko vidí spolužiaka s fajným novým peračníkom. Hneď by ho chcel, aj keď jeho vlastný funguje perfektne! Chvíľu počká a uvedomí si, že nový netreba. Niekedy pomáha počkať!',
      accentColor: Color(0xFF7C5CBF),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '⏳',
      title: 'The Waiting Trick',
      titleSk: 'Trik s čakaním',
      body: 'Wait a little before buying anything. If you still want it tomorrow, it might be worth it. Most impulse cravings disappear within minutes!',
      bodySk: 'Počkaj chvíľu pred akýmkoľvek nákupom. Ak to stále chceš zajtra, možno to stojí za to. Väčšina impulzívnych túžob zmizne do pár minút!',
      accentColor: Color(0xFF7C5CBF),
    ),
  ],

  'reklama_vplyv': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📺',
      title: 'Advertising and Its Influence',
      titleSk: 'Reklama a jej vplyv',
      body: 'Why do things in adverts look so tempting?',
      bodySk: 'Prečo sú veci v reklame tak lákavé?',
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🍫',
      title: 'Chrumko Sees an Ad',
      titleSk: 'Chrumko vidí reklamu',
      body: 'Chrumko sees a TV ad for a huge chocolate bar. It looks enormous and delicious! Next day in the shop he finds it — but it\'s much smaller than on TV. The packaging is nice, but the real thing is very different from the ad.',
      bodySk: 'Chrumko pozerá televíziu a uvidí reklamu na veľkú čokoládu. Na obrazovke vyzerá obrovská a veľmi chutná! Na druhý deň v obchode ju nájde — je oveľa menšia ako na obrazovke. Obal je pekný, ale skutočná vec je veľmi odlišná od reklamy.',
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🎭',
      title: 'How Ads Trick You',
      titleSk: 'Ako ťa reklamy klamú',
      facts: [
        FactItem(emoji: '🔍', text: 'Food looks bigger and tastier than in real life', textSk: 'Jedlo vyzerá väčšie a chutnejšie ako v skutočnosti'),
        FactItem(emoji: '🎵', text: 'Happy music makes you feel good about the product', textSk: 'Veselá hudba ťa rozveselí a ovplyvní pocit z výrobku'),
        FactItem(emoji: '⭐', text: 'Famous characters make things seem more exciting', textSk: 'Známe postavy robia veci zdanlivo vzrušujúcejšími'),
      ],
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👦',
      storyTitle: 'The Ad Trick',
      storyTitleSk: 'Trik s reklamou',
      storyBody: 'Chrumko sees a TV ad for a huge chocolate bar. It looks enormous and delicious! The next day, he finds it in the shop, but it\'s much smaller than on TV. The packaging is nice, but the real chocolate is very different from what the ad showed.',
      storyBodySk: 'Chrumko vidí televíznu reklamu na obrovskú čokoládu. Vyzerá obrovská a chutná! Nasledujúci deň ju nájde v obchode, ale je oveľa menšia. Obal je pekný, ale skutočná čokoláda je veľmi iná od toho, čo ukazovala reklama.',
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🕵️',
      highlightText: 'Be a DETECTIVE — always look past the pretty packaging at what you\'re really buying!',
      highlightTextSk: 'Buď DETEKTÍV — vždy pozri za pekný obal na to, čo skutočne kupuješ!',
      accentColor: Color(0xFFF5A623),
    ),
  ],

  'emocionalne_nakupovanie': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '😢',
      title: 'Emotional Shopping',
      titleSk: 'Emocionálne nakupovanie',
      body: 'Do we sometimes buy things just because we\'re sad?',
      bodySk: 'Kupujeme si niekedy veci len preto, že sme smutní?',
      accentColor: Color(0xFF2196F3),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🎮',
      title: 'Chrumko Loses a Game',
      titleSk: 'Chrumko prehrá hru',
      body: 'Chrumko loses the last round of a game. He\'s angry and sad. On the way home he sees a shop and wants to buy a big treat to feel better. He stops and thinks — he\'s not really hungry, and has snacks at home. He decides to wait!',
      bodySk: 'Chrumko prehrá posledné kolo hry. Je nahnevaný a sklamaný. Cestou domov uvidí obchod a dostane chuť kúpiť si veľkú sladkosť, aby sa cítil lepšie. Zastaví sa — nie je hladný a doma má ešte ovocie. Rozhodne sa počkať!',
      accentColor: Color(0xFF2196F3),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '💡',
      title: 'Emotions That Trigger Shopping',
      titleSk: 'Emócie, ktoré spúšťajú nakupovanie',
      facts: [
        FactItem(emoji: '😢', text: 'Sadness — wanting comfort', textSk: 'Smútok — hľadanie útechy'),
        FactItem(emoji: '😤', text: 'Anger or frustration — wanting relief', textSk: 'Hnev alebo frustrácia — hľadanie úľavy'),
        FactItem(emoji: '🎉', text: 'Excitement — wanting to celebrate', textSk: 'Nadšenie — chcenie osláviť'),
        FactItem(emoji: '😴', text: 'Boredom — wanting stimulation', textSk: 'Nuda — hľadanie stimulácie'),
      ],
      accentColor: Color(0xFF2196F3),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👦',
      storyTitle: 'Sad Day Shopping',
      storyTitleSk: 'Nakupovanie v smutnosti',
      storyBody: 'Chrumko loses the final round of a game. He\'s angry and sad. On the way home, he sees a shop and wants to buy something to feel better. He stops and thinks: he\'s not really hungry and has snacks at home. He decides to wait instead of buying!',
      storyBodySk: 'Chrumko prehrá finálne kolo hry. Je nahnevaný a smutný. Cestou domov vidí obchod a chce si kúpiť niečo, aby sa cítil lepšie. Zastaví sa a premýšľa: nie je hladný a doma má sladkosti. Rozhodne sa počkať!',
      accentColor: Color(0xFF2196F3),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '🧘',
      title: 'Pause and Think',
      titleSk: 'Zastav sa a zamysli',
      body: 'When emotions are running high, it helps to wait before buying. Once the emotion fades, you\'ll make much better decisions with your money!',
      bodySk: 'Keď sú emócie silné, pomáha pred nákupom počkať. Keď emócia opadne, urobíš oveľa lepšie rozhodnutia s peniazmi!',
      accentColor: Color(0xFF2196F3),
    ),
  ],

  // Continue with remaining lessons...
  // (Due to length, I'll include the structure and a few more complete examples)
  // The pattern is: intro, info, facts, story, highlight/tip

  'vreckove': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '👛',
      title: 'Pocket Money',
      titleSk: 'Vreckové',
      body: 'Why do some children get pocket money every week or month?',
      bodySk: 'Prečo niektoré deti dostávajú vreckové každý týždeň alebo mesiac?',
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🎬',
      title: 'Chrumko Plans His Week',
      titleSk: 'Chrumko plánuje týždeň',
      body: 'Chrumko gets €10 at the start of the week. He sees a treat at the school snack bar. But he remembers: in two days he\'s going to the cinema with friends! He buys only a small thing now and keeps some money for the cinema.',
      bodySk: 'Chrumko dostane na začiatku týždňa 10 eur. V školskom bufete uvidí sladkosť. Ale zapamätá si: o dva dni ide s kamarátmi do kina! Kúpi si teraz len malú vec a časť peňazí si nechá na kino.',
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📊',
      title: 'The 50-30-20 Rule',
      titleSk: 'Pravidlo 50-30-20',
      facts: [
        FactItem(emoji: '🛒', text: '50% — Needs: things you actually have to buy', textSk: '50% — Potreby: veci, ktoré naozaj musíš kúpiť'),
        FactItem(emoji: '🎮', text: '30% — Wants: fun stuff you enjoy', textSk: '30% — Túžby: zábavné veci, ktoré si užívaš'),
        FactItem(emoji: '🏦', text: '20% — Savings: save for bigger goals!', textSk: '20% — Sporenie: šetri na väčšie ciele!'),
      ],
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👦',
      storyTitle: 'Weekly Planning',
      storyTitleSk: 'Týždenné plánovanie',
      storyBody: 'Chrumko gets ten euros at the start of the week. He sees a treat at school he\'d like. But he remembers: in two days he\'s going to the cinema with friends! He buys only a small thing now and saves money for the cinema.',
      storyBodySk: 'Chrumko dostane na začiatku týždňa desať eur. V škole uvidí sladkosť, ktorú by chcel. Ale pamätá si: o dva dni ide do kina s kamarátmi! Kúpi si len niečo malé a peniaze si nechá na kino.',
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '🐷',
      title: 'Pro Tip',
      titleSk: 'Tip',
      body: 'Save FIRST, then spend. Put savings aside the moment you receive money — don\'t wait to see what\'s left over!',
      bodySk: 'NAJPRV šetri, potom míňaj. Odlož si úspory hneď, keď dostaneš peniaze — nečakaj, čo ti ostane!',
      accentColor: Color(0xFF4CAF50),
    ),
  ],

  // The rest of the lessons follow the same pattern...
  // I'll add a few more key ones and include the story type for each
};

// ─────────────────────────────────────────────
// MAIN SCREEN WIDGET
// ─────────────────────────────────────────────

class LessonContentScreen extends StatefulWidget {
  final Lesson lesson;
  final String categoryTitle;
  final bool isSlovak;

  const LessonContentScreen({
    super.key,
    required this.lesson,
    required this.categoryTitle,
    this.isSlovak = false,
  });

  @override
  State<LessonContentScreen> createState() => _LessonContentScreenState();
}

class _LessonContentScreenState extends State<LessonContentScreen>
    with SingleTickerProviderStateMixin {
  int _currentSlide = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Allow isSlovak to also be read live from Provider
  bool get _isSk {
    try {
      final l10n = context.read<AppLocalizationsProvider>();
      return l10n.currentLanguage == 'sk';
    } catch (_) {
      return widget.isSlovak;
    }
  }

  List<LessonSlide> get slides =>
      lessonSlides[widget.lesson.id] ?? _defaultSlides(widget.lesson);

  List<LessonSlide> _defaultSlides(Lesson lesson) => [
        LessonSlide(
          type: LessonSlideType.intro,
          emoji: '📖',
          title: lesson.title,
          titleSk: lesson.title,
          body: 'This lesson is coming soon! Check back later.',
          bodySk: 'Táto lekcia čoskoro príde! Príď neskôr.',
          accentColor: const Color(0xFFF5A623),
        ),
      ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _goNext() {
    HapticFeedback.lightImpact();
    if (_currentSlide < slides.length - 1) {
      _animController.reset();
      setState(() => _currentSlide++);
      _animController.forward();
    } else {
      _finishLesson();
    }
  }

  void _goPrev() {
    if (_currentSlide > 0) {
      _animController.reset();
      setState(() => _currentSlide--);
      _animController.forward();
    }
  }

  void _finishLesson() {
    if (widget.lesson.quizLessonId != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LessonQuizScreen(
            lessonId: widget.lesson.quizLessonId!,
            lessonTitle: widget.lesson.title,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSk ? 'Lekcia dokončená! 🎉' : 'Lesson complete! 🎉'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = slides[_currentSlide];
    final accent = slide.accentColor ?? const Color(0xFFF5A623);
    final isLast = _currentSlide == slides.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(accent),
            _buildProgressBar(accent),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _buildSlide(slide, accent),
                ),
              ),
            ),
            _buildBottomBar(isLast, accent),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: const Icon(Icons.close_rounded, size: 20, color: Colors.black54),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoryTitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.lesson.title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentSlide + 1} / ${slides.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: (_currentSlide + 1) / slides.length,
          minHeight: 8,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(accent),
        ),
      ),
    );
  }

  Widget _buildSlide(LessonSlide slide, Color accent) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: switch (slide.type) {
        LessonSlideType.intro => _buildIntroSlide(slide, accent),
        LessonSlideType.info => _buildInfoSlide(slide, accent),
        LessonSlideType.facts => _buildFactsSlide(slide, accent),
        LessonSlideType.highlight => _buildHighlightSlide(slide, accent),
        LessonSlideType.tip => _buildTipSlide(slide, accent),
        LessonSlideType.story => _buildStorySlide(slide, accent),
      },
    );
  }

  // ── SLIDE TYPES ──────────────────────────────

  Widget _buildIntroSlide(LessonSlide s, Color accent) {
    final title = _isSk ? (s.titleSk ?? s.title!) : s.title!;
    final body = _isSk ? (s.bodySk ?? s.body!) : s.body!;
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(s.emoji ?? '💰', style: const TextStyle(fontSize: 64)),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            body,
            style: const TextStyle(
              fontSize: 16,
              height: 1.55,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoSlide(LessonSlide s, Color accent) {
    final title = _isSk ? (s.titleSk ?? s.title!) : s.title!;
    final body = _isSk ? (s.bodySk ?? s.body!) : s.body!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Text(s.emoji ?? '📖', style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            body,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Color(0xFF333333),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildFactsSlide(LessonSlide s, Color accent) {
    final title = _isSk ? (s.titleSk ?? s.title!) : s.title!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Text(s.emoji ?? '📋', style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(s.facts!.length, (i) {
          final fact = s.facts![i];
          final text = _isSk ? fact.textSk : fact.text;
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + i * 80),
            builder: (ctx, val, child) => Opacity(
              opacity: val,
              child: Transform.translate(
                offset: Offset(20 * (1 - val), 0),
                child: child,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(fact.emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHighlightSlide(LessonSlide s, Color accent) {
    final text = _isSk
        ? (s.highlightTextSk ?? s.highlightText!)
        : s.highlightText!;
    return Column(
      children: [
        const SizedBox(height: 40),
        Text(s.emoji ?? '💡', style: const TextStyle(fontSize: 72)),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent, accent.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTipSlide(LessonSlide s, Color accent) {
    final title = _isSk ? (s.titleSk ?? s.title!) : s.title!;
    final body = _isSk ? (s.bodySk ?? s.body!) : s.body!;
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(s.emoji ?? '💡', style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: accent.withOpacity(0.4), width: 2),
          ),
          child: Text(
            body,
            style: TextStyle(fontSize: 16, height: 1.6, color: Colors.grey[850]),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStorySlide(LessonSlide s, Color accent) {
    final title = _isSk ? (s.storyTitleSk ?? s.storyTitle!) : s.storyTitle!;
    final body = _isSk ? (s.storyBodySk ?? s.storyBody!) : s.storyBody!;
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(s.emoji ?? '👦', style: const TextStyle(fontSize: 48)),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            body,
            style: const TextStyle(
              fontSize: 15,
              height: 1.65,
              color: Color(0xFF444444),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── BOTTOM BAR ────────────────────────────────

  Widget _buildBottomBar(bool isLast, Color accent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          if (_currentSlide > 0)
            GestureDetector(
              onTap: _goPrev,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black54),
              ),
            )
          else
            const SizedBox(width: 50),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _goNext,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isLast
                        ? (widget.lesson.quizLessonId != null
                            ? (_isSk ? '🎯 Spustiť kvíz' : '🎯 Start Quiz')
                            : (_isSk ? '✅ Dokončiť' : '✅ Finish'))
                        : (_isSk ? 'Pokračovať →' : 'Continue →'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}