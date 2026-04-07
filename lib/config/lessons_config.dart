import '../models/lesson.dart';

const List<LessonCategory> LESSON_CATEGORIES = [
  LessonCategory(
    id: 'peniaze_ako_koncept',
    title: 'Peniaze ako koncept',
    lessons: [
      Lesson(id: 'co_su_peniaze', title: 'Čo sú peniaze', quizLessonId: 1001),
      Lesson(id: 'preco_peniaze_existuju', title: 'Prečo peniaze existujú', quizLessonId: 1002),
      Lesson(id: 'ako_ludia_platili_kedysi', title: 'Ako ľudia platili kedysi', quizLessonId: 1003),
      Lesson(id: 'mince_bankovky_digitalne', title: 'Mince, bankovky, digitálne peniaze', quizLessonId: 1004),
      Lesson(id: 'hodnota_peniazi', title: 'Hodnota peňazí', quizLessonId: 1005),
      Lesson(id: 'peniaze_nie_su_nekonecne', title: 'Peniaze nie sú nekonečné', quizLessonId: 1006),
      Lesson(id: 'odkial_peniaze_prichadzaju', title: 'Odkiaľ peniaze prichádzajú', quizLessonId: 1007),
    ],
  ),
  LessonCategory(
    id: 'potreby_vs_tuzby',
    title: 'Potreby vs túžby',
    lessons: [
      Lesson(id: 'co_potrebujem_na_zivot', title: 'Čo potrebujem na život', quizLessonId: 2001),
      Lesson(id: 'co_len_chcem', title: 'Čo len chcem', quizLessonId: 2002),
      Lesson(id: 'preco_chceme_vec', title: 'Prečo chceme veci, ktoré nepotrebujeme', quizLessonId: 2003),
      Lesson(id: 'reklama_vplyv', title: 'Reklama a jej vplyv', quizLessonId: 2004),
      Lesson(id: 'emocionalne_nakupovanie', title: 'Emocionálne nakupovanie', quizLessonId: 2005),
    ],
  ),
  LessonCategory(
    id: 'prve_hospodarenie',
    title: 'Prvé hospodárenie s peniazmi',
    lessons: [
      Lesson(id: 'vreckove', title: 'Vreckové', quizLessonId: 3001),
      Lesson(id: 'ako_si_rozdelit_peniaze', title: 'Ako si rozdeliť peniaze', quizLessonId: 3002),
      Lesson(id: 'minut_teraz_vs_neskor', title: 'Minúť teraz vs neskôr', quizLessonId: 3003),
      Lesson(id: 'preco_sa_oplati_planovat', title: 'Prečo sa oplatí plánovať', quizLessonId: 3004),
      Lesson(id: 'male_financne_chyby', title: 'Malé finančné chyby', quizLessonId: 3005),
    ],
  ),
  LessonCategory(
    id: 'sporenie',
    title: 'Sporenie',
    lessons: [
      Lesson(id: 'co_je_sporenie', title: 'Čo je sporenie', quizLessonId: 4001),
      Lesson(id: 'preco_si_odkladat', title: 'Prečo si odkladať peniaze', quizLessonId: 4002),
      Lesson(id: 'kratkodoby_vs_dlhodoby', title: 'Krátkodobý cieľ vs dlhodobý cieľ', quizLessonId: 4003),
      Lesson(id: 'ako_si_vytvorit_rezervu', title: 'Ako si vytvoriť rezervu', quizLessonId: 4004),
      Lesson(id: 'pravidelne_male_sumy', title: 'Pravidelné malé sumy', quizLessonId: 4005),
    ],
  ),
  LessonCategory(
    id: 'cena_a_hodnota',
    title: 'Cena a hodnota',
    lessons: [
      Lesson(id: 'cena_vs_kvalita', title: 'Cena vs kvalita', quizLessonId: 5001),
      Lesson(id: 'lacne_vs_drahe', title: 'Lacné vs drahé', quizLessonId: 5002),
      Lesson(id: 'vyhodna_kupa', title: 'Čo znamená výhodná kúpa', quizLessonId: 5003),
      Lesson(id: 'porovnavanie_cien', title: 'Porovnávanie cien', quizLessonId: 5004),
      Lesson(id: 'jednotkova_cena', title: 'Jednotková cena', quizLessonId: 5005),
    ],
  ),
  LessonCategory(
    id: 'nakupovanie_a_rozhodovanie',
    title: 'Nakupovanie a rozhodovanie',
    lessons: [
      Lesson(id: 'ako_funguje_obchod', title: 'Ako funguje obchod', quizLessonId: 6001),
      Lesson(id: 'zlavy', title: 'Zľavy', quizLessonId: 6002),
      Lesson(id: 'marketingove_triky', title: 'Akcie a marketingové triky', quizLessonId: 6003),
      Lesson(id: 'impulzivne_nakupy', title: 'Impulzívne nákupy', quizLessonId: 6004),
      Lesson(id: 'ako_nenaletiet_na_reklamu', title: 'Ako nenaletieť na reklamu', quizLessonId: 6005),
    ],
  ),
  LessonCategory(
    id: 'peniaze_v_rodine',
    title: 'Peniaze v rodine',
    lessons: [
      Lesson(id: 'odkial_rodina_berie_peniaze', title: 'Odkiaľ rodina berie peniaze', quizLessonId: 7001),
      Lesson(id: 'vydavky_domacnosti', title: 'Výdavky domácnosti', quizLessonId: 7002),
      Lesson(id: 'byvanie_stoji_peniaze', title: 'Bývanie stojí peniaze', quizLessonId: 7003),
      Lesson(id: 'jedlo_stoji_peniaze', title: 'Jedlo stojí peniaze', quizLessonId: 7004),
      Lesson(id: 'energie_stoja_peniaze', title: 'Energie stoja peniaze', quizLessonId: 7005),
    ],
  ),
  LessonCategory(
    id: 'praca_a_prijem',
    title: 'Práca a príjem',
    lessons: [
      Lesson(id: 'preco_ludia_pracuju', title: 'Prečo ľudia pracujú', quizLessonId: 8001),
      Lesson(id: 'typy_povolani', title: 'Typy povolaní', quizLessonId: 8002),
      Lesson(id: 'plat_a_odmena', title: 'Plat a odmena', quizLessonId: 8003),
      Lesson(id: 'cas_je_hodnota', title: 'Čas = hodnota', quizLessonId: 8004),
      Lesson(id: 'produktivita', title: 'Produktivita', quizLessonId: 8005),
    ],
  ),
  LessonCategory(
    id: 'rozpocet',
    title: 'Rozpočet',
    lessons: [
      Lesson(id: 'co_je_rozpocet', title: 'Čo je rozpočet', quizLessonId: 9001),
      Lesson(id: 'prijmy_a_vydavky', title: 'Príjmy a výdavky', quizLessonId: 9002),
      Lesson(id: 'mesacne_planovanie', title: 'Mesačné plánovanie', quizLessonId: 9003),
      Lesson(id: 'fixne_vydavky', title: 'Fixné výdavky', quizLessonId: 9004),
      Lesson(id: 'variabilne_vydavky', title: 'Variabilné výdavky', quizLessonId: 9005),
    ],
  ),
  LessonCategory(
    id: 'banky_a_ucty',
    title: 'Banky a účty',
    lessons: [
      Lesson(id: 'co_robi_banka', title: 'Čo robí banka', quizLessonId: 10001),
      Lesson(id: 'bankovy_ucet', title: 'Bankový účet', quizLessonId: 10002),
      Lesson(id: 'platobna_karta', title: 'Platobná karta', quizLessonId: 10003),
      Lesson(id: 'pin', title: 'PIN', quizLessonId: 10004),
      Lesson(id: 'prevod_peniazi', title: 'Prevod peňazí', quizLessonId: 10005),
    ],
  ),
  LessonCategory(
    id: 'digitalne_peniaze',
    title: 'Digitálne peniaze a online bezpečnosť',
    lessons: [
      Lesson(id: 'online_platby', title: 'Online platby'),
      Lesson(id: 'hesla', title: 'Heslá'),
      Lesson(id: 'scam', title: 'Scam'),
      Lesson(id: 'falosne_e_shopy', title: 'Falošné e-shopy'),
      Lesson(id: 'podvody_na_internete', title: 'Podvody na internete'),
      Lesson(id: 'influenceri_a_peniaze', title: 'Influenceri a peniaze'),
    ],
  ),
  LessonCategory(
    id: 'dlh_a_poziciavanie',
    title: 'Dlh a požičiavanie',
    lessons: [
      Lesson(id: 'co_je_dlh', title: 'Čo je dlh'),
      Lesson(id: 'dobry_vs_zly_dlh', title: 'Dobrý vs zlý dlh'),
      Lesson(id: 'kedy_si_ludia_poziciavaju', title: 'Kedy si ľudia požičiavajú'),
      Lesson(id: 'urok', title: 'Úrok'),
      Lesson(id: 'preco_sa_dlh_zvacuje', title: 'Prečo sa dlh zväčšuje'),
      Lesson(id: 'rizika_poziciek', title: 'Riziká pôžičiek'),
    ],
  ),
  LessonCategory(
    id: 'financne_chyby',
    title: 'Finančné chyby',
    lessons: [
      Lesson(id: 'minanie_bez_planu', title: 'Míňanie bez plánu'),
      Lesson(id: 'nakupovanie_pod_emociami', title: 'Nakupovanie pod emóciami'),
      Lesson(id: 'zadlzenie', title: 'Zadĺženie'),
      Lesson(id: 'fomo_pri_peniazoch', title: 'FOMO pri peniazoch'),
      Lesson(id: 'peer_pressure', title: 'Peer pressure'),
    ],
  ),
  LessonCategory(
    id: 'prva_vyplata',
    title: 'Prvá výplata',
    lessons: [
      Lesson(id: 'hruba_vs_cista_mzda', title: 'Hrubá vs čistá mzda'),
      Lesson(id: 'odvody_jednoducho', title: 'Odvody jednoducho'),
      Lesson(id: 'brigada', title: 'Brigáda'),
      Lesson(id: 'prvy_plat', title: 'Prvý plat'),
      Lesson(id: 'kam_miznu_peniaze', title: 'Kam miznú peniaze'),
    ],
  ),
  LessonCategory(
    id: 'stat_a_peniaze',
    title: 'Štát a peniaze',
    lessons: [
      Lesson(id: 'dane', title: 'Dane'),
      Lesson(id: 'na_co_idu_dane', title: 'Na čo idú dane'),
      Lesson(id: 'verejne_sluzby', title: 'Verejné služby'),
      Lesson(id: 'preco_stat_vybera_peniaze', title: 'Prečo štát vyberá peniaze'),
    ],
  ),
  LessonCategory(
    id: 'financna_rezerva',
    title: 'Finančná rezerva',
    lessons: [
      Lesson(id: 'nudzove_peniaze', title: 'Núdzové peniaze'),
      Lesson(id: 'necakane_vydavky', title: 'Nečakané výdavky'),
      Lesson(id: 'preco_mat_rezervu', title: 'Prečo mať rezervu'),
    ],
  ),
  LessonCategory(
    id: 'inflacia',
    title: 'Inflácia',
    lessons: [
      Lesson(id: 'preco_vec_zdrazuju', title: 'Prečo veci zdražujú'),
      Lesson(id: 'peniaze_stracaju_hodnotu', title: 'Peniaze strácajú hodnotu'),
      Lesson(id: 'ako_inflacia_ovplyvnuje_zivot', title: 'Ako inflácia ovplyvňuje život'),
    ],
  ),
  LessonCategory(
    id: 'investovanie',
    title: 'Investovanie',
    lessons: [
      Lesson(id: 'peniaze_mozu_pracovat', title: 'Peniaze môžu pracovať'),
      Lesson(id: 'riziko_a_vynos', title: 'Riziko a výnos'),
      Lesson(id: 'dlhodobost', title: 'Dlhodobosť – sila zloženého úročenia'),
      Lesson(id: 'zaklad_investovania', title: 'Základ investovania'),
      Lesson(id: 'diverzifikacia', title: 'Diverzifikácia'),
    ],
  ),
  LessonCategory(
    id: 'podnikanie',
    title: 'Podnikanie',
    lessons: [
      Lesson(id: 'ako_vznika_firma', title: 'Ako vzniká firma'),
      Lesson(id: 'naklady_a_zisk', title: 'Náklady a zisk'),
      Lesson(id: 'riziko_podnikania', title: 'Riziko podnikania'),
      Lesson(id: 'cena_produktu', title: 'Cena produktu'),
    ],
  ),
  LessonCategory(
    id: 'financna_samostatnost',
    title: 'Finančná samostatnosť',
    lessons: [
      Lesson(id: 'samostatne_byvanie', title: 'Samostatné bývanie'),
      Lesson(id: 'mesacne_naklady_dospeleho', title: 'Mesačné náklady dospelého'),
      Lesson(id: 'ako_prezit_mesiac', title: 'Ako prežiť mesiac'),
      Lesson(id: 'dlhodobe_planovanie', title: 'Dlhodobé plánovanie'),
    ],
  ),
];
