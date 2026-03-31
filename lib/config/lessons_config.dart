import '../models/lesson.dart';

const List<LessonCategory> LESSON_CATEGORIES = [
  LessonCategory(
    id: 'peniaze_ako_koncept',
    title: 'Peniaze ako koncept',
    lessons: [
      Lesson(id: 'co_su_peniaze', title: 'Čo sú peniaze'),
      Lesson(id: 'preco_peniaze_existuju', title: 'Prečo peniaze existujú'),
      Lesson(id: 'ako_ludia_platili_kedysi', title: 'Ako ľudia platili kedysi'),
      Lesson(id: 'mince_bankovky_digitalne', title: 'Mince, bankovky, digitálne peniaze'),
      Lesson(id: 'hodnota_peniazi', title: 'Hodnota peňazí'),
      Lesson(id: 'peniaze_nie_su_nekonecne', title: 'Peniaze nie sú nekonečné'),
      Lesson(id: 'odkial_peniaze_prichadzaju', title: 'Odkiaľ peniaze prichádzajú'),
    ],
  ),
  LessonCategory(
    id: 'potreby_vs_tuzby',
    title: 'Potreby vs túžby',
    lessons: [
      Lesson(id: 'co_potrebujem_na_zivot', title: 'Čo potrebujem na život'),
      Lesson(id: 'co_len_chcem', title: 'Čo len chcem'),
      Lesson(id: 'preco_chceme_vec', title: 'Prečo chceme veci, ktoré nepotrebujeme'),
      Lesson(id: 'reklama_vplyv', title: 'Reklama a jej vplyv'),
      Lesson(id: 'emocionalne_nakupovanie', title: 'Emocionálne nakupovanie'),
    ],
  ),
  LessonCategory(
    id: 'prve_hospodarenie',
    title: 'Prvé hospodárenie s peniazmi',
    lessons: [
      Lesson(id: 'vreckove', title: 'Vreckové'),
      Lesson(id: 'ako_si_rozdelit_peniaze', title: 'Ako si rozdeliť peniaze'),
      Lesson(id: 'minut_teraz_vs_neskor', title: 'Minúť teraz vs neskôr'),
      Lesson(id: 'preco_sa_oplati_planovat', title: 'Prečo sa oplatí plánovať'),
      Lesson(id: 'male_financne_chyby', title: 'Malé finančné chyby'),
    ],
  ),
  LessonCategory(
    id: 'sporenie',
    title: 'Sporenie',
    lessons: [
      Lesson(id: 'co_je_sporenie', title: 'Čo je sporenie'),
      Lesson(id: 'preco_si_odkladat', title: 'Prečo si odkladať peniaze'),
      Lesson(id: 'kratkodoby_vs_dlhodoby', title: 'Krátkodobý cieľ vs dlhodobý cieľ'),
      Lesson(id: 'ako_si_vytvorit_rezervu', title: 'Ako si vytvoriť rezervu'),
      Lesson(id: 'pravidelne_male_sumy', title: 'Pravidelné malé sumy'),
    ],
  ),
  LessonCategory(
    id: 'cena_a_hodnota',
    title: 'Cena a hodnota',
    lessons: [
      Lesson(id: 'cena_vs_kvalita', title: 'Cena vs kvalita'),
      Lesson(id: 'lacne_vs_drahe', title: 'Lacné vs drahé'),
      Lesson(id: 'vyhodna_kupa', title: 'Čo znamená výhodná kúpa'),
      Lesson(id: 'porovnavanie_cien', title: 'Porovnávanie cien'),
      Lesson(id: 'jednotkova_cena', title: 'Jednotková cena'),
    ],
  ),
  LessonCategory(
    id: 'nakupovanie_a_rozhodovanie',
    title: 'Nakupovanie a rozhodovanie',
    lessons: [
      Lesson(id: 'ako_funguje_obchod', title: 'Ako funguje obchod'),
      Lesson(id: 'zlavy', title: 'Zľavy'),
      Lesson(id: 'marketingove_triky', title: 'Akcie a marketingové triky'),
      Lesson(id: 'impulzivne_nakupy', title: 'Impulzívne nákupy'),
      Lesson(id: 'ako_nenaletiet_na_reklamu', title: 'Ako nenaletieť na reklamu'),
    ],
  ),
  LessonCategory(
    id: 'peniaze_v_rodine',
    title: 'Peniaze v rodine',
    lessons: [
      Lesson(id: 'odkial_rodina_berie_peniaze', title: 'Odkiaľ rodina berie peniaze'),
      Lesson(id: 'vydavky_domacnosti', title: 'Výdavky domácnosti'),
      Lesson(id: 'byvanie_stoji_peniaze', title: 'Bývanie stojí peniaze'),
      Lesson(id: 'jedlo_stoji_peniaze', title: 'Jedlo stojí peniaze'),
      Lesson(id: 'energie_stoja_peniaze', title: 'Energie stoja peniaze'),
    ],
  ),
  LessonCategory(
    id: 'praca_a_prijem',
    title: 'Práca a príjem',
    lessons: [
      Lesson(id: 'preco_ludia_pracuju', title: 'Prečo ľudia pracujú'),
      Lesson(id: 'typy_povolani', title: 'Typy povolaní'),
      Lesson(id: 'plat_a_odmena', title: 'Plat a odmena'),
      Lesson(id: 'cas_je_hodnota', title: 'Čas = hodnota'),
      Lesson(id: 'produktivita', title: 'Produktivita'),
    ],
  ),
  LessonCategory(
    id: 'rozpocet',
    title: 'Rozpočet',
    lessons: [
      Lesson(id: 'co_je_rozpocet', title: 'Čo je rozpočet'),
      Lesson(id: 'prijmy_a_vydavky', title: 'Príjmy a výdavky'),
      Lesson(id: 'mesacne_planovanie', title: 'Mesačné plánovanie'),
      Lesson(id: 'fixne_vydavky', title: 'Fixné výdavky'),
      Lesson(id: 'variabilne_vydavky', title: 'Variabilné výdavky'),
    ],
  ),
  LessonCategory(
    id: 'banky_a_ucty',
    title: 'Banky a účty',
    lessons: [
      Lesson(id: 'co_robi_banka', title: 'Čo robí banka'),
      Lesson(id: 'bankovy_ucet', title: 'Bankový účet'),
      Lesson(id: 'platobna_karta', title: 'Platobná karta'),
      Lesson(id: 'pin', title: 'PIN'),
      Lesson(id: 'prevod_peniazi', title: 'Prevod peňazí'),
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
