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

  /// Optional custom icon widget (e.g. MyFlutterApp.coins, MyFlutterApp.chrumka).
  /// Used by [LessonSlideType.icon] and also replaces the emoji circle on
  /// [LessonSlideType.intro] / [LessonSlideType.story] when provided.
  final Widget? iconWidget;

  /// Optional icon size override. Controls the rendered image size inside the
  /// container. When set, this value replaces the default iconSize passed by
  /// the slide-type builder to [_buildAvatarWidget].
  final double? iconSize;

  /// Optional container size override. Controls the outer bounding box that
  /// wraps the icon. Must be >= [iconSize] or the icon will be clipped.
  /// When omitted the slide-type builder's own default is used.
  ///
  /// Set both together to make the icon visually larger:
  /// ```dart
  /// LessonSlide(
  ///   type: LessonSlideType.story,
  ///   iconWidget: MyFlutterApp.chrumka,
  ///   iconSize: 160,
  ///   iconContainerSize: 180,
  ///   ...
  /// )
  /// ```
  final double? iconContainerSize;

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
    this.iconWidget,
    this.iconSize,
    this.iconContainerSize,
  });

  /// Convenience factory — creates a [LessonSlideType.icon] slide in one line.
  ///
  /// Example:
  /// ```dart
  /// LessonSlide.icon(
  ///   iconWidget: MyFlutterApp.coins,
  ///   title: 'Coins & Cash',
  ///   titleSk: 'Mince a hotovosť',
  ///   body: 'Coins are the oldest form of money still in use today.',
  ///   bodySk: 'Mince sú najstaršia forma peňazí, ktorá sa stále používa.',
  ///   accentColor: Color(0xFFF5A623),
  ///   iconSize: 110,
  /// )
  /// ```
  factory LessonSlide.icon({
    required Widget iconWidget,
    String? title,
    String? titleSk,
    String? body,
    String? bodySk,
    String? emoji,
    Color? accentColor,
    double? iconSize,
    double? iconContainerSize,
  }) {
    return LessonSlide(
      type: LessonSlideType.icon,
      iconWidget: iconWidget,
      emoji: emoji,
      title: title,
      titleSk: titleSk,
      body: body,
      bodySk: bodySk,
      accentColor: accentColor,
      iconSize: iconSize,
      iconContainerSize: iconContainerSize,
    );
  }
}

class FactItem {
  final String emoji;
  final String text;
  final String textSk;

  /// Optional per-item icon widget — overrides [emoji] when provided.
  final Widget? iconWidget;

  const FactItem({
    required this.emoji,
    required this.text,
    required this.textSk,
    this.iconWidget,
  });
}

enum LessonSlideType { intro, info, facts, highlight, tip, story, icon }

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
    // ── EXAMPLE: icon slide using MyFlutterApp.coins ──
    LessonSlide.icon(
      iconWidget: MyFlutterApp.payment,
      iconSize: 300,
      iconContainerSize: 320,
      title: '3 Forms of Money',
      titleSk: '3 formy peňazí',
      body: 'Coins, banknotes, and digital money are the three main forms used today.',
      bodySk: 'Mince, bankovky a digitálne peniaze sú tri hlavné formy, ktoré sa dnes používajú.',
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📋',
      title: '3 Forms of Money',
      titleSk: '3 formy peňazí',
      facts: [
        FactItem(
          emoji: '🪙',
          text: 'Coins — small metal discs for everyday purchases',
          textSk: 'Mince — malé kovové disky na každodenné nákupy',
        ),
        FactItem(
          emoji: '💵',
          text: 'Banknotes — paper money for larger amounts',
          textSk: 'Bankovky — papierové peniaze pre väčšie sumy',
        ),
        FactItem(
          emoji: '💳',
          text: 'Digital money — pay by card or phone instantly',
          textSk: 'Digitálne peniaze — platiť kartou alebo telefónom okamžite',
        ),
      ],
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👦',
      // Use Chrumka asset on the story slide
      iconWidget: MyFlutterApp.chrumko_coin,
      iconSize: 300,
      iconContainerSize: 320,
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
      iconWidget: MyFlutterApp.cereal,
      iconSize: 300,
      iconContainerSize: 320,
      storyTitle: 'Snack swap',
      storyTitleSk: 'Výmena snacku',
      storyBody: 'Chrumko has an apple for his snack, but he\'d rather have a cereal bar. He asks his friend, who has a cereal bar, if they can swap snacks, but she doesn\'t want the apple because she already has one. If he had money, he could buy the cereal bar right away without having to look for someone who wants an apple.',
      storyBodySk: 'Chrumko má na desiatu jablko ale radšej by si dal cereálnu tyčinku. Poprosí kamarátku, ktorá má cereálnu tyčinku, aby si desiatu vymenili, ale ona jablko nechce, lebo už jedno má. Keby mal peniaze, mohol by si cereálnu tyčinku kúpiť hneď bez hľadania niekoho, kto chce práve jablko.',
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
      type: LessonSlideType.story,
      iconWidget: MyFlutterApp.barter,
      iconSize: 500,
      iconContainerSize: 520,
      storyTitle: 'Chrumko Needs Bread',
      storyTitleSk: 'Chrumko potrebuje chlieb',
      storyBody: 'Imagine coins didn\'t exist and Chrumko wanted bread. The baker would ask for two eggs. If Chrumko had no eggs, he\'d first have to find some. That\'s why paying used to be so much more complicated!',
      storyBodySk: 'Predstav si, že mince by neexistovali a Chrumko by chcel chlieb. Pekár by si vypýtal dve vajcia. Ak by Chrumko vajcia nemal, najprv by ich musel zohnať. Aj preto bolo platenie kedysi oveľa zložitejšie!',
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
        FactItem(
          emoji: '🪙',
          text: '600 BC: First metal coins in Lydia (Turkey)',
          textSk: '600 pr. n. l.: Prvé kovové mince v Lydii (Turecko)',
        ),
        FactItem(emoji: '📜', text: '700 AD: First paper money in China', textSk: '700 n. l.: Prvé papierové peniaze v Číne'),
      ],
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
      type: LessonSlideType.story,
      iconWidget: MyFlutterApp.tie,
      iconSize: 300,
      iconContainerSize: 320,
      storyTitle: 'Chrumko Buys a Tie',
      storyTitleSk: 'Chrumko si kupuje kravatu',
      storyBody: 'Chrumko wants to buy a new tie. The shop assistant asks: card or cash? Banknotes and coins = cash. Card payment = digital money sent from his account. Both options mean paying money — just different ways!',
      storyBodySk: 'Chrumko si chce kúpiť novú kravatu. Predavačka sa ho opýta: kartou alebo v hotovosti? Bankovky a mince = hotovosť. Platba kartou = digitálne peniaze poslané z účtu. Obe možnosti znamenajú platbu peniazmi — len iným spôsobom!',
      accentColor: Color(0xFF009688),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🔍',
      title: 'Types of Money Today',
      titleSk: 'Typy peňazí dnes',
      facts: [
        FactItem(
          emoji: '🪙',
          text: 'Coins — metal, great for small purchases',
          textSk: 'Mince — kovové, ideálne na malé nákupy',
        ),
        FactItem(
          emoji: '💵',
          text: 'Banknotes — paper, convenient to carry',
          textSk: 'Bankovky — papierové, pohodlné na nosenie',
        ),
        FactItem(emoji: '📱', text: 'Digital — stored in your bank account, pay by card or phone', 
        textSk: 'Digitálne — uložené v bankovom účte, platiť kartou alebo telefónom'),
      ],
      accentColor: Color(0xFF009688),
    ),
    // ── EXAMPLE: standalone icon slide with MyFlutterApp.robot ──
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🏦',
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
        FactItem(
          emoji: '🪙',
          text: 'A coin with "50" = 50 cents (less than €1)',
          textSk: 'Minca s číslom „50" = 50 centov (menej ako 1 €)',
        ),
        FactItem(
          emoji: '💵',
          text: 'A note with "50" = €50 (much more!)',
          textSk: 'Bankovka s číslom „50" = 50 € (oveľa viac!)',
        ),
        FactItem(emoji: '🧮', text: 'Knowing values helps you know what you can buy', textSk: 'Poznanie hodnôt ti pomôže vedieť, čo si môžeš kúpiť'),
      ],
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👦',
      iconWidget: MyFlutterApp.juice,
      iconSize: 300,
      iconContainerSize: 320,
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
      type: LessonSlideType.story,
      emoji: '🍬',
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
        FactItem(
          emoji: '👔',
          text: 'Salary — regular pay from an employer',
          textSk: 'Plat — pravidelná odmena od zamestnávateľa',
        ),
        FactItem(
          emoji: '🏪',
          text: 'Business — selling goods or services',
          textSk: 'Podnikanie — predaj tovarov alebo služieb',
          iconWidget: MyFlutterApp.shop,
        ),
        FactItem(emoji: '🎁', text: 'Gifts / pocket money — for children especially!', textSk: 'Dary / vreckové — hlavne pre deti!'),
      ],
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👦',
      iconWidget: MyFlutterApp.idea,
      iconSize: 300,
      iconContainerSize: 320,
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
      emoji: '🤔',
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
      iconWidget: MyFlutterApp.look,
      iconSize: 300,
      iconContainerSize: 320,
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
      emoji: '🖍️',
      storyTitle: 'Cool Pencil Case',
      storyTitleSk: 'Pekný peračník',
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
      emoji: '🙁',
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
        FactItem(emoji: '🙁', text: 'Sadness — wanting comfort', textSk: 'Smútok — hľadanie útechy'),
        FactItem(emoji: '😤', text: 'Anger or frustration — wanting relief', textSk: 'Hnev alebo frustrácia — hľadanie úľavy'),
        FactItem(emoji: '🎉', text: 'Excitement — wanting to celebrate', textSk: 'Nadšenie — chcenie osláviť'),
        FactItem(emoji: '🥱', text: 'Boredom — wanting stimulation', textSk: 'Nuda — hľadanie stimulácie'),
      ],
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

  // ════════════════════════════════════════════
  // SECTION 3 — PRVE HOSPODAENIE S PENIAZMI
  // ════════════════════════════════════════════

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
        FactItem(
          emoji: '🛒',
          text: '50% — Needs: things you actually have to buy',
          textSk: '50% — Potreby: veci, ktoré naozaj musíš kúpiť',
        ),
        FactItem(emoji: '🎮', text: '30% — Wants: fun stuff you enjoy', textSk: '30% — Túžby: zábavné veci, ktoré si užívaš'),
        FactItem(
          emoji: '🎯',
          text: '20% — Savings: save for bigger goals!',
          textSk: '20% — Sporenie: šetri na väčšie ciele!',
        ),
      ],
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

  'ako_si_rozdelit_peniaze': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '💸',
      title: 'How to Split Your Money',
      titleSk: 'Ako si rozdeliť peniaze',
      body: 'Is it a good idea to spend everything at once?',
      bodySk: 'Je dobré minúť všetko naraz?',
      accentColor: Color(0xFF5C6BC0),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      iconWidget: MyFlutterApp.saving,
      iconSize: 300,
      iconContainerSize: 320,
      storyTitle: 'Chrumko Splits His Money',
      storyTitleSk: 'Chrumko si rozdelí peniaze',
      storyBody: 'Chrumko gets €10 from his parents. He wants to buy a big toy right away, but realises he\'d have nothing left. He puts €7 in his piggy bank for saving and buys a small item he needs for school with the rest.',
      storyBodySk: 'Chrumko dostane od rodičov 10 eur. Hneď by chcel kúpiť väčšiu hračku, ale uvedomí si, že potom mu nič nezostane. Rozhodne sa odložiť si 7 eur do pokladničky. Za zvyšné peniaze si kúpi menšiu vec, ktorú potrebuje do školy.',
      accentColor: Color(0xFF5C6BC0),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📐',
      title: 'Why Split?',
      titleSk: 'Prečo deliť?',
      facts: [
        FactItem(
          emoji: '🛒',
          text: 'One part for what you need right now',
          textSk: 'Jedna časť na to, čo teraz potrebuješ',
        ),
        FactItem(
          emoji: '🐷',
          text: 'One part saved for later goals',
          textSk: 'Jedna časť odložená na neskoršie ciele',
        ),
        FactItem(
          emoji: '🎉',
          text: 'Splitting teaches you to plan and decide calmly',
          textSk: 'Delenie ťa učí plánovať a rozhodovať pokojne',
        ),
      ],
      accentColor: Color(0xFF5C6BC0),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '🍕',
      storyTitle: 'Pizza With Friends',
      storyTitleSk: 'Pizza s kamarátmi',
      storyBody: 'A few days later Chrumko is glad he kept part of his money. His friends invite him for pizza and he has exactly enough. He smiles knowing he planned ahead!',
      storyBodySk: 'O pár dní je Chrumko rád, že si časť peňazí nechal. Kamaráti ho pozývajú na pizzu a on má presne dosť. S úsmevom vie, že dobre naplánoval!',
      accentColor: Color(0xFF5C6BC0),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🧾',
      highlightText: 'Split your money FIRST — then decide what to spend and what to save!',
      highlightTextSk: 'NAJPRV si rozdeľ peniaze — potom rozhoduj, čo minúť a čo ušetriť!',
      accentColor: Color(0xFF5C6BC0),
    ),
  ],

  'minut_teraz_vs_neskor': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '⏳',
      title: 'Spend Now or Later?',
      titleSk: 'Minúť teraz alebo neskôr?',
      body: 'What is better — a small treat today or something bigger in a few days?',
      bodySk: 'Čo je lepšie — malá vec dnes alebo väčšia vec o pár dní?',
      accentColor: Color(0xFF00897B),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🍭',
      title: 'Chrumko and the Lollipop',
      titleSk: 'Chrumko a lízanka',
      body: 'Chrumko has €2 and sees his favourite lollipop. He really wants it — but then remembers the colouring book he loved last week. It costs more than he has today. He decides to wait, save up, and buy the book instead.',
      bodySk: 'Chrumko má 2 eurá a uvidí svoju obľúbenú lízanku. Veľmi by si ju chcel — ale potom si spomenie na omaľovánku, ktorú miloval minulý týždeň. Tá stojí viac. Rozhodne sa počkať, nasporiť a kúpiť radšej knihu.',
      accentColor: Color(0xFF00897B),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🔄',
      title: 'Now vs Later',
      titleSk: 'Teraz vs neskôr',
      facts: [
        FactItem(
          emoji: '💳',
          text: 'Spending now: instant joy, but the money is gone',
          textSk: 'Minúť teraz: okamžitá radosť, ale peniaze sú preč',
        ),
        FactItem(
          emoji: '🕰️',
          text: 'Waiting: needs patience, but you can get something bigger',
          textSk: 'Čakanie: vyžaduje trpezlivosť, ale dostaneš niečo väčšie',
        ),
        FactItem(
          emoji: '📖',
          text: 'A colouring book brings joy for weeks; a lollipop lasts minutes',
          textSk: 'Omaľovánka teší týždne; lízanka zmizne za pár minút',
        ),
      ],
      accentColor: Color(0xFF00897B),
    ),
    LessonSlide.icon(
      iconWidget: MyFlutterApp.idea,
      iconSize: 300,
      iconContainerSize: 320,
      title: 'The Patience Trick',
      titleSk: 'Trik trpezlivosti',
      body: 'Before spending, ask: will I enjoy this tomorrow too? Sometimes waiting leads to a much better reward!',
      bodySk: 'Pred míňaním sa opýtaj: budem sa z toho tešiť aj zajtra? Niekedy čakanie prinesie oveľa lepšiu odmenu!',
      accentColor: Color(0xFF00897B),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🏆',
      highlightText: 'Patience pays off — saving up for something bigger feels amazing!',
      highlightTextSk: 'Trpezlivosť sa vypláca — nasporiť si na niečo väčšie je skvelý pocit!',
      accentColor: Color(0xFF00897B),
    ),
  ],

  'preco_sa_oplati_planovat': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📅',
      title: 'Why Planning Pays Off',
      titleSk: 'Prečo sa oplatí plánovať',
      body: 'Why is it helpful to know in advance what you\'ll use your money for?',
      bodySk: 'Prečo je dobré vedieť dopredu, na čo peniaze použijem?',
      accentColor: Color(0xFF8D6E63),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '🕶️',
      storyTitle: 'Chrumko\'s Sunglasses Plan',
      storyTitleSk: 'Chrumkov plán na okuliare',
      storyBody: 'Chrumko knows he wants ice cream on Saturday and has been eyeing new sunglasses. On Wednesday he gets pocket money and spots a new toy in a shop window. He remembers his plans and walks past the shop. On Saturday he has enough for ice cream — and keeps saving for the sunglasses.',
      storyBodySk: 'Chrumko vie, že v sobotu chce zmrzlinu s kamarátmi a dlho si chce kúpiť slnečné okuliare. V stredu dostane vreckové a uvidí novú hračku vo výklade. Spomenie si na plány a prejde okolo. V sobotu má dosť na zmrzlinu — a na okuliare stále šetrí.',
      accentColor: Color(0xFF8D6E63),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🗺️',
      title: 'Benefits of Planning',
      titleSk: 'Výhody plánovania',
      facts: [
        FactItem(emoji: '🎯', text: 'You know exactly what you\'re saving for', textSk: 'Vieš presne, na čo šetríš'),
        FactItem(emoji: '🚫', text: 'Easier to skip impulse buys when you have a goal', textSk: 'Jednoduchšie odolať impulzívnym nákupom, keď máš cieľ'),
        FactItem(emoji: '✅', text: 'The feeling of reaching your goal is fantastic', textSk: 'Pocit, keď dosiahneš cieľ, je fantastický'),
      ],
      accentColor: Color(0xFF8D6E63),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '📝',
      title: 'Write It Down',
      titleSk: 'Zapíš si to',
      body: 'Write your saving goal on a piece of paper or in a notebook. Seeing your goal every day keeps you motivated!',
      bodySk: 'Zapíš si cieľ sporenia na papier alebo do zošita. Každodenné videnie cieľa ťa motivuje!',
      accentColor: Color(0xFF8D6E63),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🎯',
      highlightText: 'A plan turns your money into a tool for reaching YOUR goals!',
      highlightTextSk: 'Plán mení tvoje peniaze na nástroj na dosiahnutie TVOJICH cieľov!',
      accentColor: Color(0xFF8D6E63),
    ),
  ],

  'male_financne_chyby': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🤦',
      title: 'Small Money Mistakes',
      titleSk: 'Malé finančné chyby',
      body: 'Can a mistake actually be a good experience?',
      bodySk: 'Môže byť chyba aj dobrou skúsenosťou?',
      accentColor: Color(0xFFE53935),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '🔦',
      storyTitle: 'The Flashing Toy',
      storyTitleSk: 'Blikajúca hračka',
      storyBody: 'Chrumko buys a small flashing toy in the shop because it looks amazing. He plays with it for a while at home, then puts it away and never comes back to it. A few days later he wishes he had bought something he would use longer. Next time he\'ll take more time to decide.',
      storyBodySk: 'Chrumko si v obchode kúpi malú blikajúcu hračku, pretože sa mu zdá veľmi zaujímavá. Doma sa s ňou chvíľu hrá, ale po krátkom čase ju odloží a nevráti sa k nej. O pár dní si uvedomí, že by si radšej kúpil niečo, čo by využil dlhšie. Nabudúce si dá viac času na rozhodovanie.',
      accentColor: Color(0xFFE53935),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📚',
      title: 'Learning From Mistakes',
      titleSk: 'Učenie sa z chýb',
      facts: [
        FactItem(emoji: '🙋', text: 'Everyone spends money on something they regret sometimes', textSk: 'Každý niekedy minie peniaze na niečo, čo ho neskôr mrzí'),
        FactItem(emoji: '🔍', text: 'Ask yourself: why did I choose that? What would I do differently?', textSk: 'Opýtaj sa: prečo som sa tak rozhodol? Čo by som urobil inak?'),
        FactItem(emoji: '🌱', text: 'Each small mistake helps you make better choices in the future', textSk: 'Každá malá chyba ti pomáha robiť lepšie rozhodnutia v budúcnosti'),
      ],
      accentColor: Color(0xFFE53935),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '💪',
      title: 'Mistakes Are OK',
      titleSk: 'Chyby sú v poriadku',
      body: 'Don\'t be too hard on yourself. Every mistake with money is a lesson. The important thing is to think about it and improve next time!',
      bodySk: 'Nebuď na seba príliš prísny. Každá chyba s peniazmi je lekcia. Dôležité je zamyslieť sa a nabudúce sa zlepšiť!',
      accentColor: Color(0xFFE53935),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🌟',
      highlightText: 'A mistake is only wasted if you don\'t LEARN from it!',
      highlightTextSk: 'Chyba je zbytočná iba vtedy, keď sa z nej NIČ nenaučíš!',
      accentColor: Color(0xFFE53935),
    ),
  ],

// ════════════════════════════════════════════
// SECTION 4 — SPORENIE
// ════════════════════════════════════════════

  'co_je_sporenie': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🐷',
      title: 'What is Saving?',
      titleSk: 'Čo je sporenie?',
      body: 'What can we do with money other than spend it right away?',
      bodySk: 'Čo lepšie môžeme spraviť s peniazmi ako ich hneď minúť?',
      accentColor: Color(0xFF43A047),
    ),
    LessonSlide.icon(
      iconWidget: MyFlutterApp.saving,
      iconSize: 300,
      iconContainerSize: 320,
      title: 'Chrumko\'s Piggy Bank',
      titleSk: 'Chrumkova pokladnička',
      body: 'Chrumko gets small coins every week. He decides to put one coin into his piggy bank each time. At first it seems slow. After a few weeks his piggy bank is heavier — and he can now afford something more expensive!',
      bodySk: 'Chrumko dostáva každý týždeň drobné mince. Rozhodne sa, že jednu mincu vždy vloží do pokladničky. Najprv sa zdá, že suma rastie pomaly. Po niekoľkých týždňoch je pokladnička ťažšia — a Chrumko si môže kúpiť niečo drahšie!',
      accentColor: Color(0xFF43A047),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '💡',
      title: 'Key Facts About Saving',
      titleSk: 'Kľúčové fakty o sporení',
      facts: [
        FactItem(emoji: '🗓️', text: 'Saving means setting money aside instead of spending it right away', textSk: 'Sporenie znamená odložiť peniaze namiesto okamžitého míňania'),
        FactItem(emoji: '🏦', text: 'You can save at home in a piggy bank or at the bank in an account', textSk: 'Môžeš šetriť doma v pokladničke alebo v banke na účte'),
        FactItem(emoji: '➕', text: 'Even small amounts matter when saved regularly', textSk: 'Aj malé sumy majú zmysel, keď sa pravidelne odkladajú'),
      ],
      accentColor: Color(0xFF43A047),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '🎯',
      title: 'Save With a Goal',
      titleSk: 'Šetri s cieľom',
      body: 'It\'s easier to save when you know what you\'re saving for. Pick one thing you really want and put money aside each week until you reach it!',
      bodySk: 'Ľahšie sa šetrí, keď vieš, na čo šetríš. Vyber si jednu vec, ktorú naozaj chceš, a každý týždeň si odkladaj, kým ju nedosiahneš!',
      accentColor: Color(0xFF43A047),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🐷',
      highlightText: 'Saving is like planting a seed — small, patient steps grow into something big!',
      highlightTextSk: 'Sporenie je ako sadenie semienka — malé, trpezlivé kroky vyrastú na niečo veľké!',
      accentColor: Color(0xFF43A047),
    ),
  ],

  'preco_si_odkladat': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🔐',
      title: 'Why Set Money Aside?',
      titleSk: 'Prečo si odkladať peniaze?',
      body: 'Why don\'t you always need to spend all your money?',
      bodySk: 'Prečo vždy netreba minúť všetky peniaze?',
      accentColor: Color(0xFF1E88E5),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      // photo chrumko s knihou
      emoji: '📚',
      storyTitle: 'The Book Chrumko Wanted',
      storyTitleSk: 'Kniha, ktorú Chrumko chcel',
      storyBody: 'Chrumko notices a book in the bookshop he really loves. But it costs more than his weekly pocket money. Because he always sets aside part of his allowance, he already has enough saved. He buys the book — no waiting needed!',
      storyBodySk: 'Chrumko si všimne v kníhkupectve knihu, ktorá sa mu veľmi páči. Stojí však viac, ako je jeho vreckové. Keďže si vždy odkladá časť vreckového, má dosť ušetrené. Kúpi si knihu — žiadne čakanie!',
      accentColor: Color(0xFF1E88E5),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🛡️',
      title: 'Why Savings Matter',
      titleSk: 'Prečo sú úspory dôležité',
      facts: [
        FactItem(emoji: '🎯', text: 'Saved money can buy bigger things your allowance alone can\'t cover', textSk: 'Ušetrené peniaze môžu kúpiť väčšie veci, na ktoré vreckové nestačí'),
        FactItem(emoji: '🆘', text: 'Savings help in unexpected situations', textSk: 'Úspory pomáhajú v nečakaných situáciách'),
        FactItem(emoji: '🌅', text: 'Having savings gives you a calm, free feeling', textSk: 'Mať úspory dáva pokojný a slobodný pocit'),
      ],
      accentColor: Color(0xFF1E88E5),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🔐',
      highlightText: 'Saved money gives you FREEDOM — it lets you choose, not just react!',
      highlightTextSk: 'Ušetrené peniaze ti dávajú SLOBODU — môžeš si vyberať, nie iba reagovať!',
      accentColor: Color(0xFF1E88E5),
    ),
  ],

  'kratkodoby_vs_dlhodoby': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏁',
      title: 'Short-Term vs Long-Term Goals',
      titleSk: 'Krátkodobý cieľ vs dlhodobý cieľ',
      body: 'What can you save for quickly — and what takes much more time?',
      bodySk: 'Na čo si vieš rýchlo nasporiť — a na čo treba oveľa viac času?',
      accentColor: Color(0xFF7B1FA2),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🧱',
      title: 'Stickers and a Big Set',
      titleSk: 'Nálepky a veľká stavebnica',
      body: 'Chrumko wants new stickers he can save for in one week. He also wants a big building set that costs much more — that will take several weeks of saving. He decides to work on both goals at the same time!',
      bodySk: 'Chrumko chce nové nálepky, na ktoré si vie nasporiť za týždeň. Zároveň sa mu páči veľká stavebnica, ktorá stojí oveľa viac — na tú bude šetriť niekoľko týždňov. Rozhodne sa pracovať na oboch cieľoch naraz!',
      accentColor: Color(0xFF7B1FA2),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📊',
      title: 'Two Types of Goals',
      titleSk: 'Dva typy cieľov',
      facts: [
        FactItem(emoji: '⌛', text: 'Short-term: achieved quickly, usually cheaper — like stickers or a treat', textSk: 'Krátkodobý: dosiahneš rýchlo, zvyčajne lacnejší — napríklad nálepky alebo sladkosť'),
        FactItem(emoji: '🕰️', text: 'Long-term: takes weeks or months, usually more valuable', textSk: 'Dlhodobý: trvá týždne alebo mesiace, zvyčajne hodnotnejší'),
        FactItem(emoji: '🎯', text: 'Having both types of goals keeps saving fun and motivating', textSk: 'Mať oba typy cieľov robí sporenie zábavnejším a motivujúcejším'),
      ],
      accentColor: Color(0xFF7B1FA2),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🏁',
      highlightText: 'Small goals keep you going; big goals keep you dreaming. You need BOTH!',
      highlightTextSk: 'Malé ciele ťa udržujú v pohybe; veľké ciele ťa inšpirujú. Potrebuješ OBOJE!',
      accentColor: Color(0xFF7B1FA2),
    ),
  ],

  'ako_si_vytvorit_rezervu': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🛡️',
      title: 'Building a Reserve',
      titleSk: 'Ako si vytvoriť rezervu',
      body: 'Is it a good idea to have saved money even without a specific plan?',
      bodySk: 'Je dobré mať odložené peniaze aj bez konkrétneho plánu?',
      accentColor: Color(0xFF00838F),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      // photo chrumko s obalkou
      emoji: '📦',
      title: 'Chrumko\'s Envelope',
      titleSk: 'Chrumkova obálka',
      body: 'Chrumko keeps some money in a small envelope and doesn\'t want to spend it yet. A few days later at school he discovers he needs material for a project. Thanks to his reserve, he doesn\'t have to stress about where to get the money — he can buy what he needs right away.',
      bodySk: 'Chrumko si necháva časť peňazí v malej obálke a nechce ich hneď minúť. O pár dní v škole zistí, že potrebuje materiál na projekt. Vďaka rezerve nemusí riešiť, odkiaľ peniaze zobrať — materiál môže kúpiť hneď.',
      accentColor: Color(0xFF00838F),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🆘',
      title: 'What a Reserve Is For',
      titleSk: 'Na čo je rezerva',
      facts: [
        FactItem(emoji: '🔧', text: 'Unexpected repairs or replacements (a broken toy, a lost pencil)', textSk: 'Nečakané opravy alebo náhrady (pokazená hračka, stratená ceruzka)'),
        FactItem(emoji: '📋', text: 'Surprise school needs — materials, trips, events', textSk: 'Nečakané školské potreby — materiál, výlety, udalosti'),
        FactItem(emoji: '✨', text: 'Peace of mind knowing you\'re always prepared', textSk: 'Pokoj v duši, že si vždy pripravený'),
      ],
      accentColor: Color(0xFF00838F),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🛡️',
      highlightText: 'A reserve is your financial safety net — always have a little set aside "just in case"!',
      highlightTextSk: 'Rezerva je tvoja finančná sieť bezpečnosti — vždy si trochu nechaj "pre istotu"!',
      accentColor: Color(0xFF00838F),
    ),
  ],

  'pravidelne_male_sumy': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🪙',
      title: 'Small Amounts Add Up',
      titleSk: 'Pravidelné malé sumy',
      body: 'Can small coins really grow into something bigger over time?',
      bodySk: 'Môžu malé mince časom narásť na väčšiu sumu?',
      accentColor: Color(0xFFFB8C00),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      iconWidget: MyFlutterApp.saving,
      iconSize: 300,
      iconContainerSize: 320, 
      emoji: '🪙',
      storyTitle: 'Chrumko\'s 50 Cents',
      storyTitleSk: 'Chrumkových 50 centov',
      storyBody: 'Chrumko saves 50 cents every week. At first it seems like very little. After several weeks he discovers he has several euros! He can buy something he could never afford with just one coin.',
      storyBodySk: 'Chrumko si každý týždeň odloží 50 centov. Na začiatku sa mu zdá, že je to veľmi málo. Po niekoľkých týždňoch však zistí, že má už niekoľko eur! Môže si kúpiť vec, na ktorú by mu jedna minca nikdy nestačila.',
      accentColor: Color(0xFFFB8C00),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📈',
      title: 'The Power of Regular Saving',
      titleSk: 'Sila pravidelného sporenia',
      facts: [
        FactItem(emoji: '📅', text: '50 cents a week = €2 a month = €26 a year!', textSk: '50 centov týždenne = 2 € mesačne = 26 € za rok!'),
        FactItem(emoji: '🔁', text: 'The key is regularity — even tiny amounts count', textSk: 'Kľúčom je pravidelnosť — aj drobné sumy sa počítajú'),
        FactItem(emoji: '🏔️', text: 'Small steps consistently taken lead to big results', textSk: 'Malé kroky robené pravidelne vedú k veľkým výsledkom'),
      ],
      accentColor: Color(0xFFFB8C00),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '📈',
      highlightText: 'Don\'t underestimate small amounts — CONSISTENCY turns coins into real savings!',
      highlightTextSk: 'Nepodceňuj malé sumy — PRAVIDELNOSŤ mení mince na skutočné úspory!',
      accentColor: Color(0xFFFB8C00),
    ),
  ],

// ════════════════════════════════════════════
// SECTION 5 — CENA A HODNOTA
// ════════════════════════════════════════════

  'cena_vs_kvalita': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '⚖️',
      title: 'Price vs Quality',
      titleSk: 'Cena vs kvalita',
      body: 'Is a more expensive thing always better — or do we sometimes pay for something other than the product itself?',
      bodySk: 'Je drahšia vec vždy lepšia, alebo niekedy platíme aj za niečo iné než samotný výrobok?',
      accentColor: Color(0xFF6D4C41),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      // photo chrumko a ceruzka
      emoji: '✏️',
      storyTitle: 'Two Pencils',
      storyTitleSk: 'Dve ceruzky',
      storyBody: 'Chrumko is choosing a pencil in the stationery shop. One has a colourful label and a famous brand — so it costs more. Next to it is a simpler pencil that costs less. He tries both on paper. Both write equally well. The shop assistant explains the dearer one costs more partly because of its famous name. Chrumko realises a higher price doesn\'t automatically mean better quality.',
      storyBodySk: 'Chrumko si v papiernictve vyberá novú ceruzku. Jedna má farebný obal a známu značku — preto stojí viac. Vedľa leží jednoduchšia ceruzka, ktorá stojí menej. Obe vyskúša na papieri. Obe píšu rovnako dobre. Predavačka mu vysvetlí, že drahšia stojí viac aj pre známe meno. Chrumko si uvedomí, že vyššia cena automaticky neznamená lepšiu kvalitu.',
      accentColor: Color(0xFF6D4C41),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🔍',
      title: 'What Affects Price',
      titleSk: 'Čo ovplyvňuje cenu',
      facts: [
        FactItem(emoji: '🏷️', text: 'Brand name — famous brands charge more', textSk: 'Značka — známe značky účtujú viac'),
        FactItem(emoji: '🔨', text: 'Materials — better materials can mean higher quality', textSk: 'Materiály — lepšie materiály môžu znamenať vyššiu kvalitu'),
        FactItem(emoji: '📺', text: 'Advertising — companies spend a lot on ads and you pay for it', textSk: 'Reklama — firmy míňajú veľa na reklamu a ty to platíš'),
      ],
      accentColor: Color(0xFF6D4C41),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '🕵️',
      title: 'Be a Smart Buyer',
      titleSk: 'Buď chytrý kupujúci',
      body: 'Don\'t just look at the price tag — look at the actual product. How well does it work? How long will it last? Those are the questions that matter!',
      bodySk: 'Nepozeraj len na cenovku — pozri sa na samotný výrobok. Ako dobre funguje? Ako dlho vydrží? To sú otázky, ktoré sa počítajú!',
      accentColor: Color(0xFF6D4C41),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '⚖️',
      highlightText: 'Higher price doesn\'t always mean higher quality. Look at what you\'re actually getting!',
      highlightTextSk: 'Vyššia cena nie vždy znamená vyššiu kvalitu. Pozri, čo skutočne dostávaš!',
      accentColor: Color(0xFF6D4C41),
    ),
  ],

  'lacne_vs_drahe': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏷️',
      title: 'Cheap vs Expensive',
      titleSk: 'Lacné vs drahé',
      body: 'Why can two similar things cost completely different amounts?',
      bodySk: 'Prečo môžu dve podobné veci stáť úplne rozdielne peniaze?',
      accentColor: Color(0xFF0277BD),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '📓',
      storyTitle: 'Two Notebooks',
      storyTitleSk: 'Dva zošity',
      storyBody: 'Chrumko needs a new exercise book for school. In the first shop he sees one with a nice cover at a higher price. In another shop he finds a similar one for less. Both have the same number of pages and work the same way. The only difference is the cover and brand. He realises that looking in more than one place can find a better price!',
      storyBodySk: 'Chrumko potrebuje nový zošit do školy. V prvom obchode vidí zošit s pekným obalom za vyššiu cenu. V inom obchode nájde podobný zošit lacnejšie. Oba majú rovnaký počet strán a dajú sa rovnako používať. Rozdiel je len v obale a značke. Zistí, že pohľad na viac miest môže nájsť lepšiu cenu!',
      accentColor: Color(0xFF0277BD),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📊',
      title: 'Why Prices Differ',
      titleSk: 'Prečo sa ceny líšia',
      facts: [
        FactItem(emoji: '🏪', text: 'Different shops set different prices for the same product', textSk: 'Rôzne obchody si nastavujú rôzne ceny za rovnaký výrobok'),
        FactItem(emoji: '📦', text: 'Packaging, brand, and store location all affect price', textSk: 'Obal, značka a poloha obchodu ovplyvňujú cenu'),
        FactItem(emoji: '👀', text: 'A quick comparison can save you real money', textSk: 'Rýchle porovnanie ti môže ušetriť skutočné peniaze'),
      ],
      accentColor: Color(0xFF0277BD),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🏷️',
      highlightText: 'The same product, the same quality — sometimes a different shop means a better price!',
      highlightTextSk: 'Rovnaký výrobok, rovnaká kvalita — niekedy iný obchod znamená lepšiu cenu!',
      accentColor: Color(0xFF0277BD),
    ),
  ],

  'vyhodna_kupa': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '✅',
      title: 'What Makes a Good Deal?',
      titleSk: 'Čo znamená výhodná kúpa',
      body: 'When can you truly say a purchase was a good one?',
      bodySk: 'Kedy sa dá povedať, že kúpa bola naozaj dobrá?',
      accentColor: Color(0xFF2E7D32),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      // photo chrumko s flasou
      emoji: '💧',
      storyTitle: 'Chrumko\'s Water Bottle',
      storyTitleSk: 'Chrumkova fľaša na vodu',
      storyBody: 'Chrumko wants a new water bottle for school. He sees a very cheap thin plastic one, but it looks fragile. Next to it is a sturdier bottle that costs more. He chooses the sturdier one because he can use it every day. Weeks later he\'s glad — it hasn\'t been damaged and still works perfectly. The more expensive bottle turned out to be the better deal!',
      storyBodySk: 'Chrumko chce novú fľašu na vodu do školy. Vidí veľmi lacnú tenkú plastovú, ale zdá sa krehká. Vedľa je pevnejšia fľaša, ktorá stojí viac. Vyberie si pevnejšiu, pretože ju môže používať každý deň. O týždne neskôr je rád — nepoškodila sa a stále skvelo slúži. Drahšia fľaša bola nakoniec výhodnejšia kúpa!',
      accentColor: Color(0xFF2E7D32),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🏆',
      title: 'Signs of a Good Deal',
      titleSk: 'Znaky výhodnej kúpy',
      facts: [
        FactItem(emoji: '⏳', text: 'The item lasts a long time and does its job well', textSk: 'Vec dlho vydrží a dobre plní svoju úlohu'),
        FactItem(emoji: '💰', text: 'The price matches what you actually get', textSk: 'Cena zodpovedá tomu, čo skutočne dostaneš'),
        FactItem(emoji: '🚫', text: 'A cheap item that breaks quickly is NOT a good deal', textSk: 'Lacná vec, ktorá sa rýchlo pokazí, NIE je výhodná kúpa'),
      ],
      accentColor: Color(0xFF2E7D32),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '✅',
      highlightText: 'A good deal = good price AND good quality. Both matter!',
      highlightTextSk: 'Výhodná kúpa = dobrá cena A dobrá kvalita. Oboje sa počíta!',
      accentColor: Color(0xFF2E7D32),
    ),
  ],

  'porovnavanie_cien': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🔎',
      title: 'Comparing Prices',
      titleSk: 'Porovnávanie cien',
      body: 'Can the same thing cost less just by looking a little longer?',
      bodySk: 'Môže rovnaká vec stáť menej len preto, že ju hľadáme o chvíľu dlhšie?',
      accentColor: Color(0xFF4527A0),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      // photo chrumko a pastelky
      emoji: '🖍️',
      storyTitle: 'Chrumko\'s Coloured Pencils',
      storyTitleSk: 'Chrumkove pastelky',
      storyBody: 'Chrumko wants coloured pencils. In the first shop he finds a set he likes. Later in another shop he sees the same set — same number of colours — but cheaper. He compares the packaging and content: it\'s the same product. He buys the cheaper set and has money left for other school supplies.',
      storyBodySk: 'Chrumko chce pastelky. V prvom obchode nájde sadu, ktorá sa mu páči. Neskôr v inom obchode uvidí rovnakú sadu — rovnaký počet farieb — ale lacnejšie. Porovná obaly aj obsah: je to rovnaký výrobok. Kúpi lacnejšiu sadu a zostanú mu peniaze na ďalšie školské potreby.',
      accentColor: Color(0xFF4527A0),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📋',
      title: 'How to Compare',
      titleSk: 'Ako porovnávať',
      facts: [
        FactItem(emoji: '1️⃣', text: 'Check what\'s inside — quantity and quality', textSk: 'Skontroluj obsah — množstvo a kvalitu'),
        FactItem(emoji: '2️⃣', text: 'Look at the price per item or per gram', textSk: 'Pozri sa na cenu za kus alebo za gram'),
        FactItem(emoji: '3️⃣', text: 'Check at least two different shops before buying', textSk: 'Pred kúpou pozri aspoň v dvoch rôznych obchodoch'),
      ],
      accentColor: Color(0xFF4527A0),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🔎',
      highlightText: 'A few extra minutes of comparing can save real money — always check more than one option!',
      highlightTextSk: 'Pár minút porovnávania môže ušetriť skutočné peniaze — vždy pozri viac ako jednu možnosť!',
      accentColor: Color(0xFF4527A0),
    ),
  ],

  'jednotkova_cena': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📏',
      title: 'Unit Price',
      titleSk: 'Jednotková cena',
      body: 'Is a bigger pack always more expensive — or can it actually work out cheaper?',
      bodySk: 'Je väčšie balenie vždy drahšie, alebo môže v skutočnosti vyjsť výhodnejšie?',
      accentColor: Color(0xFF00695C),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '💧',
      // photo chrumko a flasa
      storyTitle: 'Water Before the Trip',
      storyTitleSk: 'Voda pred cestou',
      storyBody: 'Chrumko wants to buy water before a journey. He sees two small bottles and one large one. At first the two small ones seem better since each costs less. But when he looks closer, two small bottles together cost more than one large bottle. His mum shows him there\'s more water in the big bottle for a lower price. Chrumko understands: sometimes it pays to look at the quantity, not just the price!',
      storyBodySk: 'Chrumko chce kúpiť vodu pred cestou. Vidí dve malé fľaše a jednu veľkú. Najprv sa mu zdá, že dve malé budú lepšie, lebo každá stojí menej. Keď sa však pozrie bližšie, dve malé spolu stoja viac než jedna veľká. Mama mu ukáže, že vo veľkej je viac vody za nižšiu cenu. Chrumko pochopí: niekedy sa oplatí pozerať aj na množstvo, nielen na cenu!',
      accentColor: Color(0xFF00695C),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🧮',
      title: 'What Is Unit Price?',
      titleSk: 'Čo je jednotková cena?',
      facts: [
        FactItem(emoji: '📏', text: 'Unit price = price per 1 item, 1 litre, or 1 gram', textSk: 'Jednotková cena = cena za 1 kus, 1 liter alebo 1 gram'),
        FactItem(emoji: '📦', text: 'A bigger pack may cost more overall, but less per unit', textSk: 'Väčšie balenie môže stáť celkovo viac, ale menej za kus'),
        FactItem(emoji: '🧮', text: 'Always divide the total price by the quantity to compare fairly', textSk: 'Vždy vydeľ celkovú cenu množstvom, aby si mohol spravodlivo porovnať'),
      ],
      accentColor: Color(0xFF00695C),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '📏',
      highlightText: 'The total price isn\'t everything — always check the UNIT PRICE to find the real best deal!',
      highlightTextSk: 'Celková cena nie je všetko — vždy skontroluj JEDNOTKOVÚ CENU, aby si našiel skutočne najlepšiu kúpu!',
      accentColor: Color(0xFF00695C),
    ),
  ],

// ════════════════════════════════════════════
// SECTION 6 — NAKUPOVANIE A ROZHODOVANIE
// ════════════════════════════════════════════

  'ako_funguje_obchod': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏪',
      title: 'How Does a Shop Work?',
      titleSk: 'Ako funguje obchod?',
      body: 'What is actually happening in a shop?',
      bodySk: 'Čo sa v skutočnosti deje v obchode?',
      accentColor: Color(0xFF1565C0),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '🛒',
      storyTitle: 'Chrumko at the Shop',
      storyTitleSk: 'Chrumko v obchode',
      storyBody: 'Chrumko goes to the shop with his mum after school. He takes a basket and looks at the shelves. He picks a bread roll, apples, and yoghurt. His mum shows him the price tag and explains it tells them how much they\'ll pay at the till. When they reach the checkout the cashier scans each item and the total appears on the screen. Each item is added to the final price.',
      storyBodySk: 'Chrumko ide popoludní s mamou do obchodu. Pri vstupe si vezme košík a pozerá sa na regály. Vyberie rožok, jablká a jogurt. Mama mu ukáže cenovku a vysvetlí, že ukazuje, koľko za výrobok zaplatia pri pokladni. Keď prídu k pokladni, predavačka výrobky naskenuje a na displeji sa objaví celková suma. Každá vec sa pripočíta k výslednej cene.',
      accentColor: Color(0xFF1565C0),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🔄',
      title: 'How Shops Work',
      titleSk: 'Ako fungujú obchody',
      facts: [
        FactItem(emoji: '🏭', text: 'Shops buy products from manufacturers or suppliers', textSk: 'Obchody nakupujú výrobky od výrobcov alebo dodávateľov'),
        FactItem(emoji: '💰', text: 'They sell them to customers at a higher price — that\'s how they earn', textSk: 'Predávajú ich zákazníkom za vyššiu cenu — tak zarábajú'),
        FactItem(emoji: '🏗️', text: 'The price includes staff wages, transport, storage, and running costs', textSk: 'V cene sú zahrnuté mzdy, doprava, skladovanie a prevádzka obchodu'),
      ],
      accentColor: Color(0xFF1565C0),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🏪',
      highlightText: 'Every purchase is an exchange: you give money, the shop gives you a product. Both sides gain!',
      highlightTextSk: 'Každý nákup je výmena: ty dáš peniaze, obchod ti dá výrobok. Obe strany získajú!',
      accentColor: Color(0xFF1565C0),
    ),
  ],

  'zlavy': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏷️',
      title: 'Discounts',
      titleSk: 'Zľavy',
      body: 'If something is cheaper, does that automatically mean it\'s worth buying?',
      bodySk: 'Ak je niečo lacnejšie, znamená to automaticky, že sa to oplatí kúpiť?',
      accentColor: Color(0xFFAD1457),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      // photo chrumko a cokolada
      emoji: '🍫',
      storyTitle: 'The Discounted Chocolate',
      storyTitleSk: 'Zlacnená čokoláda',
      storyBody: 'Chrumko goes to the shop to buy only a snack. At the shelf he sees a big red sign advertising a discount on milk chocolate. The price is lower than usual and the packaging looks tempting. He almost puts it in his basket. Then he remembers: he didn\'t plan to buy sweets and he has some at home already. He decides to save the money for something he\'ll actually need later.',
      storyBodySk: 'Chrumko ide do obchodu kúpiť len desiatu. Pri regáli uvidí veľký červený nápis so zľavou na mliečnu čokoládu. Cena je nižšia než zvyčajne a obal vyzerá lákavo. Takmer ju dá do košíka. Potom si spomenie: sladkosť neplánoval kúpiť a doma má ešte inú. Rozhodne sa peniaze nechať na vec, ktorú bude potrebovať neskôr.',
      accentColor: Color(0xFFAD1457),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '💡',
      title: 'Discounts — The Truth',
      titleSk: 'Zľavy — pravda',
      facts: [
        FactItem(emoji: '📣', text: 'Shops use discounts to attract customers and sell more', textSk: 'Obchody používajú zľavy, aby nalákali zákazníkov a predali viac'),
        FactItem(emoji: '❓', text: 'Ask: would I buy this at the normal price?', textSk: 'Opýtaj sa: kúpil by som si toto za normálnu cenu?'),
        FactItem(emoji: '🚫', text: 'Buying something just because it\'s discounted wastes money', textSk: 'Kúpa len preto, že je zlacnená, plytvá peniazmi'),
      ],
      accentColor: Color(0xFFAD1457),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🏷️',
      highlightText: 'A discount is only good if you actually NEED what\'s on offer!',
      highlightTextSk: 'Zľava je dobrá iba vtedy, keď to, čo ponúka, skutočne POTREBUJEŠ!',
      accentColor: Color(0xFFAD1457),
    ),
  ],
  //nefunguje
  'akcie_a_marketingove_triky': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🎭',
      title: 'Sales & Marketing Tricks',
      titleSk: 'Akcie a marketingové triky',
      body: 'Why do some signs in shops catch your eye instantly among all the others?',
      bodySk: 'Prečo niektoré nápisy v obchode vyzerajú tak, že si ich všimneme hneď medzi prvými?',
      accentColor: Color(0xFFE65100),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '🟡',
      storyTitle: '"Best Price" Sign',
      storyTitleSk: 'Nápis "Najlepšia cena"',
      storyBody: 'Chrumko notices a large yellow sign: "Great deal — best price!" The product is placed right at the entrance where everyone sees it. He thinks there must be huge savings. When he checks the price of a similar product on another shelf, the difference is tiny. His mum explains that a big sign doesn\'t automatically mean the best deal. Chrumko learns to compare first, then decide.',
      storyBodySk: 'Chrumko si všimne veľký žltý nápis: „Výhodné balenie za najlepšiu cenu!" Výrobok je položený pri vstupe, kde ho každý vidí. Myslí si, že úspora musí byť obrovská. Keď skontroluje cenu podobného výrobku na inom regáli, rozdiel je veľmi malý. Mama vysvetlí, že veľký nápis automaticky neznamená najlepšiu kúpu. Chrumko sa naučí najprv porovnávať, potom rozhodovať.',
      accentColor: Color(0xFFE65100),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🎯',
      title: 'Common Marketing Tricks',
      titleSk: 'Bežné marketingové triky',
      facts: [
        FactItem(emoji: '🟡', text: '"Best price / only today" — creates urgency so you act fast', textSk: '"Najlepšia cena / len dnes" — vytvára naliehavosť, aby si konal rýchlo'),
        FactItem(emoji: '📍', text: 'Products placed at eye level or at the entrance are often more expensive', textSk: 'Výrobky umiestnené vo výške očí alebo pri vstupe bývajú drahšie'),
        FactItem(emoji: '🔢', text: 'Prices like €1.99 look much cheaper than €2 even though they\'re nearly the same', textSk: 'Ceny ako 1,99 € vyzerajú oveľa lacnejšie ako 2 €, hoci sú skoro rovnaké'),
      ],
      accentColor: Color(0xFFE65100),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '🕵️',
      title: 'Be a Shopping Detective',
      titleSk: 'Buď detektív v obchode',
      body: 'Slow down, compare, and ask yourself: is this really the best option? Don\'t let a colourful sign do your thinking for you!',
      bodySk: 'Spomaľ, porovnaj a opýtaj sa: je toto skutočne najlepšia možnosť? Nedovoľ, aby farebný nápis myslel za teba!',
      accentColor: Color(0xFFE65100),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🎭',
      highlightText: 'Shops are designed to make you spend. Stay alert — YOU are in charge of your money!',
      highlightTextSk: 'Obchody sú navrhnuté, aby si míňal. Buď ostražitý — TY si šéf svojich peňazí!',
      accentColor: Color(0xFFE65100),
    ),
  ],

  'impulzivne_nakupy': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🤯',
      title: 'Impulse Buying',
      titleSk: 'Impulzívne nákupy',
      body: 'Why do we sometimes want to buy something the instant we see it?',
      bodySk: 'Prečo máme niekedy chuť kúpiť si niečo hneď, keď to uvidíme?',
      accentColor: Color(0xFF6A1B9A),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '🍬',
      storyTitle: 'Gum at the Checkout',
      storyTitleSk: 'Žuvačky pri pokladni',
      storyBody: 'Chrumko stands with his mum at the checkout. While waiting in line he sees colourful chewing gum right by the till — placed exactly where everyone notices it. He instantly wants some. Then he remembers he still has sweets at home from yesterday. He waits and in the end doesn\'t buy the gum. The craving passes quickly.',
      storyBodySk: 'Chrumko stojí s mamou pri pokladni. Kým čakajú v rade, uvidí farebné žuvačky hneď pri kase — umiestnené presne tam, kde si ich každý všimne. Hneď ich chce. Potom si spomenie, že doma má ešte sladkosť z včera. Počká a nakoniec si žuvačky nekúpi. Chuť rýchlo prešla.',
      accentColor: Color(0xFF6A1B9A),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🧠',
      title: 'Why Impulse Buys Happen',
      titleSk: 'Prečo sa stávajú impulzívne nákupy',
      facts: [
        FactItem(emoji: '👀', text: 'Seeing something triggers an immediate "I want that!" feeling', textSk: 'Videnie niečoho vyvolá okamžitý pocit „to chcem!"'),
        FactItem(emoji: '🛒', text: 'Shops place tempting items at tills and eye level on purpose', textSk: 'Obchody zámerne umiestňujú lákavé veci pri pokladniach a vo výške očí'),
        FactItem(emoji: '⏸️', text: 'A short pause almost always stops the urge', textSk: 'Krátka pauza skoro vždy zastaví nutkanie'),
      ],
      accentColor: Color(0xFF6A1B9A),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '⏸️',
      title: 'The Pause Rule',
      titleSk: 'Pravidlo pauzy',
      body: 'Before putting anything in your basket, pause for 30 seconds and ask: do I really want this, or do I just want it because I can see it?',
      bodySk: 'Pred vložením čohokoľvek do košíka zastav na 30 sekúnd a opýtaj sa: naozaj to chcem, alebo to chcem len preto, že to vidím?',
      accentColor: Color(0xFF6A1B9A),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🤯',
      highlightText: 'Impulse buys feel exciting for a second — but a PAUSE gives you control!',
      highlightTextSk: 'Impulzívne nákupy sú vzrušujúce na sekundu — ale PAUZA ti dáva kontrolu!',
      accentColor: Color(0xFF6A1B9A),
    ),
  ],

  'ako_nenaletiet_na_reklamu': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🧠',
      title: 'Think for Yourself',
      titleSk: 'Ako sa rozhodovať vlastnou hlavou',
      body: 'How do you know if you want something because you need it — or just because it caught your attention?',
      bodySk: 'Ako zistiť, či niečo chceš preto, že to potrebuješ, alebo preto, že to upútalo tvoju pozornosť?',
      accentColor: Color(0xFF37474F),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      // photo chrumko a pero
      emoji: '🖊️',
      storyTitle: 'Chrumko and the Fancy Pen',
      storyTitleSk: 'Chrumko a farebné pero',
      storyBody: 'Chrumko goes to the shop after school to buy an exercise book. At the shelf he notices a pen with a very colourful cover and a favourite cartoon character. He almost throws it in the basket. Then he remembers he has two perfectly working pens at home. He stops and thinks: does he really need it? He buys only the book and leaves the pen. Days later he\'s glad he spent money only on what he actually needed.',
      storyBodySk: 'Chrumko ide po škole do obchodu kúpiť zošit. Pri regáli si všimne pero s veľmi farebným obalom a obľúbenou postavičkou. Takmer ho hodí do košíka. Potom si spomenie, že doma má dve funkčné perá. Zastaví sa a premýšľa: naozaj ho potrebuje? Kúpi len zošit a pero nechá v obchode. O pár dní je rád, že minul peniaze len na to, čo skutočne potreboval.',
      accentColor: Color(0xFF37474F),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '❓',
      title: 'Three Questions Before Buying',
      titleSk: 'Tri otázky pred nákupom',
      facts: [
        FactItem(emoji: '1️⃣', text: 'Do I actually need this?', textSk: 'Naozaj to potrebujem?'),
        FactItem(emoji: '2️⃣', text: 'Will I use it for a long time?', textSk: 'Budem to používať dlhšie?'),
        FactItem(emoji: '3️⃣', text: 'Is it worth spending my money on this?', textSk: 'Oplatí sa mi za to minúť peniaze?'),
      ],
      accentColor: Color(0xFF37474F),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🧠',
      highlightText: 'Your own brain is the best shopping tool — use it BEFORE you buy, not after!',
      highlightTextSk: 'Tvoj vlastný mozog je najlepší nákupný nástroj — použi ho PRED kúpou, nie po nej!',
      accentColor: Color(0xFF37474F),
    ),
  ],

// ════════════════════════════════════════════
// SECTION 7 — PENIAZE V RODINE
// ════════════════════════════════════════════

  'odkial_rodina_berie_peniaze': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '👨‍👩‍👦',
      title: 'Where Does a Family\'s Money Come From?',
      titleSk: 'Odkiaľ rodina berie peniaze?',
      body: 'How does money get into the family when nobody makes it at home?',
      bodySk: 'Ako sa peniaze dostanú do rodiny, keď ich doma nikto nevyrába?',
      accentColor: Color(0xFF2E7D32),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '📱',
      storyTitle: 'Mum\'s Bank Message',
      storyTitleSk: 'Mamina správa z banky',
      storyBody: 'Chrumko notices his mum looking at a message on her phone from the bank. He asks what arrived. She explains she received her salary for her work. She shows him that from this money the family pays for groceries, the flat, and school supplies. Chrumko realises the money they use at home comes from his parents going to work.',
      storyBodySk: 'Chrumko si všimne, že mama pozerá na správu z banky v telefóne. Spýta sa, čo prišlo. Mama mu vysvetlí, že dostala výplatu za prácu. Ukáže mu, že z týchto peňazí rodina platí potraviny, byt a školské potreby. Chrumko si uvedomí, že peniaze, ktoré doma používajú, prichádzajú preto, že rodičia pracujú.',
      accentColor: Color(0xFF2E7D32),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '💼',
      title: 'Sources of Family Income',
      titleSk: 'Zdroje rodinného príjmu',
      facts: [
        FactItem(emoji: '👔', text: 'Salary — regular pay from an employer for work done', textSk: 'Plat — pravidelná odmena od zamestnávateľa za vykonanú prácu'),
        FactItem(emoji: '🏪', text: 'Business — some parents run their own company or service', textSk: 'Podnikanie — niektorí rodičia prevádzkujú vlastnú firmu alebo službu'),
        FactItem(emoji: '🎁', text: 'Other sources — gifts, benefits, or occasional income', textSk: 'Iné zdroje — darčeky, dávky alebo príležitostný príjem'),
      ],
      accentColor: Color(0xFF2E7D32),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '👨‍👩‍👦',
      highlightText: 'Family money comes from WORK. Work takes time and effort — that\'s why it matters!',
      highlightTextSk: 'Rodinné peniaze pochádzajú z PRÁCE. Práca si vyžaduje čas a úsilie — preto má zmysel!',
      accentColor: Color(0xFF2E7D32),
    ),
  ],

  'vydavky_domacnosti': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏠',
      title: 'Household Expenses',
      titleSk: 'Výdavky domácnosti',
      body: 'Where does the money go even when the family isn\'t buying anything big?',
      bodySk: 'Kam miznú peniaze, keď rodina nič veľké nekupuje?',
      accentColor: Color(0xFF4E342E),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '🌸',
      storyTitle: 'No Flowerpot This Month',
      storyTitleSk: 'Žiadny kvetináč tento mesiac',
      storyBody: 'Chrumko wonders why his parents didn\'t buy the new decorative flowerpot they liked. His dad shows him that this week they already paid the internet bill, water bill, and school lunches. Even though these aren\'t big items, together they add up to a large sum. Chrumko understands: money often goes on many small necessary payments.',
      storyBodySk: 'Chrumko sa čuduje, prečo rodičia nekúpili nový dekoratívny kvetináč, ktorý sa im páčil. Otec mu ukáže, že tento týždeň už platili účet za internet, vodu a školský obed. Aj keď to nie sú veľké veci, spolu tvoria väčšiu sumu. Chrumko pochopí: peniaze často odchádzajú na veľa malých potrebných platieb.',
      accentColor: Color(0xFF4E342E),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📋',
      title: 'Common Household Expenses',
      titleSk: 'Bežné výdavky domácnosti',
      facts: [
        FactItem(emoji: '🏠', text: 'Rent or mortgage — paying for where you live', textSk: 'Nájom alebo hypotéka — platenie za miesto, kde bývate'),
        FactItem(emoji: '🛒', text: 'Food — grocery shopping happens every week', textSk: 'Jedlo — nákup potravín prebieha každý týždeň'),
        FactItem(emoji: '💡', text: 'Utilities — electricity, water, heating, internet', textSk: 'Energie — elektrina, voda, kúrenie, internet'),
        FactItem(emoji: '🎒', text: 'School supplies, transport, healthcare', textSk: 'Školské potreby, doprava, zdravotná starostlivosť'),
      ],
      accentColor: Color(0xFF4E342E),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🏠',
      highlightText: 'Running a home has many regular costs — they all add up, even when nothing "big" is bought!',
      highlightTextSk: 'Chod domácnosti má veľa pravidelných nákladov — všetky sa spočítajú, aj keď sa nič "veľké" nekupuje!',
      accentColor: Color(0xFF4E342E),
    ),
  ],

  'byvanie_stoji_peniaze': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏘️',
      title: 'Housing Costs Money',
      titleSk: 'Bývanie stojí peniaze',
      body: 'Why do we have to pay for the place where we live every single month?',
      bodySk: 'Prečo treba platiť za miesto, kde bývame, každý mesiac?',
      accentColor: Color(0xFF1A237E),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '🔧',
      storyTitle: 'The Monthly Payment',
      storyTitleSk: 'Mesačná platba',
      storyBody: 'Chrumko notices his parents talking about monthly payments for their flat. He asks why they keep paying for a place they already have. His mum explains that housing means not just the space itself, but also heat, water, shared areas, and maintenance. When the lift breaks or the roof needs repair, that costs money too. Chrumko understands: a home needs ongoing care.',
      storyBodySk: 'Chrumko si všimne, že rodičia hovoria o mesačných platbách za byt. Spýta sa, prečo sa stále platí za miesto, ktoré predsa už majú. Mama vysvetlí, že bývanie znamená nielen samotný priestor, ale aj teplo, vodu, spoločné priestory a údržbu. Keď sa pokazí výťah alebo treba opraviť strechu, aj to stojí peniaze. Chrumko pochopí: domov potrebuje stálu starostlivosť.',
      accentColor: Color(0xFF1A237E),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🏗️',
      title: 'What Housing Costs Include',
      titleSk: 'Čo zahŕňajú náklady na bývanie',
      facts: [
        FactItem(emoji: '💳', text: 'Rent or mortgage — regular payment for using or buying the home', textSk: 'Nájom alebo hypotéka — pravidelná platba za používanie alebo kúpu domu'),
        FactItem(emoji: '🔥', text: 'Heating & water — keeping the home comfortable', textSk: 'Kúrenie a voda — udržiavanie domova pohodlného'),
        FactItem(emoji: '🔧', text: 'Repairs & maintenance — things break and need fixing', textSk: 'Opravy a údržba — veci sa kazia a treba ich opraviť'),
      ],
      accentColor: Color(0xFF1A237E),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🏘️',
      highlightText: 'A home is wonderful — and it costs money to keep it warm, safe, and working every day!',
      highlightTextSk: 'Domov je nádherný — a stojí peniaze, aby bol každý deň teplý, bezpečný a funkčný!',
      accentColor: Color(0xFF1A237E),
    ),
  ],

  'jedlo_stoji_peniaze': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🍞',
      title: 'Food Costs Money',
      titleSk: 'Jedlo stojí peniaze',
      body: 'Why doesn\'t the fridge fill itself even though it seems like food is always at home?',
      bodySk: 'Prečo sa chladnička sama nenaplní, aj keď sa zdá, že jedlo je doma stále?',
      accentColor: Color(0xFF558B2F),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      iconWidget: MyFlutterApp.look,
      iconSize: 300,
      iconContainerSize: 320,
      emoji: '🛒',
      storyTitle: 'A Small Shop, A Big Bill',
      storyTitleSk: 'Malý nákup, veľký účet',
      storyBody: 'Chrumko goes on a small shopping trip with his mum. Into the basket go bread, milk, fruit, cheese, pasta, and yoghurts. He thinks they\'re only buying a few things. At the till the sum is higher than he expected. His mum explains that even everyday food items cost a lot together. Chrumko realises food is a big regular part of family spending.',
      storyBodySk: 'Chrumko ide s mamou na menší nákup. Do košíka dávajú chlieb, mlieko, ovocie, syr, cestoviny a jogurty. Zdá sa mu, že kupujú len pár vecí. Pri pokladni vidí vyššiu sumu, než čakal. Mama mu vysvetlí, že aj bežné potraviny spolu stoja dosť. Chrumko si uvedomí, že jedlo je veľká pravidelná časť rodinných výdavkov.',
      accentColor: Color(0xFF558B2F),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🧺',
      title: 'Food Spending Facts',
      titleSk: 'Fakty o výdavkoch na jedlo',
      facts: [
        FactItem(emoji: '🗓️', text: 'Food is bought frequently — it runs out and needs replacing', textSk: 'Jedlo sa kupuje často — míňa sa a treba ho dopĺňať'),
        FactItem(emoji: '👨‍👩‍👦', text: 'The bigger the family, the more food — and the bigger the cost', textSk: 'Čím väčšia rodina, tým viac jedla — a väčší výdavok'),
        FactItem(emoji: '➕', text: 'Small individual items add up to a large monthly total', textSk: 'Malé jednotlivé položky sa spočítajú na veľkú mesačnú sumu'),
      ],
      accentColor: Color(0xFF558B2F),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🍞',
      highlightText: 'Food is one of the BIGGEST regular expenses for every family — it\'s a true need!',
      highlightTextSk: 'Jedlo je jeden z NAJVÄČŠÍCH pravidelných výdavkov každej rodiny — je to skutočná potreba!',
      accentColor: Color(0xFF558B2F),
    ),
  ],

  'energie_stoja_peniaze': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '💡',
      title: 'Energy Costs Money',
      titleSk: 'Energia stojí peniaze',
      body: 'Why do parents turn off lights — even when we could leave them on a little longer?',
      bodySk: 'Prečo rodičia vypínajú svetlo, aj keď ho ešte chvíľu môžeme nechať svietiť?',
      accentColor: Color(0xFFF9A825),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      iconWidget: MyFlutterApp.idea,
      iconSize: 300,
      iconContainerSize: 320,
      emoji: '💡',
      storyTitle: 'The Light Left On',
      storyTitleSk: 'Svetlo nechané svietiť',
      storyBody: 'Chrumko leaves his room and leaves the light on. His mum calls him back and asks him to turn it off. She explains that even small things add up over a month. Later Chrumko notices that at home they turn off the water while brushing teeth and don\'t leave the fridge open for long. He gradually understands: energy isn\'t visible like an object, but it costs money every day.',
      storyBodySk: 'Chrumko odíde z izby a nechá zapnuté svetlo. Mama ho zavolá späť a poprosí ho, aby ho vypol. Vysvetlí mu, že aj malé veci sa počas mesiaca spočítajú. Neskôr si Chrumko všimne, že doma zatvárajú vodu pri umývaní zubov a nenechávajú dlho otvorenú chladničku. Postupne chápe: energia nie je viditeľná ako predmet, ale stojí peniaze každý deň.',
      accentColor: Color(0xFFF9A825),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🔌',
      title: 'Saving Energy = Saving Money',
      titleSk: 'Šetrenie energie = šetrenie peňazí',
      facts: [
        FactItem(emoji: '💡', text: 'Turn off lights when leaving a room', textSk: 'Vypínaj svetlá, keď opúšťaš izbu'),
        FactItem(emoji: '💧', text: 'Turn off the tap when brushing teeth', textSk: 'Zatváraj vodu pri umývaní zubov'),
        FactItem(emoji: '❄️', text: 'Don\'t leave the fridge open longer than needed', textSk: 'Nenechávaj dlho otvorenú chladničku'),
        FactItem(emoji: '📺', text: 'Turn off devices rather than leaving them on standby', textSk: 'Vypínaj zariadenia namiesto toho, aby si ich nechal v pohotovostnom režime'),
      ],
      accentColor: Color(0xFFF9A825),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '💡',
      highlightText: 'Small habits save big money — every bit of energy you save helps your family!',
      highlightTextSk: 'Malé návyky šetria veľké peniaze — každý kúsok energie, ktorý ušetríš, pomáha tvojej rodine!',
      accentColor: Color(0xFFF9A825),
    ),
  ],

// ════════════════════════════════════════════
// SECTION 8 — PRÁCA A PRÍJEM
// ════════════════════════════════════════════

  'preco_ludia_pracuju': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '💼',
      title: 'Why Do People Work?',
      titleSk: 'Prečo ľudia pracujú?',
      body: 'Why do adults go to work every day even when they might prefer to stay home?',
      bodySk: 'Prečo dospelí každý deň chodia do práce, aj keď by radšej zostali doma?',
      accentColor: Color(0xFF00796B),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '🌧️',
      storyTitle: 'Mum Goes to Work in the Rain',
      storyTitleSk: 'Mama ide do práce za dažďa',
      storyBody: 'Chrumko notices in the morning that his mum is getting ready for work even though it\'s raining and it would be nicer to stay home. He asks why she has to go every day. She explains that she receives money for her work which the family uses to pay rent, buy food, and cover school costs. She shows him that electricity and water at home are also paid from her salary.',
      storyBodySk: 'Chrumko si ráno všimne, že mama sa pripravuje do práce, hoci vonku prší a zostalo by sa príjemnejšie doma. Spýta sa, prečo musí ísť každý deň. Mama vysvetlí, že za prácu dostáva peniaze, z ktorých rodina platí nájom, kupuje jedlo a pokrýva školské náklady. Ukáže mu, že aj elektrina a voda doma sa platia z jej platu.',
      accentColor: Color(0xFF00796B),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🌍',
      title: 'Two Reasons People Work',
      titleSk: 'Dva dôvody, prečo ľudia pracujú',
      facts: [
        FactItem(emoji: '💰', text: 'Earning money — to pay for life\'s necessities and more', textSk: 'Zarábanie peňazí — na platenie životných potrieb a ďalšieho'),
        FactItem(emoji: '🤝', text: 'Helping others — teachers, doctors, and builders all make life better for everyone', textSk: 'Pomáhanie ostatným — učitelia, lekári a stavbári zlepšujú život všetkým'),
      ],
      accentColor: Color(0xFF00796B),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '💼',
      highlightText: 'Work creates value — and that value earns money AND makes the world a better place!',
      highlightTextSk: 'Práca vytvára hodnotu — a tá hodnota zarába peniaze A robí svet lepším miestom!',
      accentColor: Color(0xFF00796B),
    ),
  ],

  'typy_povolani': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🌐',
      title: 'Types of Jobs',
      titleSk: 'Typy povolaní',
      body: 'Does everyone do the same work — or does each person have a different role?',
      bodySk: 'Robia všetci dospelí rovnakú prácu, alebo má každý inú úlohu?',
      accentColor: Color(0xFF283593),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '🚌',
      storyTitle: 'Chrumko\'s Walk to School',
      storyTitleSk: 'Chrumkova cesta do školy',
      storyBody: 'Chrumko walks to school and notices how many different people are already working. The bus has a driver, the school has a teacher waiting, workers are fixing the pavement by the road. Later in the shop a shop assistant is stocking shelves and a postman delivers letters. Chrumko realises everyone does something different — but together all these jobs keep the world running.',
      storyBodySk: 'Chrumko ide do školy a všimne si, koľko rôznych ľudí už pracuje. Autobus šoféruje vodič, v škole čaká učiteľka, pri ceste opravujú pracovníci chodník. Neskôr v obchode predavačka dopĺňa tovar a poštár nosí listy. Chrumko si uvedomí, že každý robí niečo iné — ale dohromady tieto práce udržujú svet v chode.',
      accentColor: Color(0xFF283593),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🔧',
      title: 'Types of Work',
      titleSk: 'Typy práce',
      facts: [
        FactItem(emoji: '🏫', text: 'Teaching, healing, helping — working with people', textSk: 'Vyučovanie, liečenie, pomáhanie — práca s ľuďmi'),
        FactItem(emoji: '🏗️', text: 'Building, repairing, making — creating physical things', textSk: 'Stavanie, opravovanie, vyrábanie — tvorba fyzických vecí'),
        FactItem(emoji: '💻', text: 'Organising, designing, computing — working with information', textSk: 'Organizovanie, navrhovanie, počítanie — práca s informáciami'),
      ],
      accentColor: Color(0xFF283593),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🌐',
      highlightText: 'Every job matters — different skills working together make society function!',
      highlightTextSk: 'Každá práca sa počíta — rôzne zručnosti spolupracujúce spolu zabezpečujú fungovanie spoločnosti!',
      accentColor: Color(0xFF283593),
    ),
  ],

  'plat_a_odmena': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '💳',
      title: 'Salary and Pay',
      titleSk: 'Plat a odmena',
      body: 'Does everyone get the same amount of money for their work?',
      bodySk: 'Dostáva každý človek za svoju prácu rovnaké peniaze?',
      accentColor: Color(0xFF4527A0),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '📅',
      title: 'How Salary Works',
      titleSk: 'Ako funguje plat',
      body: 'Chrumko asks his dad why money doesn\'t arrive every day. His dad explains he gets his salary once a month into his bank account. From that money the family gradually pays for everything needed throughout the whole month. Chrumko understands: the money from work needs to be split wisely to last.',
      bodySk: 'Chrumko sa opýta otca, prečo peniaze neprichádzajú každý deň. Otec vysvetlí, že plat dostáva raz za mesiac na účet. Z týchto peňazí rodina postupne platí všetko potrebné počas celého mesiaca. Chrumko pochopí: peniaze z práce treba rozumne rozdeliť, aby vystačili.',
      accentColor: Color(0xFF4527A0),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📊',
      title: 'What Affects Pay',
      titleSk: 'Čo ovplyvňuje plat',
      facts: [
        FactItem(emoji: '🎓', text: 'Education and skills — more expertise often means higher pay', textSk: 'Vzdelanie a zručnosti — viac odbornosti často znamená vyšší plat'),
        FactItem(emoji: '⚖️', text: 'Responsibility — managing more comes with more pay', textSk: 'Zodpovednosť — väčšia zodpovednosť prináša vyšší plat'),
        FactItem(emoji: '⏰', text: 'Time — hours, days, or months of work all count', textSk: 'Čas — hodiny, dni alebo mesiace práce sa všetky počítajú'),
      ],
      accentColor: Color(0xFF4527A0),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '💳',
      highlightText: 'Salary is the reward for work — and it must be planned carefully to cover the whole month!',
      highlightTextSk: 'Plat je odmena za prácu — a treba ho starostlivo naplánovať, aby pokryl celý mesiac!',
      accentColor: Color(0xFF4527A0),
    ),
  ],

  'cas_je_hodnota': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '⏰',
      title: 'Time = Pay',
      titleSk: 'Čas = odmena',
      body: 'Why does it also matter HOW MUCH TIME you put into your work?',
      bodySk: 'Prečo záleží aj na tom, koľko ČASU práci venuješ?',
      accentColor: Color(0xFF00838F),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      // photo chrumko a kvet
      emoji: '🌿',
      storyTitle: 'Chrumko\'s Brother in the Garden',
      storyTitleSk: 'Chrumkov brat v záhrade',
      storyBody: 'Chrumko sees his older brother helping their neighbour tidy the garden at the weekend. They work together all morning, collecting leaves, raking grass, and carrying branches. After the work the brother receives a small reward. The neighbour explains that the pay is for the time and the help he devoted to the work. Chrumko understands: time and effort count at work.',
      storyBodySk: 'Chrumko vidí, že jeho starší brat cez víkend pomáha susedovi upratať záhradu. Pracujú spolu celé dopoludnie, zbierajú lístie, hrabú trávu a nosia konáre. Po práci dostane brat malú odmenu. Sused mu vysvetlí, že odmena je za čas aj pomoc, ktorú venoval práci. Chrumko pochopí: čas a úsilie sa pri práci počítajú.',
      accentColor: Color(0xFF00838F),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '⏱️',
      title: 'Time at Work',
      titleSk: 'Čas v práci',
      facts: [
        FactItem(emoji: '📐', text: 'Many jobs pay by the hour — more hours worked, more earned', textSk: 'Mnohé práce platia za hodinu — viac odpracovaných hodín, viac zarobené'),
        FactItem(emoji: '🗓️', text: 'Monthly salaries cover all the hours worked that month', textSk: 'Mesačné platy pokrývajú všetky hodiny odpracované v danom mesiaci'),
        FactItem(emoji: '💪', text: 'Effort and quality of work also matter, not just time', textSk: 'Záleží aj na úsilí a kvalite práce, nielen na čase'),
      ],
      accentColor: Color(0xFF00838F),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '⏰',
      highlightText: 'Time is valuable — at work, the time and effort you give comes back to you as pay!',
      highlightTextSk: 'Čas je cenný — v práci sa čas a úsilie, ktoré vložíš, vrátia ako odmena!',
      accentColor: Color(0xFF00838F),
    ),
  ],

  'produktivita': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🚀',
      title: 'Productivity',
      titleSk: 'Produktivita',
      body: 'Is it important only to work for a long time — or also to work effectively?',
      bodySk: 'Je dôležité len pracovať dlho, alebo aj pracovať efektívne?',
      accentColor: Color(0xFFBF360C),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      // photo chrumko s mobilom a knihou
      emoji: '📖',
      storyTitle: 'Homework: Distracted vs Focused',
      storyTitleSk: 'Domáca úloha: rozptýlený vs sústredený',
      storyBody: 'Chrumko does his homework. First he keeps looking at his phone and stopping often. The assignment takes a long time. The next day he sits down without distractions, prepares everything he needs and works in a focused way. This time he finishes much faster and without stress. He realises that when he works carefully, he manages more in less time.',
      storyBodySk: 'Chrumko si robí domácu úlohu. Najprv sa stále pozerá na mobil a často prerušuje prácu. Úloha mu trvá veľmi dlho. Na druhý deň si sadne bez vyrušovania, pripraví si všetko potrebné a pracuje sústredene. Tentoraz úlohu dokončí rýchlejšie a bez stresu. Uvedomí si, že keď pracuje pozorne, zvládne viac za kratší čas.',
      accentColor: Color(0xFFBF360C),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '⚙️',
      title: 'How to Be Productive',
      titleSk: 'Ako byť produktívny',
      facts: [
        FactItem(emoji: '📵', text: 'Remove distractions — put away your phone while working', textSk: 'Odstrán rozptýlenie — odlož telefón počas práce'),
        FactItem(emoji: '✅', text: 'Prepare everything you need before starting', textSk: 'Priprav si všetko potrebné pred začatím'),
        FactItem(emoji: '🎯', text: 'Focus on one task at a time rather than switching between many', textSk: 'Sústreď sa na jednu úlohu naraz namiesto prepínania medzi mnohými'),
      ],
      accentColor: Color(0xFFBF360C),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🚀',
      highlightText: 'Working SMART beats working long — focus and effort make you truly productive!',
      highlightTextSk: 'Pracovať MÚDRO je lepšie ako pracovať dlho — sústredenie a úsilie ťa robia skutočne produktívnym!',
      accentColor: Color(0xFFBF360C),
    ),
  ],

// ════════════════════════════════════════════
// SECTION 9 — ROZPOČET
// ════════════════════════════════════════════

  'co_je_rozpocet': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📒',
      title: 'What Is a Budget?',
      titleSk: 'Čo je rozpočet?',
      body: 'How do people know how much they can spend so the money lasts to the end of the month?',
      bodySk: 'Ako ľudia vedia, koľko môžu minúť, aby im peniaze vystačili do konca mesiaca?',
      accentColor: Color(0xFF1565C0),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '📓',
      storyTitle: 'Mum\'s Notebook',
      storyTitleSk: 'Mamin zošit',
      storyBody: 'Chrumko sees his mum writing numbers in a notebook. He asks what she\'s doing. She explains she\'s planning expenses for the whole month. First she writes down the money the family will receive, then what needs to be paid. Only then does she think about what might be left over for extras. Chrumko understands: a budget helps keep money in order.',
      storyBodySk: 'Chrumko vidí, že mama si zapisuje čísla do zošita. Spýta sa, čo robí. Mama vysvetlí, že plánuje výdavky na celý mesiac. Najprv zapíše peniaze, ktoré rodina dostane, potom to, čo treba zaplatiť. Až potom rozmýšľa, čo môže zostať navyše. Chrumko pochopí: rozpočet pomáha mať v peniazoch poriadok.',
      accentColor: Color(0xFF1565C0),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📐',
      title: 'What a Budget Shows',
      titleSk: 'Čo ukazuje rozpočet',
      facts: [
        FactItem(emoji: '📥', text: 'Income — money coming in (salary, pocket money, etc.)', textSk: 'Príjem — peniaze prichádzajúce (plat, vreckové a pod.)'),
        FactItem(emoji: '📤', text: 'Expenses — money going out (food, rent, transport, fun)', textSk: 'Výdavky — peniaze odchádzajúce (jedlo, nájom, doprava, zábava)'),
        FactItem(emoji: '⚖️', text: 'Balance — what\'s left after subtracting expenses from income', textSk: 'Zostatok — čo zostane po odpočítaní výdavkov od príjmu'),
      ],
      accentColor: Color(0xFF1565C0),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '📝',
      title: 'Make Your Own Budget',
      titleSk: 'Urob si vlastný rozpočet',
      body: 'Even kids can make a budget! Write down your pocket money, then list what you want to spend it on. Subtract the expenses and see what\'s left to save.',
      bodySk: 'Aj deti si môžu urobiť rozpočet! Zapíš svoje vreckové, potom vypíš, na čo ho chceš minúť. Odpočítaj výdavky a uvidíš, čo zostane na sporenie.',
      accentColor: Color(0xFF1565C0),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '📒',
      highlightText: 'A budget is a plan for your money — it keeps you in control instead of always wondering "where did it go?"!',
      highlightTextSk: 'Rozpočet je plán pre tvoje peniaze — udržuje ťa v kontrole namiesto stáleho premýšľania "kam to všetko išlo?"!',
      accentColor: Color(0xFF1565C0),
    ),
  ],

  'prijmy_a_vydavky': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '⚖️',
      title: 'Income and Expenses',
      titleSk: 'Príjmy a výdavky',
      body: 'Why isn\'t it enough to just know how much money you have?',
      bodySk: 'Prečo nestačí vedieť len to, koľko peňazí máme?',
      accentColor: Color(0xFF2E7D32),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '🧮',
      storyTitle: 'After the Salary Comes the Bills',
      storyTitleSk: 'Po plate prídu účty',
      storyBody: 'Chrumko thinks that once parents receive their salary they can immediately buy everything they want. His dad shows him that before spending, they first have to subtract rent, food, and other bills. After those expenses are paid, a smaller amount remains. Chrumko realises: it\'s not just about what comes in but what goes out too.',
      storyBodySk: 'Chrumko si myslí, že keď rodičia dostanú výplatu, môžu hneď kúpiť všetko, čo chcú. Otec mu ukáže, že pred míňaním treba odpočítať bývanie, jedlo a ďalšie účty. Keď tieto výdavky zaplatia, zostane menšia suma. Chrumko si uvedomí: dôležité nie je len to, čo príde, ale aj to, čo odíde.',
      accentColor: Color(0xFF2E7D32),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📊',
      title: 'Income vs Expenses',
      titleSk: 'Príjmy vs výdavky',
      facts: [
        FactItem(emoji: '📈', text: 'If income > expenses → you can save the difference', textSk: 'Ak príjmy > výdavky → môžeš ušetriť rozdiel'),
        FactItem(emoji: '📉', text: 'If expenses > income → there\'s a problem: spending more than you earn', textSk: 'Ak výdavky > príjmy → je tu problém: míňaš viac, ako zarobíš'),
        FactItem(emoji: '✅', text: 'A healthy budget keeps expenses below income', textSk: 'Zdravý rozpočet udržuje výdavky pod príjmami'),
      ],
      accentColor: Color(0xFF2E7D32),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '⚖️',
      highlightText: 'Track BOTH sides — what comes in AND what goes out. That\'s the secret to money balance!',
      highlightTextSk: 'Sleduj OBE strany — čo prichádza AJ čo odchádza. To je tajomstvo finančnej rovnováhy!',
      accentColor: Color(0xFF2E7D32),
    ),
  ],

  'mesacne_planovanie': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📅',
      title: 'Monthly Planning',
      titleSk: 'Mesačné plánovanie',
      body: 'Why doesn\'t a family spend all their money at the very start of the month?',
      bodySk: 'Prečo rodina neminie všetky peniaze hneď na začiatku mesiaca?',
      accentColor: Color(0xFF6A1B9A),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      // photo chrumko a playstation
      emoji: '🎮',
      storyTitle: 'Not Right After Pay Day',
      storyTitleSk: 'Nie hneď po výplate',
      storyBody: 'Chrumko suggests buying a new game right after his mum\'s salary arrives. She explains they must wait until all the important things are paid. In a few days more payments come for school and the household. Only then will they see what they can afford extra. Chrumko understands: money needs to be spread across the whole month.',
      storyBodySk: 'Chrumko navrhne kúpiť novú hru hneď po výplate. Mama vysvetlí, že najprv musia počkať, kým zaplatia všetko dôležité. O niekoľko dní prídu ďalšie platby za školu a domácnosť. Až potom uvidia, čo si môžu dovoliť navyše. Chrumko pochopí: peniaze treba rozložiť na celý mesiac.',
      accentColor: Color(0xFF6A1B9A),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🗓️',
      title: 'Monthly Planning Steps',
      titleSk: 'Kroky mesačného plánovania',
      facts: [
        FactItem(emoji: '1️⃣', text: 'Know your monthly income', textSk: 'Poznaj mesačný príjem'),
        FactItem(emoji: '2️⃣', text: 'List all regular expenses (rent, food, bills)', textSk: 'Vypíš všetky pravidelné výdavky (nájom, jedlo, účty)'),
        FactItem(emoji: '3️⃣', text: 'What\'s left = available for extras and savings', textSk: 'Čo zostane = k dispozícii pre ďalšie výdavky a sporenie'),
      ],
      accentColor: Color(0xFF6A1B9A),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '📅',
      highlightText: 'A month is 30 days — money must last all 30, not just the first few!',
      highlightTextSk: 'Mesiac má 30 dní — peniaze musia vydržať všetkých 30, nielen prvých pár!',
      accentColor: Color(0xFF6A1B9A),
    ),
  ],

  'fixne_vydavky': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🔁',
      title: 'Fixed Expenses',
      titleSk: 'Fixné výdavky',
      body: 'Why do some payments repeat exactly the same every month?',
      bodySk: 'Prečo sa niektoré výdavky opakujú stále rovnako?',
      accentColor: Color(0xFF4E342E),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '📡',
      storyTitle: 'The Same Bills Every Month',
      storyTitleSk: 'Rovnaké účty každý mesiac',
      storyBody: 'Chrumko asks why his parents talk about the same payments every month. His dad shows him the internet and rent bills. He explains these payments come regularly. Even if they don\'t buy anything new this month, these expenses remain the same. Chrumko understands: some money is set aside first — always.',
      storyBodySk: 'Chrumko sa pýta, prečo rodičia každý mesiac hovoria o rovnakých platbách. Otec mu ukáže účet za internet a nájom. Vysvetlí, že tieto platby prichádzajú pravidelne. Aj keď tento mesiac nič nové nekupujú, tieto výdavky zostávajú rovnaké. Chrumko pochopí: niektoré peniaze sú vždy vopred určené.',
      accentColor: Color(0xFF4E342E),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📋',
      title: 'Examples of Fixed Expenses',
      titleSk: 'Príklady fixných výdavkov',
      facts: [
        FactItem(emoji: '🏠', text: 'Rent or mortgage — same amount every month', textSk: 'Nájom alebo hypotéka — rovnaká suma každý mesiac'),
        FactItem(emoji: '📡', text: 'Internet and phone — regular monthly subscription', textSk: 'Internet a telefón — pravidelné mesačné predplatné'),
        FactItem(emoji: '🏫', text: 'School lunches or fees — predictable recurring cost', textSk: 'Školský obed alebo poplatky — predvídateľný opakujúci sa náklad'),
      ],
      accentColor: Color(0xFF4E342E),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🔁',
      highlightText: 'Fixed expenses come FIRST in every budget — you can\'t skip them, so plan for them!',
      highlightTextSk: 'Fixné výdavky prichádzajú v každom rozpočte AKO PRVÉ — nemôžeš ich preskočiť, tak s nimi počítaj!',
      accentColor: Color(0xFF4E342E),
    ),
  ],

  'variabilne_vydavky': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📊',
      title: 'Variable Expenses',
      titleSk: 'Variabilné výdavky',
      body: 'Why do we sometimes spend more and sometimes less — even when buying similar things?',
      bodySk: 'Prečo niekedy minieme viac a inokedy menej, aj keď kupujeme podobné veci?',
      accentColor: Color(0xFF00695C),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      // photo chrumko a nakupny kosik
      emoji: '🛒',
      storyTitle: 'The Changing Shopping Bill',
      storyTitleSk: 'Meniaci sa nákupný účet',
      storyBody: 'One week Chrumko goes with his parents for only basic groceries. Another week they buy extra fruit, school supplies, and a gift for grandma. That week the till total is higher. His mum explains that some expenses change depending on what\'s needed. Chrumko realises: not every month costs exactly the same.',
      storyBodySk: 'Jeden týždeň ide Chrumko s rodičmi len po základné potraviny. Iný týždeň kupujú aj ovocie navyše, školské pomôcky a darček pre babku. Ten týždeň je suma pri pokladni vyššia. Mama vysvetlí, že niektoré výdavky sa menia podľa toho, čo treba. Chrumko si uvedomí: nie každý mesiac stojí presne rovnako.',
      accentColor: Color(0xFF00695C),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🔀',
      title: 'Examples of Variable Expenses',
      titleSk: 'Príklady variabilných výdavkov',
      facts: [
        FactItem(emoji: '🛒', text: 'Food — the amount and types bought change each week', textSk: 'Jedlo — množstvo a druhy nakupovaného sa každý týždeň menia'),
        FactItem(emoji: '👕', text: 'Clothing — bought when needed, not every month', textSk: 'Oblečenie — kupuje sa podľa potreby, nie každý mesiac'),
        FactItem(emoji: '🎉', text: 'Events, outings, and gifts — vary throughout the year', textSk: 'Udalosti, výlety a darčeky — počas roka sa líšia'),
      ],
      accentColor: Color(0xFF00695C),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '📊',
      title: 'Managing Variable Expenses',
      titleSk: 'Spravovanie variabilných výdavkov',
      body: 'Always keep some flexible money in your budget for variable expenses. They\'re unpredictable — but you can expect them to show up!',
      bodySk: 'V rozpočte si vždy nechaj nejakú flexibilnú sumu na variabilné výdavky. Sú nepredvídateľné — ale môžeš očakávať, že sa objavia!',
      accentColor: Color(0xFF00695C),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '📊',
      highlightText: 'Variable expenses change — but a good budget has room for surprises!',
      highlightTextSk: 'Variabilné výdavky sa menia — ale dobrý rozpočet má priestor na prekvapenia!',
      accentColor: Color(0xFF00695C),
    ),
  ],

// ════════════════════════════════════════════
// SECTION 10 — BANKA A PENIAZE
// ════════════════════════════════════════════

  'co_robi_banka': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏦',
      title: 'What Does a Bank Do?',
      titleSk: 'Čo robí banka?',
      body: 'Where do parents\' money go when they don\'t keep it in their wallet at home?',
      bodySk: 'Kam idú peniaze rodičov, keď ich nedržia doma v peňaženke?',
      accentColor: Color(0xFF01579B),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '📱',
      storyTitle: 'The Salary Arrives',
      storyTitleSk: 'Výplata prišla',
      storyBody: 'Chrumko asks why his mum doesn\'t go to collect money in person after her salary arrives. She explains the salary came directly to the bank account. She shows him on her phone that the received amount is visible there. Chrumko realises money can be stored safely even without holding it in your hand.',
      storyBodySk: 'Chrumko sa pýta, prečo mama po výplate nejde po peniaze osobne. Mama vysvetlí, že výplata prišla priamo na bankový účet. Ukáže mu v mobile, že prijatú sumu tam vidí. Chrumko si uvedomí, že peniaze môžu byť uložené bezpečne aj bez toho, aby ich držal v ruke.',
      accentColor: Color(0xFF01579B),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🏦',
      title: 'What Banks Do',
      titleSk: 'Čo robia banky',
      facts: [
        FactItem(emoji: '🔐', text: 'Keep your money safe — more secure than cash at home', textSk: 'Uchovávajú tvoje peniaze bezpečne — bezpečnejšie než hotovosť doma'),
        FactItem(emoji: '💸', text: 'Allow you to send and receive money easily', textSk: 'Umožňujú ti ľahko posielať a prijímať peniaze'),
        FactItem(emoji: '📱', text: 'Let you manage your money via card, app, or online', textSk: 'Umožňujú spravovať peniaze cez kartu, aplikáciu alebo online'),
      ],
      accentColor: Color(0xFF01579B),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🏦',
      highlightText: 'A bank is a safe home for your money — it keeps it secure and ready whenever you need it!',
      highlightTextSk: 'Banka je bezpečný domov pre tvoje peniaze — udržuje ich v bezpečí a pripravené, kedykoľvek ich potrebuješ!',
      accentColor: Color(0xFF01579B),
    ),
  ],

  'bankovy_ucet': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📋',
      title: 'Bank Account',
      titleSk: 'Bankový účet',
      body: 'How does the bank know which money belongs to which person?',
      bodySk: 'Ako banka vie, ktoré peniaze patria komu?',
      accentColor: Color(0xFF1A237E),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      // photo chrumko a mobil
      emoji: '📱',
      storyTitle: 'Checking the Balance',
      storyTitleSk: 'Kontrola zostatku',
      storyBody: 'Chrumko sees his dad checking the account balance on his phone. On the screen is a number showing how much money is currently in the account. His dad explains that when they pay a bill or go shopping, the number gets smaller. When his salary arrives, it goes up. Chrumko understands: an account is like a display showing how much money you have.',
      storyBodySk: 'Chrumko vidí, že otec kontroluje stav účtu v mobile. Na obrazovke je číslo, ktoré ukazuje, koľko peňazí je momentálne na účte. Otec vysvetlí, že keď zaplatia účet alebo nakúpia, číslo sa zmenší. Keď príde výplata, číslo sa zvýši. Chrumko pochopí: účet je ako displej ukazujúci, koľko peňazí máš.',
      accentColor: Color(0xFF1A237E),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '💻',
      title: 'Key Facts About Accounts',
      titleSk: 'Kľúčové fakty o účtoch',
      facts: [
        FactItem(emoji: '🔢', text: 'Each account has a unique number — it identifies your account', textSk: 'Každý účet má jedinečné číslo — identifikuje tvoj účet'),
        FactItem(emoji: '📥', text: 'Money can arrive (salary, transfers) and leave (payments, withdrawals)', textSk: 'Peniaze môžu prichádzať (plat, prevody) a odchádzať (platby, výbery)'),
        FactItem(emoji: '📊', text: 'The balance shows exactly how much is currently available', textSk: 'Zostatok presne ukazuje, koľko je momentálne k dispozícii'),
      ],
      accentColor: Color(0xFF1A237E),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '📋',
      highlightText: 'A bank account is YOUR space in the bank — a safe record of your money movements!',
      highlightTextSk: 'Bankový účet je TVOJ priestor v banke — bezpečný záznam pohybov tvojich peňazí!',
      accentColor: Color(0xFF1A237E),
    ),
  ],

  'platobna_karta': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '💳',
      title: 'Payment Card',
      titleSk: 'Platobná karta',
      body: 'How can a small card replace money in a wallet?',
      bodySk: 'Ako môže malá karta nahradiť peniaze v peňaženke?',
      accentColor: Color(0xFF006064),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '🛒',
      storyTitle: 'Card at the Checkout',
      storyTitleSk: 'Karta pri pokladni',
      storyBody: 'Chrumko goes to the shop with his mum. At the checkout she doesn\'t take out cash — she uses a card. After paying, the amount appears on the terminal. His mum explains that the money was sent from the account. Chrumko realises: the card just helps you use money that\'s already stored in the bank.',
      storyBodySk: 'Chrumko ide s mamou do obchodu. Pri pokladni mama nevytiahne hotovosť, ale kartu. Po zaplatení sa suma zobrazí na termináli. Mama vysvetlí, že peniaze odišli z účtu. Chrumko si uvedomí: karta len pomáha použiť peniaze, ktoré sú uložené v banke.',
      accentColor: Color(0xFF006064),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🔗',
      title: 'How Cards Work',
      titleSk: 'Ako fungujú karty',
      facts: [
        FactItem(emoji: '🔗', text: 'A card is linked to your bank account — it\'s a tool, not the money itself', textSk: 'Karta je prepojená s tvojím bankovým účtom — je to nástroj, nie samotné peniaze'),
        FactItem(emoji: '⚡', text: 'Payment is instant — money leaves your account right away', textSk: 'Platba je okamžitá — peniaze odídu z účtu ihneď'),
        FactItem(emoji: '📍', text: 'Cards work in shops, ATMs, and for online payments', textSk: 'Karty fungujú v obchodoch, bankomatoch aj pri online platbách'),
      ],
      accentColor: Color(0xFF006064),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '💳',
      highlightText: 'A card is just the key — the money it unlocks lives in your bank account!',
      highlightTextSk: 'Karta je len kľúč — peniaze, ktoré odomyká, žijú na tvojom bankovom účte!',
      accentColor: Color(0xFF006064),
    ),
  ],

  'pin': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🔐',
      title: 'PIN Code',
      titleSk: 'PIN kód',
      body: 'Why isn\'t having the card enough — do you also need a secret number?',
      bodySk: 'Prečo nestačí mať kartu, ale treba poznať aj tajné číslo?',
      accentColor: Color(0xFF880E4F),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '🛡️',
      storyTitle: 'Why Cover the Keypad?',
      storyTitleSk: 'Prečo zakryť klávesnicu?',
      storyBody: 'Chrumko notices his mum covering the keypad with her hand when paying. He asks why. She explains she\'s entering her PIN and doesn\'t want anyone to see it. She tells him that secret information needs to be protected. If someone else knew the PIN together with the card, they could use someone else\'s money. Chrumko understands: security with money is very important.',
      storyBodySk: 'Chrumko si všimne, že mama pri platení zakrýva rukou klávesnicu. Spýta sa prečo. Mama vysvetlí, že zadáva PIN a nechce, aby ho niekto videl. Hovorí mu, že tajné údaje treba chrániť. Keby ho niekto cudzí poznal spolu s kartou, mohol by použiť cudzie peniaze. Chrumko pochopí: bezpečnosť pri peniazoch je veľmi dôležitá.',
      accentColor: Color(0xFF880E4F),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🛡️',
      title: 'PIN Safety Rules',
      titleSk: 'Pravidlá bezpečnosti PINu',
      facts: [
        FactItem(emoji: '🤫', text: 'Never share your PIN with anyone — not even friends', textSk: 'Nikdy nezdieľaj PIN s nikým — ani s kamarátmi'),
        FactItem(emoji: '🙈', text: 'Cover the keypad when entering your PIN in public', textSk: 'Zakryj klávesnicu pri zadávaní PINu na verejnosti'),
        FactItem(emoji: '🚫', text: 'Never write your PIN on the card or near it', textSk: 'Nikdy nepíš PIN na kartu alebo v jej blízkosti'),
      ],
      accentColor: Color(0xFF880E4F),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🔐',
      highlightText: 'Your PIN is a secret — NEVER share it. It\'s the lock on your money!',
      highlightTextSk: 'Tvoj PIN je tajomstvo — NIKDY ho nezdieľaj. Je to zámok na tvojich peniazoch!',
      accentColor: Color(0xFF880E4F),
    ),
  ],
  // nefunguje
  'prevod_penazi': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📲',
      title: 'Transferring Money',
      titleSk: 'Prevod peňazí',
      body: 'How does money get to someone else without a physical envelope or cash?',
      bodySk: 'Ako sa peniaze dostanú k niekomu inému bez obálky alebo hotovosti?',
      accentColor: Color(0xFF1B5E20),
    ),
    LessonSlide(
      type: LessonSlideType.story,
      emoji: '👵',
      storyTitle: 'Sending Money to Grandma',
      storyTitleSk: 'Posielanie peňazí babke',
      storyBody: 'Chrumko hears his mum is sending money to his grandma. He thinks they\'ll have to go to the post office. His mum shows him on her phone that she entered the account number and amount. After confirming, the money is sent. Chrumko realises: today money often travels digitally — fast, safe, and without leaving the house!',
      storyBodySk: 'Chrumko počuje, že mama posiela peniaze babke. Myslí si, že pôjdu na poštu. Mama mu ukáže v mobile, že zadala číslo účtu a sumu. Po potvrdení sa peniaze odošlú. Chrumko si uvedomí: dnes sa peniaze často pohybujú digitálne — rýchlo, bezpečne a bez odchodu z domu!',
      accentColor: Color(0xFF1B5E20),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🌐',
      title: 'How Bank Transfers Work',
      titleSk: 'Ako fungujú bankové prevody',
      facts: [
        FactItem(emoji: '🔢', text: 'You need the recipient\'s account number and the amount', textSk: 'Potrebuješ číslo účtu príjemcu a sumu'),
        FactItem(emoji: '⚡', text: 'Money moves electronically through the bank system', textSk: 'Peniaze sa pohybujú elektronicky cez bankový systém'),
        FactItem(emoji: '✅', text: 'No cash needed — it all happens digitally and instantly', textSk: 'Žiadna hotovosť nie je potrebná — všetko prebieha digitálne a okamžite'),
      ],
      accentColor: Color(0xFF1B5E20),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '⚠️',
      title: 'Always Double-Check',
      titleSk: 'Vždy dvakrát skontroluj',
      body: 'Before confirming a transfer, always check the account number and amount are correct. Once sent, reversing a transfer can be very difficult!',
      bodySk: 'Pred potvrdením prevodu vždy skontroluj, či je číslo účtu a suma správna. Raz odoslané peniaze je veľmi ťažké vrátiť!',
      accentColor: Color(0xFF1B5E20),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '📲',
      highlightText: 'Money can travel the world digitally in seconds — modern banking makes it fast and simple!',
      highlightTextSk: 'Peniaze môžu digitálne cestovať po svete za sekundy — moderné bankovníctvo to robí rýchlym a jednoduchým!',
      accentColor: Color(0xFF1B5E20),
    ),
  ],
};

// ─────────────────────────────────────────────
// ICON WIDGET HELPER
// ─────────────────────────────────────────────

/// Renders a [MyFlutterApp] / [ImageWidget] inside a styled circle container
/// matching the lesson accent colour. Drop this anywhere you need a standalone
/// icon display outside of a slide.
///
/// Example:
/// ```dart
/// LessonIconDisplay(
///   iconWidget: MyFlutterApp.coins,
///   accentColor: Color(0xFFF5A623),
///   size: 100,
/// )
/// ```
class LessonIconDisplay extends StatelessWidget {
  const LessonIconDisplay({
    super.key,
    required this.iconWidget,
    this.accentColor = const Color(0xFFF5A623),
    this.size = 120,
    this.iconSize = 64,
  });

  final Widget iconWidget;
  final Color accentColor;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0),
        shape: BoxShape.rectangle,
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          // ImageWidget / Icon widgets honour the SizedBox constraints
          child: FittedBox(fit: BoxFit.contain, child: iconWidget),
        ),
      ),
    );
  }
}

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
    _animController.stop();
    _animController.dispose();
    super.dispose();
  }

  void _goNext() {
    HapticFeedback.lightImpact();
    if (_currentSlide < slides.length - 1) {
      if (!mounted) return;
      _animController.reset();
      setState(() => _currentSlide++);
      _animController.forward();
    } else {
      _finishLesson();
    }
  }

  void _goPrev() {
    if (_currentSlide > 0) {
      if (!mounted) return;
      _animController.reset();
      setState(() => _currentSlide--);
      _animController.forward();
    }
  }

  void _finishLesson() {
    if (!mounted) return;
    
    // Stop animation to prevent issues during navigation
    _animController.stop();
    
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
      // Show snackbar after navigation pop completes
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isSk ? 'Lekcia dokončená! 🎉' : 'Lesson complete! 🎉'),
            ),
          );
        }
      });
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
        LessonSlideType.intro     => _buildIntroSlide(slide, accent),
        LessonSlideType.info      => _buildInfoSlide(slide, accent),
        LessonSlideType.facts     => _buildFactsSlide(slide, accent),
        LessonSlideType.highlight => _buildHighlightSlide(slide, accent),
        LessonSlideType.tip       => _buildTipSlide(slide, accent),
        LessonSlideType.story     => _buildStorySlide(slide, accent),
        LessonSlideType.icon      => _buildIconSlide(slide, accent),
      },
    );
  }

  // ── ICON AVATAR HELPER ────────────────────────
  // Shared between intro, story and the new icon slide.
  // Prefers iconWidget over emoji when both are supplied.
  // slide.iconSize overrides the caller's default iconSize when set.

  Widget _buildAvatarWidget({
    required LessonSlide slide,
    required Color accent,
    double containerSize = 120,
    double iconSize = 72,
    double emojiSize = 64,
  }) {
    // Per-slide overrides take priority over the builder's defaults.
    final effectiveIconSize      = slide.iconSize          ?? iconSize;
    final effectiveContainerSize = slide.iconContainerSize ?? containerSize;

    if (slide.iconWidget != null) {
      return LessonIconDisplay(
        iconWidget: slide.iconWidget!,
        accentColor: accent,
        size: effectiveContainerSize,
        iconSize: effectiveIconSize,
      );
    }
    return Container(
      width: effectiveContainerSize,
      height: effectiveContainerSize,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          slide.emoji ?? '📖',
          style: TextStyle(fontSize: emojiSize),
        ),
      ),
    );
  }

  // ── SLIDE TYPES ──────────────────────────────

  Widget _buildIntroSlide(LessonSlide s, Color accent) {
    final title = _isSk ? (s.titleSk ?? s.title!) : s.title!;
    final body  = _isSk ? (s.bodySk  ?? s.body!)  : s.body!;
    return Column(
      children: [
        const SizedBox(height: 24),
        _buildAvatarWidget(slide: s, accent: accent),
        const SizedBox(height: 28),
        Text(
          title,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Text(
            body,
            style: const TextStyle(fontSize: 16, height: 1.55, color: Color(0xFF333333)),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoSlide(LessonSlide s, Color accent) {
    final title = _isSk ? (s.titleSk ?? s.title!) : s.title!;
    final body  = _isSk ? (s.bodySk  ?? s.body!)  : s.body!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Text(s.emoji ?? '📖', style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
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
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Text(
            body,
            style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF333333)),
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
              child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
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
              child: Transform.translate(offset: Offset(20 * (1 - val), 0), child: child),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  // Per-item: prefer iconWidget over emoji
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: fact.iconWidget != null
                          ? SizedBox(
                              width: 28,
                              height: 28,
                              child: FittedBox(fit: BoxFit.contain, child: fact.iconWidget),
                            )
                          : Text(fact.emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 14, height: 1.45, color: Color(0xFF333333)),
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
    final text = _isSk ? (s.highlightTextSk ?? s.highlightText!) : s.highlightText!;
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
              BoxShadow(color: accent.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTipSlide(LessonSlide s, Color accent) {
    final title = _isSk ? (s.titleSk ?? s.title!) : s.title!;
    final body  = _isSk ? (s.bodySk  ?? s.body!)  : s.body!;
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(s.emoji ?? '💡', style: const TextStyle(fontSize: 64)),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
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
    final body  = _isSk ? (s.storyBodySk  ?? s.storyBody!)  : s.storyBody!;
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildAvatarWidget(slide: s, accent: accent, containerSize: 80, iconSize: 52, emojiSize: 48),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.2),
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
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
            ],
          ),
          child: Text(
            body,
            style: const TextStyle(fontSize: 15, height: 1.65, color: Color(0xFF444444)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// New slide type: full-page icon showcase with title + body text below.
  /// Created via [LessonSlide.icon()] factory or by setting
  /// [type: LessonSlideType.icon] manually.
  Widget _buildIconSlide(LessonSlide s, Color accent) {
    final title = _isSk ? (s.titleSk ?? s.title ?? '') : (s.title ?? '');
    final body  = _isSk ? (s.bodySk  ?? s.body  ?? '') : (s.body  ?? '');
    return Column(
      children: [
        const SizedBox(height: 32),
        _buildAvatarWidget(slide: s, accent: accent, containerSize: 140, iconSize: 88, emojiSize: 72),
        const SizedBox(height: 28),
        if (title.isNotEmpty)
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2),
            textAlign: TextAlign.center,
          ),
        if (title.isNotEmpty) const SizedBox(height: 16),
        if (body.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withOpacity(0.25), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
              ],
            ),
            child: Text(
              body,
              style: const TextStyle(fontSize: 15, height: 1.65, color: Color(0xFF444444)),
              textAlign: TextAlign.center,
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
                    BoxShadow(color: accent.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: Text(
                    isLast
                        ? (widget.lesson.quizLessonId != null
                            ? (_isSk ? '🎯 Spustiť kvíz' : '🎯 Start Quiz')
                            : (_isSk ? '✅ Dokončiť'     : '✅ Finish'))
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