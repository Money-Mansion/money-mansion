import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

enum LessonSlideType { intro, info, facts, highlight, tip }

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
      bodySk: 'Chrumko chce novú plyšovú hračku, ktorú vidí v obchode. Potom si uvedomí, že doma už jednu podobnú má. Vlastne ju nepotrebuje — je to len túžba. A to je úplne v poriadku, pokiaľ vieme rozdiel!',
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
  // SECTION 3 — PRVÉ HOSPODÁRENIE S PENIAZMI
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
        FactItem(emoji: '🛒', text: '50% — Needs: things you actually have to buy', textSk: '50% — Potreby: veci, ktoré naozaj musíš kúpiť'),
        FactItem(emoji: '🎮', text: '30% — Wants: fun stuff you enjoy', textSk: '30% — Túžby: zábavné veci, ktoré si užívaš'),
        FactItem(emoji: '🏦', text: '20% — Savings: save for bigger goals!', textSk: '20% — Sporenie: šetri na väčšie ciele!'),
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
      emoji: '🍕',
      title: 'How to Split Your Money',
      titleSk: 'Ako si rozdeliť peniaze',
      body: 'Is it good to spend everything at once?',
      bodySk: 'Je dobré minúť všetko naraz?',
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🍕',
      title: 'Chrumko Goes for Pizza',
      titleSk: 'Chrumko ide na pizzu',
      body: 'Chrumko gets €10 and thinks about buying a big toy. But then he\'d have nothing left. He saves €7 in his piggy bank and spends the rest on something he needs for school. Days later, friends invite him for pizza — and he\'s glad he saved!',
      bodySk: 'Chrumko dostane 10 eur a chce si kúpiť väčšiu hračku. Ale potom by mu nič nezostalo. Odloží si 7 eur do pokladničky a za zvyšné kúpi vec do školy. O pár dní kamaráti pozývajú na pizzu — a on je rád, že šetril!',
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '✂️',
      highlightText: 'Split your money into parts: some to spend NOW, some to save for LATER!',
      highlightTextSk: 'Rozdeľ si peniaze na časti: niečo miniť TERAZ, niečo ušetriť na NESKÔR!',
      accentColor: Color(0xFF9C27B0),
    ),
  ],

  'minut_teraz_vs_neskor': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '⏰',
      title: 'Spend Now vs Spend Later',
      titleSk: 'Minúť teraz vs neskôr',
      body: 'What\'s better: a small thing today or a bigger thing in a few days?',
      bodySk: 'Čo je lepšie: malá vec dnes alebo väčšia vec o pár dní?',
      accentColor: Color(0xFF009688),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🎨',
      title: 'Chrumko and the Colouring Book',
      titleSk: 'Chrumko a omaľovánka',
      body: 'Chrumko has €2 and sees his favourite lollipop. He\'d eat it in minutes. But he remembers a colouring book he liked last week — it costs more. He decides to save up, and a few days later buys the book. He enjoys it for much longer than a lollipop!',
      bodySk: 'Chrumko má 2 eurá a vidí svoju obľúbenú lízanku. Zjedol by ju za pár minút. Ale pamätá si omaľovánku z minulého týždňa — stojí viac. Rozhodne sa šetriť a o pár dní kúpi knihu. Baví ho oveľa dlhšie ako lízanka!',
      accentColor: Color(0xFF009688),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🎯',
      highlightText: 'Patience pays off — waiting for a better thing is a superpower!',
      highlightTextSk: 'Trpezlivosť sa vypláca — čakanie na lepšiu vec je superschopnosť!',
      accentColor: Color(0xFF009688),
    ),
  ],

  'preco_sa_oplati_planovat': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📅',
      title: 'Why Planning Pays Off',
      titleSk: 'Prečo sa oplatí plánovať',
      body: 'Why is it good to know in advance what you\'ll use your money for?',
      bodySk: 'Prečo je dobré vedieť dopredu, na čo peniaze použijem?',
      accentColor: Color(0xFF3F51B5),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🍦',
      title: 'Chrumko Plans His Weekend',
      titleSk: 'Chrumko plánuje víkend',
      body: 'Chrumko wants to get ice cream with friends Saturday, AND buy sunglasses. He gets pocket money Wednesday and sees a toy. He thinks: if I buy it now, I won\'t have enough for ice cream or sunglasses. He saves the money!',
      bodySk: 'Chrumko chce v sobotu ísť s kamarátmi na zmrzlinu A kúpiť si slnečné okuliare. V stredu dostane vreckové a uvidí hračku. Myslí: ak to kúpim teraz, nebude mi stačiť na zmrzlinu ani okuliare. Peniaze si nechá!',
      accentColor: Color(0xFF3F51B5),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '✏️',
      title: 'Planning Steps',
      titleSk: 'Kroky plánovania',
      facts: [
        FactItem(emoji: '🎯', text: 'Know your goals — what do you want to buy?', textSk: 'Poznaj svoje ciele — čo si chceš kúpiť?'),
        FactItem(emoji: '💰', text: 'Know your budget — how much do you have?', textSk: 'Poznaj svoj rozpočet — koľko máš?'),
        FactItem(emoji: '⚖️', text: 'Prioritise — what\'s most important?', textSk: 'Prioritizuj — čo je najdôležitejšie?'),
        FactItem(emoji: '⏳', text: 'Be patient — good things take time to save for!', textSk: 'Buď trpezlivý — na dobré veci treba čas šetriť!'),
      ],
      accentColor: Color(0xFF3F51B5),
    ),
  ],

  'male_financne_chyby': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🤦',
      title: 'Small Financial Mistakes',
      titleSk: 'Malé finančné chyby',
      body: 'Can a mistake also be a good experience?',
      bodySk: 'Môže byť chyba aj dobrou skúsenosťou?',
      accentColor: Color(0xFFFF5722),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🔦',
      title: 'Chrumko\'s Blinking Toy',
      titleSk: 'Chrumkova blikajúca hračka',
      body: 'Chrumko buys a blinking toy that looks amazing in the shop. At home he plays with it for a short while, then puts it away and never touches it again. A few days later he realises he would have preferred something he\'d use longer!',
      bodySk: 'Chrumko si kúpi blikajúcu hračku, ktorá vyzerá v obchode úžasne. Doma sa s ňou chvíľu hrá, potom ju odloží a k nej sa nevráti. O pár dní si uvedomí, že by radšej kúpil niečo, čo by využíval dlhšie!',
      accentColor: Color(0xFFFF5722),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '💪',
      highlightText: 'Everyone makes money mistakes — what matters is LEARNING from them!',
      highlightTextSk: 'Každý robí finančné chyby — dôležité je sa z nich UČIŤ!',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '📝',
      title: 'After a Mistake, Ask:',
      titleSk: 'Po chybe sa spýtaj:',
      body: 'Why did I decide that way? What would I do differently? Even small experiences help you understand money better.',
      bodySk: 'Prečo som sa tak rozhodol? Čo by som urobil inak? Aj malé skúsenosti pomáhajú lepšie rozumieť peniazom.',
      accentColor: Color(0xFFFF5722),
    ),
  ],

  // ════════════════════════════════════════════
  // SECTION 4 — SPORENIE
  // ════════════════════════════════════════════

  'co_je_sporenie': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏦',
      title: 'What is Saving?',
      titleSk: 'Čo je sporenie?',
      body: 'What\'s better to do with money than spend it right away?',
      bodySk: 'Čo lepšie môžeme spraviť s peniazmi ako ich hneď minúť?',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🐷',
      title: 'Chrumko\'s Piggy Bank',
      titleSk: 'Chrumkova pokladnička',
      body: 'Chrumko gets small coins every week. He puts one coin into his piggy bank each time. At first it seems slow. After a few weeks the box is much heavier — and he can buy something more expensive! He keeps saving in case something breaks and he needs to replace it.',
      bodySk: 'Chrumko dostáva každý týždeň drobné mince. Vždy vloží jednu mincu do pokladničky. Spočiatku sa zdá, že je to pomalé. Po niekoľkých týždňoch je pokladnička oveľa ťažšia — a môže si kúpiť niečo drahšie! Bude šetriť ďalej, pre prípad, že by sa niečo pokazilo.',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🎯',
      title: 'Why Save?',
      titleSk: 'Prečo šetriť?',
      facts: [
        FactItem(emoji: '🛡️', text: 'Emergency fund — handles unexpected costs', textSk: 'Pohotovostný fond — pokrýva nečakané výdavky'),
        FactItem(emoji: '🎁', text: 'Reach bigger goals — things you can\'t buy in one go', textSk: 'Dosiahni väčšie ciele — veci, ktoré nekúpiš naraz'),
        FactItem(emoji: '😌', text: 'Peace of mind — less financial stress', textSk: 'Pokoj v duši — menej finančného stresu'),
      ],
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '⚡',
      highlightText: 'Even saving just €1 a day = €365 a year!',
      highlightTextSk: 'Aj sporenie len 1 € denne = 365 € za rok!',
      accentColor: Color(0xFFF5A623),
    ),
  ],

  'preco_si_odkladat': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📚',
      title: 'Why Set Money Aside?',
      titleSk: 'Prečo si odkladať peniaze?',
      body: 'Why shouldn\'t you always spend all your money?',
      bodySk: 'Prečo vždy netreba minúť všetky peniaze?',
      accentColor: Color(0xFF2196F3),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '📖',
      title: 'Chrumko and the Book',
      titleSk: 'Chrumko a kniha',
      body: 'Chrumko sees a book in a bookshop that he really likes. But it costs more than his weekly pocket money. If he\'d spent everything immediately, he\'d have to wait a very long time. Because he always saves part of his money, he has enough to buy it!',
      bodySk: 'Chrumko si v kníhkupectve všimne knihu, ktorá sa mu veľmi páči. Stojí viac ako jeho vreckové. Keby minul všetko hneď, musel by čakať veľmi dlho. Keďže si vždy časť odkladá, má dosť peňazí na jej kúpu!',
      accentColor: Color(0xFF2196F3),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🔓',
      highlightText: 'Saved money = freedom to buy bigger things when you\'re ready!',
      highlightTextSk: 'Ušetrené peniaze = sloboda kúpiť väčšie veci, keď budeš pripravený!',
      accentColor: Color(0xFF2196F3),
    ),
  ],

  'kratkodoby_vs_dlhodoby': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🎯',
      title: 'Short-term vs Long-term Goals',
      titleSk: 'Krátkodobý vs dlhodobý cieľ',
      body: 'What can you save for quickly, and what takes more time?',
      bodySk: 'Na čo si vieš našetriť rýchlo a na čo treba viac času?',
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🧱',
      title: 'Chrumko Has Two Goals',
      titleSk: 'Chrumko má dva ciele',
      body: 'Chrumko wants stickers (cheap — he can save for them in one week) AND a big LEGO set (expensive — that\'ll take many weeks). He decides to save for both goals at the same time!',
      bodySk: 'Chrumko chce nálepky (lacné — môže si na ne našetriť za jeden týždeň) A veľkú stavebnicu (drahé — na to bude treba veľa týždňov). Rozhodne sa šetriť na oba ciele súčasne!',
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📊',
      title: 'Two Types of Goals',
      titleSk: 'Dva typy cieľov',
      facts: [
        FactItem(emoji: '⚡', text: 'Short-term goal — achieved in days or weeks', textSk: 'Krátkodobý cieľ — dosiahnutý za dni alebo týždne'),
        FactItem(emoji: '🏆', text: 'Long-term goal — takes weeks or months of patience', textSk: 'Dlhodobý cieľ — trvá týždne alebo mesiace trpezlivosti'),
        FactItem(emoji: '✅', text: 'Both goals are worth having at the same time!', textSk: 'Oba ciele sa oplatí mať súčasne!'),
      ],
      accentColor: Color(0xFF9C27B0),
    ),
  ],

  'ako_si_vytvorit_rezervu': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🛡️',
      title: 'Building a Reserve',
      titleSk: 'Ako si vytvoriť rezervu',
      body: 'Is it good to have saved money even without a specific plan?',
      bodySk: 'Je dobré mať odložené peniaze aj bez konkrétneho plánu?',
      accentColor: Color(0xFFFF5722),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '📝',
      title: 'Chrumko\'s Envelope',
      titleSk: 'Chrumkova obálka',
      body: 'Chrumko keeps some money in a small envelope, refusing to spend it right away. A few days later, he learns he needs materials for a school project. Because he had a reserve, he doesn\'t need to worry about where to find the money!',
      bodySk: 'Chrumko si nechá časť peňazí v malej obálke a nechce ich hneď minúť. O pár dní zistí, že potrebuje materiál na školský projekt. Vďaka rezerve sa nemusí trápiť, odkiaľ peniaze zobrať!',
      accentColor: Color(0xFFFF5722),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🌈',
      highlightText: 'A reserve isn\'t for a specific thing — it\'s for when LIFE SURPRISES YOU!',
      highlightTextSk: 'Rezerva nie je na konkrétnu vec — je na to, keď ŤA PREKVAPÍ ŽIVOT!',
      accentColor: Color(0xFFFF5722),
    ),
  ],

  'pravidelne_male_sumy': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🪙',
      title: 'Regular Small Amounts',
      titleSk: 'Pravidelné malé sumy',
      body: 'Can small coins grow into a bigger amount over time?',
      bodySk: 'Môžu malé mince časom narásť na väčšiu sumu?',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '📈',
      title: 'Chrumko\'s 50 Cents',
      titleSk: 'Chrumkových 50 centov',
      body: 'Chrumko saves 50 cents every week. At first it seems very little. After several weeks he finds he has several euros — enough to buy something that a single coin could never buy!',
      bodySk: 'Chrumko si každý týždeň odloží 50 centov. Spočiatku sa mu zdá, že je to veľmi málo. Po niekoľkých týždňoch zistí, že má niekoľko eur — dosť na kúpu niečoho, na čo by jedna minca nikdy nestačila!',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🌱',
      highlightText: 'Small + Regular + Time = BIG savings. Start small, start today!',
      highlightTextSk: 'Malé + Pravidelné + Čas = VEĽKÉ úspory. Začni s malým, začni dnes!',
      accentColor: Color(0xFF4CAF50),
    ),
  ],

  // ════════════════════════════════════════════
  // SECTION 5 — CENA A HODNOTA
  // ════════════════════════════════════════════

  'cena_vs_kvalita': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🛍️',
      title: 'Price vs Quality',
      titleSk: 'Cena vs kvalita',
      body: 'Is an expensive thing always better? Or do we sometimes pay for something other than the product itself?',
      bodySk: 'Je drahšia vec vždy lepšia, alebo niekedy platíme aj za niečo iné než samotný výrobok?',
      accentColor: Color(0xFF795548),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '✏️',
      title: 'Chrumko Picks a Pencil',
      titleSk: 'Chrumko si vyberá ceruzku',
      body: 'Chrumko chooses a new pencil. One has a colourful package and a famous brand — it costs more. Next to it is a simpler one, cheaper. He tries both on paper. They write equally well! The assistant explains: the expensive one costs more partly because of its brand name.',
      bodySk: 'Chrumko si vyberá novú ceruzku. Jedna má farebný obal a známu značku — stojí viac. Vedľa je jednoduchšia, lacnejšia. Obidve vyskúša na papieri. Píšu rovnako dobre! Predavačka vysvetlí: drahšia stojí viac aj kvôli známemu menu značky.',
      accentColor: Color(0xFF795548),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🧪',
      highlightText: 'Higher price doesn\'t always mean better quality — always TEST before you buy!',
      highlightTextSk: 'Vyššia cena neznamená vždy lepšiu kvalitu — vždy SKÚŠAJ pred kúpou!',
      accentColor: Color(0xFF795548),
    ),
  ],

  'lacne_vs_drahe': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🔄',
      title: 'Cheap vs Expensive',
      titleSk: 'Lacné vs drahé',
      body: 'Why can two similar things cost completely different amounts?',
      bodySk: 'Prečo môžu dve podobné veci stáť úplne rozdielne peniaze?',
      accentColor: Color(0xFFE91E63),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '📓',
      title: 'Chrumko Needs a Notebook',
      titleSk: 'Chrumko potrebuje zošit',
      body: 'Chrumko needs a new notebook. In one shop: a nice cover, higher price. In another shop: a similar notebook, cheaper — same number of pages, works the same. The only difference is the cover and brand. He buys the cheaper one and has money left for other school supplies!',
      bodySk: 'Chrumko potrebuje nový zošit. V prvom obchode: pekný obal, vyššia cena. V druhom obchode: podobný zošit, lacnejší — rovnaký počet strán, rovnako použiteľný. Rozdiel je len v obale a značke. Kúpi lacnejší a zostanú mu peniaze na iné školské potreby!',
      accentColor: Color(0xFFE91E63),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📋',
      title: 'What Affects Price',
      titleSk: 'Čo ovplyvňuje cenu',
      facts: [
        FactItem(emoji: '🏭', text: 'Materials and production quality', textSk: 'Materiál a kvalita výroby'),
        FactItem(emoji: '🏷️', text: 'Brand name (you pay for recognition)', textSk: 'Značka (platíš za známosť)'),
        FactItem(emoji: '🏪', text: 'Where it\'s sold (different shops, different prices)', textSk: 'Kde sa predáva (rôzne obchody, rôzne ceny)'),
      ],
      accentColor: Color(0xFFE91E63),
    ),
  ],

  'vyhodna_kupa': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏆',
      title: 'What Is a Good Deal?',
      titleSk: 'Čo znamená výhodná kúpa',
      body: 'When can we say a purchase was truly good?',
      bodySk: 'Kedy sa dá povedať, že kúpa bola naozaj dobrá?',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '💧',
      title: 'Chrumko\'s Water Bottle',
      titleSk: 'Chrumkova fľaša na vodu',
      body: 'Chrumko wants a new water bottle for school. There\'s a very cheap thin plastic bottle. Next to it is a sturdier bottle that costs more. He picks the sturdy one. Weeks later he\'s glad — it hasn\'t broken and still works perfectly every day!',
      bodySk: 'Chrumko chce novú fľašu na vodu do školy. Je tu veľmi lacná tenká plastová fľaša. Vedľa nej je pevnejšia fľaša, ktorá stojí viac. Vyberie pevnejšiu. O týždne je rád — nepoškodila sa a každý deň slúži perfektne!',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '💡',
      highlightText: 'A good deal = good quality + fair price + long lasting use!',
      highlightTextSk: 'Výhodná kúpa = dobrá kvalita + fér cena + dlhé používanie!',
      accentColor: Color(0xFF4CAF50),
    ),
  ],

  'porovnavanie_cien': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🔍',
      title: 'Comparing Prices',
      titleSk: 'Porovnávanie cien',
      body: 'Can the same thing cost less just because we look a little longer?',
      bodySk: 'Môže rovnaká vec stáť menej len preto, že ju hľadáme o chvíľu dlhšie?',
      accentColor: Color(0xFF2196F3),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🖍️',
      title: 'Chrumko Hunts for Crayons',
      titleSk: 'Chrumko hľadá pastelky',
      body: 'Chrumko wants crayons. In the first shop he finds a set he likes. Later in another shop he sees the exact same crayons — cheaper! He compares the packaging and contents: same product. He buys the better-priced ones and has money left for more supplies!',
      bodySk: 'Chrumko chce pastelky. V prvom obchode nájde sadu, ktorá sa mu páči. Neskôr v inom obchode vidí úplne rovnaké pastelky — lacnejšie! Porovná obaly a obsah: rovnaký výrobok. Kúpi lacnejšie a zostanú mu peniaze na ďalšie školské potreby!',
      accentColor: Color(0xFF2196F3),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🔄',
      highlightText: 'Always compare before you buy — a few minutes can save a lot of money!',
      highlightTextSk: 'Vždy porovnávaj pred kúpou — pár minút môže ušetriť veľa peňazí!',
      accentColor: Color(0xFF2196F3),
    ),
  ],

  'jednotkova_cena': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📐',
      title: 'Unit Price',
      titleSk: 'Jednotková cena',
      body: 'Is a bigger package always more expensive, or can it actually work out cheaper?',
      bodySk: 'Je väčšie balenie vždy drahšie, alebo môže v skutočnosti vyjsť výhodnejšie?',
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '💧',
      title: 'Chrumko Buys Water',
      titleSk: 'Chrumko kupuje vodu',
      body: 'Chrumko wants water before a journey. He sees two small bottles and one large one. At first he thinks two small ones would be better since each one costs less. But then he notices: together the two small ones cost MORE than the one large one! Mum shows him there\'s more water in the big bottle for a better price.',
      bodySk: 'Chrumko chce vodu pred cestou. Vidí dve malé fľaše a jednu veľkú. Najprv si myslí, že dve malé budú lepšie, keďže každá stojí menej. Ale potom si všimne: dve malé spolu stoja VIAC ako jedna veľká! Mama mu ukáže, že vo veľkej fľaši je viac vody za lepšiu cenu.',
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🧮',
      highlightText: 'Unit price = how much does ONE unit cost? Always compare per gram or litre!',
      highlightTextSk: 'Jednotková cena = koľko stojí JEDNA jednotka? Vždy porovnávaj na gram alebo liter!',
      accentColor: Color(0xFF9C27B0),
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
      body: 'What actually happens in a shop?',
      bodySk: 'Čo sa v skutočnosti deje v obchode?',
      accentColor: Color(0xFF009688),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🧺',
      title: 'Chrumko Goes Shopping',
      titleSk: 'Chrumko ide nakupovať',
      body: 'Chrumko goes to the shop with mum. He picks up a bread roll, apples and yoghurt. Mum shows him the price tag on the shelf. At the till the cashier scans everything and the total appears on the screen — each item added up!',
      bodySk: 'Chrumko ide do obchodu s mamou. Vyberie rožok, jablká a jogurt. Mama mu ukáže cenovku pri regáli. Pri pokladni predavačka naskenuje všetko a na displeji sa objaví celková suma — každá vec sa pripočíta!',
      accentColor: Color(0xFF009688),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🏬',
      title: 'What\'s Inside a Shop\'s Price',
      titleSk: 'Čo je v cene výrobku',
      facts: [
        FactItem(emoji: '🏭', text: 'Cost of making the product', textSk: 'Náklady na výrobu produktu'),
        FactItem(emoji: '🚚', text: 'Delivery and storage costs', textSk: 'Náklady na dopravu a skladovanie'),
        FactItem(emoji: '👨‍💼', text: 'Wages for shop workers', textSk: 'Mzdy pre pracovníkov obchodu'),
        FactItem(emoji: '💡', text: 'Running costs (electricity, rent)', textSk: 'Prevádzkové náklady (elektrina, nájom)'),
      ],
      accentColor: Color(0xFF009688),
    ),
  ],

  'zlavy': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏷️',
      title: 'Discounts',
      titleSk: 'Zľavy',
      body: 'If something is cheaper, does that automatically mean you should buy it?',
      bodySk: 'Ak je niečo lacnejšie, znamená to automaticky, že sa to oplatí kúpiť?',
      accentColor: Color(0xFFE91E63),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🍫',
      title: 'Chrumko Spots a Sale',
      titleSk: 'Chrumko vidí výpredaj',
      body: 'Chrumko goes to the shop for just a snack. He spots a big red SALE sign on chocolate. It\'s cheaper than usual — very tempting! But he realises he didn\'t plan to buy chocolate and already has sweets at home. He saves his money for something he\'ll actually need later.',
      bodySk: 'Chrumko ide do obchodu len po desiatu. Uvidí veľký červený nápis ZĽAVA na čokoláde. Je lacnejšia ako zvyčajne — veľmi lákavé! Ale uvedomí si, že neplánoval kúpiť čokoládu a doma má ešte sladkosti. Peniaze si nechá na niečo, čo naozaj bude potrebovať neskôr.',
      accentColor: Color(0xFFE91E63),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🤔',
      highlightText: 'Would you buy it WITHOUT the discount? If not — it\'s not really a good deal!',
      highlightTextSk: 'Kúpil by si to BEZ zľavy? Ak nie — to nie je naozaj výhodná kúpa!',
      accentColor: Color(0xFFE91E63),
    ),
  ],

  'marketingove_triky': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🎪',
      title: 'Sales & Marketing Tricks',
      titleSk: 'Akcie a marketingové triky',
      body: 'Why do some signs in shops catch our attention immediately?',
      bodySk: 'Prečo niektoré nápisy v obchode vyzerajú tak, že si ich všimneme hneď medzi prvými?',
      accentColor: Color(0xFF7C5CBF),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🟡',
      title: 'Chrumko and the Yellow Sign',
      titleSk: 'Chrumko a žltý nápis',
      body: 'Chrumko notices a large yellow sign: "BEST VALUE DEAL!" The product is on a visible spot right at the entrance. He thinks it must be a huge saving. But looking at a similar product nearby, the price difference is tiny. Big sign ≠ best price!',
      bodySk: 'Chrumko si všimne veľký žltý nápis: „VÝHODNÉ BALENIE ZA NAJLEPŠIU CENU!" Výrobok je na viditeľnom mieste hneď pri vstupe. Myslí, že musí ísť o obrovskú úsporu. Ale pri podobnom výrobku vedľa je rozdiel v cene veľmi malý. Veľký nápis ≠ najlepšia cena!',
      accentColor: Color(0xFF7C5CBF),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🎭',
      title: 'Marketing Tricks to Watch',
      titleSk: 'Marketingové triky, na ktoré si dávaj pozor',
      facts: [
        FactItem(emoji: '🟡', text: 'Bright colours and big signs draw attention', textSk: 'Jasné farby a veľké nápisy priťahujú pozornosť'),
        FactItem(emoji: '⏰', text: '"Only today!" creates urgency to buy fast', textSk: '„Len dnes!" vytvára naliehavosť kúpiť rýchlo'),
        FactItem(emoji: '🏪', text: 'Best-looking spots in the shop for promoted items', textSk: 'Najlepšie miesta v obchode pre propagované výrobky'),
      ],
      accentColor: Color(0xFF7C5CBF),
    ),
  ],

  'impulzivne_nakupy': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '⚡',
      title: 'Impulse Purchases',
      titleSk: 'Impulzívne nákupy',
      body: 'Why do we sometimes want to buy something the instant we see it?',
      bodySk: 'Prečo máme niekedy chuť kúpiť si niečo hneď, keď to uvidíme?',
      accentColor: Color(0xFFFF5722),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🍬',
      title: 'Chrumko at the Checkout',
      titleSk: 'Chrumko pri pokladni',
      body: 'Chrumko is at the checkout with mum. While waiting in line, he sees colourful chewing gum right next to the till — placed exactly where everyone notices it. He wants some instantly! But he remembers he has sweets from yesterday at home. The craving passes quickly.',
      bodySk: 'Chrumko je s mamou pri pokladni. Kým čakajú v rade, uvidí pri kase farebné žuvačky — položené presne tam, kde si ich každý všimne. Hneď ich chce! Ale pamätá si, že doma má ešte sladkosti z včera. Chuť rýchlo prechádza.',
      accentColor: Color(0xFFFF5722),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '🛑',
      title: 'Stop and Ask Yourself',
      titleSk: 'Zastav sa a opýtaj sa sám seba',
      body: 'When you feel the urge to grab something quickly: Did I plan to buy this? Do I actually need it? Will I regret not buying it tomorrow? Pausing for 10 seconds can save a lot of money!',
      bodySk: 'Keď cítiš nutkanie rýchlo niečo chytiť: Plánoval som si toto kúpiť? Naozaj to potrebujem? Budem ľutovať, že som to nekúpil zajtra? Pauza na 10 sekúnd môže ušetriť veľa peňazí!',
      accentColor: Color(0xFFFF5722),
    ),
  ],

  'ako_nenaletiet_na_reklamu': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🕵️',
      title: 'How to Think for Yourself',
      titleSk: 'Ako sa rozhodovať vlastnou hlavou',
      body: 'How to know if we want something because we need it, or just because it caught our attention?',
      bodySk: 'Ako zistiť, či niečo chceme preto, že to potrebujeme, alebo preto, že to práve upútalo našu pozornosť?',
      accentColor: Color(0xFF3F51B5),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🖊️',
      title: 'Chrumko and the Fancy Pen',
      titleSk: 'Chrumko a módne pero',
      body: 'Chrumko goes to buy a notebook. He sees a very colourful pen with his favourite character. He almost throws it into the basket! But he remembers he has two working pens at home. He stops and thinks. He buys only the notebook. Days later he\'s glad — he spent money only on what he actually needed.',
      bodySk: 'Chrumko ide kúpiť zošit. Vidí veľmi farebné pero s obľúbenou postavičkou. Takmer ho hodí do košíka! Ale pamätá si, že doma má dve funkčné perá. Zastaví sa a premýšľa. Kúpi len zošit. O dni neskôr je rád — minul peniaze len na to, čo skutočne potreboval.',
      accentColor: Color(0xFF3F51B5),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '✅',
      title: '3 Questions Before Buying',
      titleSk: '3 otázky pred kúpou',
      facts: [
        FactItem(emoji: '❓', text: 'Do I need this?', textSk: 'Potrebujem to?'),
        FactItem(emoji: '🔄', text: 'Will I use it for a long time?', textSk: 'Budem to používať dlhšie?'),
        FactItem(emoji: '💰', text: 'Is it worth spending my money on?', textSk: 'Oplatí sa mi za to minúť peniaze?'),
      ],
      accentColor: Color(0xFF3F51B5),
    ),
  ],

  // ════════════════════════════════════════════
  // SECTION 7 — PENIAZE V RODINE
  // ════════════════════════════════════════════

  'odkial_rodina_berie_peniaze': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '👨‍👩‍👧',
      title: 'Where Does the Family Get Money?',
      titleSk: 'Odkiaľ rodina berie peniaze?',
      body: 'How does money get into the family when nobody makes it at home?',
      bodySk: 'Ako sa peniaze dostanú do rodiny, keď ich doma nikto nevyrába?',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '📱',
      title: 'Mum Gets Her Salary',
      titleSk: 'Mama dostáva výplatu',
      body: 'Chrumko notices mum looking at a bank notification on her phone. He asks what came in. Mum explains she received her work salary. She shows him how this money is gradually used to pay rent, buy groceries, and some is saved for later.',
      bodySk: 'Chrumko si všimne, že mama pozerá na bankové oznámenie v telefóne. Spýta sa, čo prišlo. Mama vysvetlí, že dostala pracovnú výplatu. Ukáže mu, ako sa z týchto peňazí postupne platí nájom, nakupujú potraviny a niečo sa odloží na neskôr.',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🔑',
      highlightText: 'Family money comes from WORK — every euro in the home was earned through effort!',
      highlightTextSk: 'Rodinné peniaze pochádzajú z PRÁCE — každé euro doma bolo zarobené úsilím!',
      accentColor: Color(0xFF4CAF50),
    ),
  ],

  'vydavky_domacnosti': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏠',
      title: 'Household Expenses',
      titleSk: 'Výdavky domácnosti',
      body: 'Where does money go when the family isn\'t buying anything big?',
      bodySk: 'Kam miznú peniaze, keď rodina nič veľké nekupuje?',
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🌸',
      title: 'No Money for a Plant Pot',
      titleSk: 'Žiadne peniaze na kvetináč',
      body: 'Chrumko wonders why the family didn\'t buy a plant pot they liked. Dad shows him that this week they already paid for internet, water, and school lunch. Even though none of these are big things individually, together they add up to a lot!',
      bodySk: 'Chrumko sa čuduje, prečo rodina nekúpila kvetináč, ktorý sa im páčil. Otec mu ukáže, že tento týždeň už platili účet za internet, vodu a školský obed. Aj keď žiadna z týchto vecí sama o sebe nie je veľká, spolu tvoria väčšiu sumu!',
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📋',
      title: 'Common Household Expenses',
      titleSk: 'Bežné výdavky domácnosti',
      facts: [
        FactItem(emoji: '🏠', text: 'Housing (rent or mortgage)', textSk: 'Bývanie (nájom alebo hypotéka)'),
        FactItem(emoji: '🍞', text: 'Food and groceries', textSk: 'Jedlo a potraviny'),
        FactItem(emoji: '💡', text: 'Electricity, water, heating', textSk: 'Elektrina, voda, kúrenie'),
        FactItem(emoji: '🌐', text: 'Internet and phone', textSk: 'Internet a telefón'),
        FactItem(emoji: '🎓', text: 'School and education costs', textSk: 'Školské a vzdelávacie náklady'),
      ],
      accentColor: Color(0xFF9C27B0),
    ),
  ],

  'byvanie_stoji_peniaze': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏘️',
      title: 'Housing Costs Money',
      titleSk: 'Bývanie stojí peniaze',
      body: 'Why do we pay for a place to live when we live there every day?',
      bodySk: 'Prečo treba platiť za miesto, kde bývame, keď tam žijeme každý deň?',
      accentColor: Color(0xFF795548),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🏢',
      title: 'More Than Just a Space',
      titleSk: 'Viac ako len priestor',
      body: 'Chrumko asks why the family keeps paying for the flat they already have. Mum explains: housing means not just the space, but everything around it — warmth, water, shared areas, maintenance. When the lift breaks or the roof needs fixing, that costs money too!',
      bodySk: 'Chrumko sa pýta, prečo rodina stále platí za byt, ktorý už predsa majú. Mama vysvetlí: bývanie znamená nielen samotný priestor, ale aj všetko okolo — teplo, voda, spoločné priestory, údržba. Keď sa pokazí výťah alebo treba opraviť strechu, aj to stojí peniaze!',
      accentColor: Color(0xFF795548),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🏡',
      highlightText: 'A home needs constant care — and care costs money every single month!',
      highlightTextSk: 'Domov potrebuje neustálu starostlivosť — a starostlivosť stojí peniaze každý mesiac!',
      accentColor: Color(0xFF795548),
    ),
  ],

  'jedlo_stoji_peniaze': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🛒',
      title: 'Food Costs Money',
      titleSk: 'Jedlo stojí peniaze',
      body: 'Why doesn\'t the fridge fill itself, even though there always seems to be food at home?',
      bodySk: 'Prečo sa chladnička sama nenaplní, aj keď sa zdá, že jedlo je doma stále?',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🧺',
      title: 'A Small Shop Adds Up',
      titleSk: 'Malý nákup sa spočíta',
      body: 'Chrumko goes with mum for a small shop. They put in bread, milk, fruit, cheese, pasta and yoghurt. It seems like just a few things. But at the checkout the total is higher than expected! Regular everyday food together costs quite a lot.',
      bodySk: 'Chrumko ide s mamou na menší nákup. Dávajú do košíka chlieb, mlieko, ovocie, syr, cestoviny a jogurty. Zdá sa, že kupujú len pár vecí. Ale pri pokladni je suma vyššia ako čakal! Bežné každodenné jedlo spolu stojí dosť veľa.',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🍽️',
      highlightText: 'Food is one of the BIGGEST regular expenses for every family!',
      highlightTextSk: 'Jedlo je jeden z NAJVÄČŠÍCH pravidelných výdavkov každej rodiny!',
      accentColor: Color(0xFF4CAF50),
    ),
  ],

  'energie_stoja_peniaze': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '💡',
      title: 'Energy Costs Money',
      titleSk: 'Energia stojí peniaze',
      body: 'Why do parents turn off lights even when we could leave them on a little longer?',
      bodySk: 'Prečo rodičia vypínajú svetlo, aj keď ho ešte chvíľu môžeme nechať svietiť?',
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🔌',
      title: 'Small Things Add Up',
      titleSk: 'Malé veci sa spočítajú',
      body: 'Chrumko leaves his room and forgets to turn off the light. Mum calls him back. She explains that even small things add up over a month. At home they also close the tap when brushing teeth and don\'t leave the fridge open too long. Energy isn\'t visible — but it costs money every day!',
      bodySk: 'Chrumko odíde z izby a zabudne vypnúť svetlo. Mama ho zavolá späť. Vysvetlí mu, že aj malé veci sa počas mesiaca spočítajú. Doma taktiež zatvárajú vodu pri umývaní zubov a nenechávajú dlho otvorenú chladničku. Energia nie je viditeľná — ale stojí peniaze každý deň!',
      accentColor: Color(0xFFF5A623),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '🌍',
      title: 'Save Energy = Save Money',
      titleSk: 'Šetri energiu = šetri peniaze',
      body: 'Turn off lights when leaving a room. Don\'t leave taps running. Close the fridge quickly. These small habits save money AND help the planet!',
      bodySk: 'Vypínaj svetlá pri odchode z izby. Nenechávaj tiecť vodu. Rýchlo zatváraj chladničku. Tieto malé návyky šetria peniaze A pomáhajú planéte!',
      accentColor: Color(0xFFF5A623),
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
      body: 'Why do adults go to work every day, even when they\'d sometimes rather stay home?',
      bodySk: 'Prečo dospelí každý deň chodia do práce, aj keď by radšej niekedy zostali doma?',
      accentColor: Color(0xFF3F51B5),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🌧️',
      title: 'Mum Goes Even in the Rain',
      titleSk: 'Mama ide aj v daždi',
      body: 'Chrumko notices mum getting ready for work even though it\'s raining outside. He asks why she has to go every day. Mum explains: her salary pays for rent, food, school supplies, electricity and water. Without work, there\'d be no money for any of it.',
      bodySk: 'Chrumko si všimne, že mama sa pripravuje do práce, aj keď vonku prší. Spýta sa, prečo musí ísť každý deň. Mama vysvetlí: jej plat platí nájom, jedlo, školské potreby, elektrinu a vodu. Bez práce by neboli peniaze na nič z toho.',
      accentColor: Color(0xFF3F51B5),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🌟',
      title: 'More Reasons to Work',
      titleSk: 'Ďalšie dôvody na prácu',
      facts: [
        FactItem(emoji: '💰', text: 'Earn income to pay for needs & wants', textSk: 'Zarobiť príjem na pokrytie potrieb a túžob'),
        FactItem(emoji: '🧠', text: 'Use your skills and talents', textSk: 'Využiť svoje zručnosti a talenty'),
        FactItem(emoji: '👥', text: 'Be part of a community', textSk: 'Byť súčasťou komunity'),
        FactItem(emoji: '🎯', text: 'Find purpose and meaning', textSk: 'Nájsť zmysel a účel'),
      ],
      accentColor: Color(0xFF3F51B5),
    ),
    LessonSlide(
      type: LessonSlideType.tip,
      emoji: '🚀',
      title: 'The Best Jobs',
      titleSk: 'Najlepšie práce',
      body: 'The best jobs combine what you\'re good at, what you enjoy, and what the world needs. In Japanese this is called "ikigai" — meaning "reason for being"!',
      bodySk: 'Najlepšie práce spájajú to, v čom vynikáš, čo ťa baví a čo svet potrebuje. Po japonsky sa to nazýva „ikigai" — čo znamená „dôvod existencie"!',
      accentColor: Color(0xFFE91E63),
    ),
  ],

  'typy_povolani': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '👷',
      title: 'Types of Jobs',
      titleSk: 'Typy povolaní',
      body: 'Do all adults do the same work, or does everyone have a different role?',
      bodySk: 'Robia všetci dospelí rovnakú prácu, alebo má každý inú úlohu?',
      accentColor: Color(0xFFFF5722),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🚌',
      title: 'Chrumko\'s Morning Walk',
      titleSk: 'Chrumkova ranná prechádzka',
      body: 'On the way to school, Chrumko notices how many people are already working. A bus driver, a teacher at school, workers fixing the pavement. Later a shop assistant restocks shelves and a postman delivers letters. Every person does something different — but all of it makes the world work!',
      bodySk: 'Cestou do školy si Chrumko všimne, koľko ľudí už pracuje. Vodič autobusu, v škole učiteľka, pracovníci opravujú chodník. Neskôr predavačka dopĺňa tovar a poštár nosí listy. Každý robí niečo iné — ale všetko spolu funguje!',
      accentColor: Color(0xFFFF5722),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🌐',
      title: 'Types of Work',
      titleSk: 'Typy práce',
      facts: [
        FactItem(emoji: '🏥', text: 'Helping people — doctors, teachers, social workers', textSk: 'Pomoc ľuďom — lekári, učitelia, sociálni pracovníci'),
        FactItem(emoji: '🔧', text: 'Making & fixing things — builders, mechanics, engineers', textSk: 'Výroba a oprava vecí — stavbári, mechanici, inžinieri'),
        FactItem(emoji: '💻', text: 'Creative & tech — designers, programmers, artists', textSk: 'Kreatívna a technická práca — dizajnéri, programátori, umelci'),
        FactItem(emoji: '🛒', text: 'Selling & service — shop workers, drivers, waiters', textSk: 'Predaj a služby — predavači, vodiči, čašníci'),
      ],
      accentColor: Color(0xFFFF5722),
    ),
  ],

  'plat_a_odmena': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '💳',
      title: 'Salary and Pay',
      titleSk: 'Plat a odmena',
      body: 'Does every person get the same amount of money for their work?',
      bodySk: 'Dostáva každý človek za svoju prácu rovnaké peniaze?',
      accentColor: Color(0xFF009688),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '📅',
      title: 'Once a Month',
      titleSk: 'Raz za mesiac',
      body: 'Chrumko asks his dad why money doesn\'t arrive every day. Dad explains: he gets his salary once a month into his account. From this money the family gradually pays for everything needed throughout the whole month. That\'s why it must be carefully divided!',
      bodySk: 'Chrumko sa pýta otca, prečo peniaze neprichádzajú každý deň. Otec vysvetlí: plat dostáva raz za mesiac na účet. Z týchto peňazí rodina postupne platí všetko potrebné počas celého mesiaca. Preto musí byť starostlivo rozdelený!',
      accentColor: Color(0xFF009688),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '⚖️',
      title: 'What Affects Your Salary',
      titleSk: 'Čo ovplyvňuje plat',
      facts: [
        FactItem(emoji: '🎓', text: 'Type of work and qualifications needed', textSk: 'Typ práce a potrebná kvalifikácia'),
        FactItem(emoji: '📈', text: 'Experience — more years = often higher pay', textSk: 'Skúsenosti — viac rokov = často vyšší plat'),
        FactItem(emoji: '⚡', text: 'Responsibility level in the role', textSk: 'Miera zodpovednosti v práci'),
      ],
      accentColor: Color(0xFF009688),
    ),
  ],

  'cas_je_hodnota': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '⏱️',
      title: 'Time = Value',
      titleSk: 'Čas = hodnota',
      body: 'Why does the amount of time a person spends working also matter?',
      bodySk: 'Prečo záleží aj na tom, koľko času človek práci venuje?',
      accentColor: Color(0xFF7C5CBF),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🌿',
      title: 'Chrumko\'s Brother Earns His Pay',
      titleSk: 'Chrumkov brat si zarobí',
      body: 'Chrumko sees his older brother helping the neighbour tidy the garden all morning — collecting leaves, raking grass, carrying branches. After finishing, he gets a small payment. The neighbour explains: the payment is for the time and help he gave to the work.',
      bodySk: 'Chrumko vidí, že starší brat pomáha susedovi celé dopoludnie uprať záhradu — zbiera lístie, hrabie trávu, nosí konáre. Po skončení dostane malú odmenu. Sused vysvetlí: odmena patrí za čas a pomoc, ktorú venoval práci.',
      accentColor: Color(0xFF7C5CBF),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '⏰',
      highlightText: 'Time is money — the time you spend working has real value!',
      highlightTextSk: 'Čas sú peniaze — čas, ktorý venujete práci, má skutočnú hodnotu!',
      accentColor: Color(0xFF7C5CBF),
    ),
  ],

  'produktivita': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '⚡',
      title: 'Productivity',
      titleSk: 'Produktivita',
      body: 'Is it only important to work a long time — or also to work efficiently?',
      bodySk: 'Je dôležité len pracovať dlho, alebo aj pracovať efektívne?',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '📱',
      title: 'Chrumko and His Homework',
      titleSk: 'Chrumko a jeho domáca úloha',
      body: 'Chrumko does homework but keeps checking his phone — it takes forever. Next day he sits down without distractions, prepares everything and works focused. He finishes much faster and without stress. He realises: when he works carefully, he gets more done in less time!',
      bodySk: 'Chrumko robí domácu úlohu, ale stále pozerá na mobil — trvá to veľmi dlho. Na druhý deň si sadne bez vyrušovania, pripraví si všetko a pracuje sústredene. Skončí oveľa rýchlejšie a bez stresu. Uvedomí si: keď pracuje pozorne, zvládne viac za kratší čas!',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🎯',
      highlightText: 'Work SMARTER, not just harder — focus is your most powerful tool!',
      highlightTextSk: 'Pracuj MÚDREJŠIE, nielen tvrdšie — sústredenie je tvoj najmocnejší nástroj!',
      accentColor: Color(0xFF4CAF50),
    ),
  ],

  // ════════════════════════════════════════════
  // SECTION 9 — ROZPOČET
  // ════════════════════════════════════════════

  'co_je_rozpocet': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📊',
      title: 'What is a Budget?',
      titleSk: 'Čo je rozpočet?',
      body: 'How do people know how much they can spend so money lasts the whole month?',
      bodySk: 'Ako ľudia vedia, koľko môžu minúť, aby im peniaze vystačili do konca mesiaca?',
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '📓',
      title: 'Mum\'s Notebook',
      titleSk: 'Mamin zošit',
      body: 'Chrumko sees mum writing numbers in a notebook. She\'s planning expenses for the whole month — first writing income, then what needs to be paid. Only then does she think about what\'s left for extra things. A budget helps keep money in order!',
      bodySk: 'Chrumko vidí, že mama si zapisuje čísla do zošita. Plánuje výdavky na celý mesiac — najprv píše príjem, potom čo treba zaplatiť. Až potom premýšľa, čo zostane na extra veci. Rozpočet pomáha mať v peniazoch poriadok!',
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📝',
      title: 'Budget Basics',
      titleSk: 'Základy rozpočtu',
      facts: [
        FactItem(emoji: '➕', text: 'Income: all the money coming IN', textSk: 'Príjem: všetky peniaze, ktoré PRICHÁDZAJÚ'),
        FactItem(emoji: '➖', text: 'Expenses: all the money going OUT', textSk: 'Výdavky: všetky peniaze, ktoré ODCHÁDZAJÚ'),
        FactItem(emoji: '💚', text: 'Surplus: income > expenses = great!', textSk: 'Prebytok: príjem > výdavky = super!'),
        FactItem(emoji: '❤️', text: 'Deficit: income < expenses = danger zone', textSk: 'Deficit: príjem < výdavky = nebezpečná zóna'),
      ],
      accentColor: Color(0xFF9C27B0),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '📐',
      highlightText: 'A budget is not a restriction — it\'s FREEDOM to spend without guilt!',
      highlightTextSk: 'Rozpočet nie je obmedzenie — je to SLOBODA míňať bez výčitiek!',
      accentColor: Color(0xFF9C27B0),
    ),
  ],

  'prijmy_a_vydavky': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '⚖️',
      title: 'Income and Expenses',
      titleSk: 'Príjmy a výdavky',
      body: 'Why isn\'t it enough to just know how much money we have?',
      bodySk: 'Prečo nestačí vedieť len to, koľko peňazí máme?',
      accentColor: Color(0xFF2196F3),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '📉',
      title: 'Chrumko Learns About Both Sides',
      titleSk: 'Chrumko sa dozvie o oboch stranách',
      body: 'Chrumko thinks when parents get their salary, they can immediately buy everything they want. Dad shows him: first they subtract housing, food and other bills. What\'s left is much less. It\'s not just about what COMES IN — it\'s also about what GOES OUT!',
      bodySk: 'Chrumko si myslí, že keď rodičia dostanú výplatu, môžu hneď kúpiť všetko, čo chcú. Otec mu ukáže: najprv treba odpočítať bývanie, jedlo a ďalšie účty. Čo zostane je oveľa menej. Dôležité nie je len to, čo PRÍDE — ale aj to, čo ODÍDE!',
      accentColor: Color(0xFF2196F3),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🔄',
      highlightText: 'Income - Expenses = What you actually have left to use freely!',
      highlightTextSk: 'Príjem - Výdavky = To, čo ti naozaj zostane na voľné použitie!',
      accentColor: Color(0xFF2196F3),
    ),
  ],

  'mesacne_planovanie': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📅',
      title: 'Monthly Planning',
      titleSk: 'Mesačné plánovanie',
      body: 'Why doesn\'t the family spend all their money at the start of the month?',
      bodySk: 'Prečo rodina neminie všetky peniaze hneď na začiatku mesiaca?',
      accentColor: Color(0xFF009688),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🎮',
      title: 'Wait for the Right Time',
      titleSk: 'Počkaj na správny čas',
      body: 'Chrumko suggests buying a new game right after the salary arrives. Mum explains: they must first wait to pay for internet, school lunch and household costs. Only after all that can they see what\'s left for extras. Good planning = money that lasts all month!',
      bodySk: 'Chrumko navrhne kúpiť novú hru hneď po výplate. Mama vysvetlí: najprv musia počkať, kým zaplatia internet, školský obed a domácnosť. Až potom uvidia, čo zostane na extra veci. Dobré plánovanie = peniaze, ktoré vydržia celý mesiac!',
      accentColor: Color(0xFF009688),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🗓️',
      highlightText: 'Think ahead — plan for the WHOLE month, not just today!',
      highlightTextSk: 'Mysli dopredu — plánuj na CELÝ mesiac, nielen na dnes!',
      accentColor: Color(0xFF009688),
    ),
  ],

  'fixne_vydavky': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🔒',
      title: 'Fixed Expenses',
      titleSk: 'Fixné výdavky',
      body: 'Why do some expenses repeat the same way every time?',
      bodySk: 'Prečo sa niektoré výdavky opakujú stále rovnako?',
      accentColor: Color(0xFF795548),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '📄',
      title: 'Same Bills Every Month',
      titleSk: 'Rovnaké účty každý mesiac',
      body: 'Chrumko asks why parents talk about the same payments every month. Dad shows him the internet and rent bill. He explains these payments arrive regularly — even when they don\'t buy anything new, these costs stay the same. Some money is always already assigned!',
      bodySk: 'Chrumko sa pýta, prečo rodičia hovoria každý mesiac o rovnakých platbách. Otec mu ukáže účet za internet a nájom. Vysvetlí, že tieto platby prichádzajú pravidelne — aj keď nič nové nekupujú, tieto náklady zostávajú rovnaké. Niektoré peniaze sú vždy vopred určené!',
      accentColor: Color(0xFF795548),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🔒',
      title: 'Examples of Fixed Expenses',
      titleSk: 'Príklady fixných výdavkov',
      facts: [
        FactItem(emoji: '🏠', text: 'Rent or mortgage — same amount every month', textSk: 'Nájom alebo hypotéka — rovnaká suma každý mesiac'),
        FactItem(emoji: '🌐', text: 'Internet subscription', textSk: 'Predplatné na internet'),
        FactItem(emoji: '📱', text: 'Phone plan', textSk: 'Mobilný plán'),
        FactItem(emoji: '🎓', text: 'School lunch or transport pass', textSk: 'Školský obed alebo mesačný lístok'),
      ],
      accentColor: Color(0xFF795548),
    ),
  ],

  'variabilne_vydavky': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📈',
      title: 'Variable Expenses',
      titleSk: 'Variabilné výdavky',
      body: 'Why do we sometimes spend more and sometimes less, even when buying similar things?',
      bodySk: 'Prečo niekedy minieme viac a inokedy menej, aj keď kupujeme podobné veci?',
      accentColor: Color(0xFF3F51B5),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🎁',
      title: 'Not Every Week the Same',
      titleSk: 'Nie každý týždeň rovnako',
      body: 'One week Chrumko\'s family buys only basic food. Another week they buy extra fruit, school supplies and a birthday present for grandma. The total is much higher! Mum explains: some expenses change based on what\'s needed that week.',
      bodySk: 'Jeden týždeň rodina kupuje len základné potraviny. Ďalší týždeň kupujú aj ovocie navyše, školské pomôcky a darček pre babku. Suma je oveľa vyššia! Mama vysvetlí: niektoré výdavky sa menia podľa toho, čo treba práve vtedy.',
      accentColor: Color(0xFF3F51B5),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '📊',
      highlightText: 'Variable costs change month to month — always leave BUFFER money in your budget!',
      highlightTextSk: 'Variabilné náklady sa menia mesiac od mesiaca — vždy nechaj v rozpočte REZERVU!',
      accentColor: Color(0xFF3F51B5),
    ),
  ],

  // ════════════════════════════════════════════
  // SECTION 10 — BANKY A ÚČTY
  // ════════════════════════════════════════════

  'co_robi_banka': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🏦',
      title: 'What Does a Bank Do?',
      titleSk: 'Čo robí banka?',
      body: 'Where does money go when parents don\'t keep it in their wallet at home?',
      bodySk: 'Kam idú peniaze, keď ich rodičia nedržia doma v peňaženke?',
      accentColor: Color(0xFF009688),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '📲',
      title: 'Salary in the Bank',
      titleSk: 'Výplata v banke',
      body: 'Chrumko asks why mum doesn\'t go to pick up her salary in person. Mum explains: the salary came directly to her bank account. She shows him on her phone that she can see the received amount there. Money can be stored safely even without holding it in your hand!',
      bodySk: 'Chrumko sa pýta, prečo mama nejde po výplatu osobne. Mama vysvetlí: výplata prišla priamo do jej bankového účtu. Ukáže mu v mobile, že tam vidí prijatú sumu. Peniaze môžu byť uložené bezpečne aj bez toho, aby ich držala v ruke!',
      accentColor: Color(0xFF009688),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '🏦',
      title: 'What a Bank Does',
      titleSk: 'Čo banka robí',
      facts: [
        FactItem(emoji: '🔐', text: 'Stores your money safely', textSk: 'Bezpečne uchováva tvoje peniaze'),
        FactItem(emoji: '💳', text: 'Allows payments by card anywhere', textSk: 'Umožňuje platby kartou kdekoľvek'),
        FactItem(emoji: '📤', text: 'Sends money to other accounts', textSk: 'Posiela peniaze na iné účty'),
        FactItem(emoji: '💵', text: 'Lets you withdraw cash at ATMs', textSk: 'Umožňuje vybrať hotovosť v bankomatoch'),
      ],
      accentColor: Color(0xFF009688),
    ),
  ],

  'bankovy_ucet': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📱',
      title: 'Bank Account',
      titleSk: 'Bankový účet',
      body: 'How does a bank know which money belongs to whom?',
      bodySk: 'Ako banka vie, ktoré peniaze patria komu?',
      accentColor: Color(0xFF7C5CBF),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '📊',
      title: 'Checking the Balance',
      titleSk: 'Kontrola stavu účtu',
      body: 'Chrumko sees dad checking his account balance on his phone. The screen shows a number — how much money is currently in the account. When they pay a bill or shop, the amount decreases. When the salary arrives, it increases. An account is like a live overview of your money!',
      bodySk: 'Chrumko vidí, že otec kontroluje stav účtu v mobile. Na obrazovke je číslo — koľko peňazí je momentálne na účte. Keď zaplatia účet alebo nakúpia, suma sa zmenší. Keď príde výplata, suma sa zvýši. Účet je ako živý prehľad tvojich peňazí!',
      accentColor: Color(0xFF7C5CBF),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '💡',
      highlightText: 'Your bank account is YOUR money — stored safely in digital form!',
      highlightTextSk: 'Bankový účet sú TVOJE peniaze — bezpečne uložené v digitálnej forme!',
      accentColor: Color(0xFF7C5CBF),
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
      accentColor: Color(0xFF2196F3),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🛒',
      title: 'Mum Pays by Card',
      titleSk: 'Mama platí kartou',
      body: 'Chrumko goes shopping with mum. At the checkout she doesn\'t take out cash — she takes out a card. After payment the amount shows on the terminal. Mum explains: the money left her bank account. The card just helps use the money stored in the bank!',
      bodySk: 'Chrumko ide s mamou do obchodu. Pri pokladni nevytiahne hotovosť — vytiahne kartu. Po zaplatení sa suma zobrazí na termináli. Mama vysvetlí: peniaze odišli z jej bankového účtu. Karta len pomáha použiť peniaze uložené v banke!',
      accentColor: Color(0xFF2196F3),
    ),
    LessonSlide(
      type: LessonSlideType.facts,
      emoji: '📋',
      title: 'Card Uses',
      titleSk: 'Použitia karty',
      facts: [
        FactItem(emoji: '🏪', text: 'Pay in shops and restaurants', textSk: 'Platiť v obchodoch a reštauráciách'),
        FactItem(emoji: '🏧', text: 'Withdraw cash from ATMs', textSk: 'Vyberať hotovosť z bankomatov'),
        FactItem(emoji: '🌐', text: 'Pay online in e-shops', textSk: 'Platiť online v e-shopoch'),
      ],
      accentColor: Color(0xFF2196F3),
    ),
  ],

  'pin': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '🔐',
      title: 'PIN Code',
      titleSk: 'PIN kód',
      body: 'Why isn\'t it enough to just have a card — you also need to know a secret number?',
      bodySk: 'Prečo nestačí mať kartu, ale treba poznať aj tajné číslo?',
      accentColor: Color(0xFFFF5722),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '🙈',
      title: 'Mum Covers the Keypad',
      titleSk: 'Mama zakrýva klávesnicu',
      body: 'Chrumko notices mum covering the keypad with her hand when paying. He asks why. Mum explains: she\'s entering her PIN and doesn\'t want anyone to see it. Secret details must be protected. If a stranger knew the PIN together with the card, they could use someone else\'s money!',
      bodySk: 'Chrumko si všimne, že mama pri platení zakrýva rukou klávesnicu. Spýta sa prečo. Mama vysvetlí: zadáva PIN a nechce, aby ho niekto videl. Tajné údaje treba chrániť. Keby cudzí poznal PIN spolu s kartou, mohol by použiť cudzie peniaze!',
      accentColor: Color(0xFFFF5722),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🔐',
      highlightText: 'Your PIN is YOUR secret — NEVER share it with anyone, not even friends!',
      highlightTextSk: 'Tvoj PIN je TVOJE tajomstvo — NIKDY ho nezdieľaj s nikým, ani s priateľmi!',
      accentColor: Color(0xFFFF5722),
    ),
  ],

  'prevod_peniazi': [
    LessonSlide(
      type: LessonSlideType.intro,
      emoji: '📤',
      title: 'Transferring Money',
      titleSk: 'Prevod peňazí',
      body: 'How does money get to someone else without an envelope or cash?',
      bodySk: 'Ako sa peniaze dostanú k niekomu inému bez obálky alebo hotovosti?',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.info,
      emoji: '👵',
      title: 'Mum Sends Money to Grandma',
      titleSk: 'Mama posiela peniaze babke',
      body: 'Chrumko hears mum is sending money to grandma. He thinks they\'ll go to the post office. Mum shows him on her phone: she entered an account number and amount. After confirming, the money was sent digitally. Today money mostly moves electronically!',
      bodySk: 'Chrumko počuje, že mama posiela peniaze babke. Myslí si, že pôjdu na poštu. Mama mu ukáže v mobile: zadala číslo účtu a sumu. Po potvrdení sa peniaze odoslali digitálne. Dnes sa peniaze väčšinou pohybujú elektronicky!',
      accentColor: Color(0xFF4CAF50),
    ),
    LessonSlide(
      type: LessonSlideType.highlight,
      emoji: '🌐',
      highlightText: 'Money travels instantly around the world — all digitally, no envelope needed!',
      highlightTextSk: 'Peniaze cestujú okamžite po celom svete — všetko digitálne, bez obálky!',
      accentColor: Color(0xFF4CAF50),
    ),
  ],
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