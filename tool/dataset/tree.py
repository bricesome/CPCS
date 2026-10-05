def N(name, desc, expl="", f=None, profil=None, kids=None, sg=None, ex=None):
    return dict(name=name, desc=desc, expl=expl, f=f or {}, profil=profil, kids=kids or [], sg=sg or [], ex=ex)

TREE = [
 N("Sols minéraux bruts", "Sols sans évolution notable : matériau à peine altéré, quasi dépourvu de matière organique. Profil (A)C ou C.",
   "Imagine une roche ou un sable fraîchement exposé : aucun horizon n'a eu le temps ou les conditions pour se former. C'est le point de départ de toute pédogenèse.",
   f=dict(processus=["aucun"], complexe=["variable"], vegetation=["nulle"], aptitude=["faible", "conservation"], drainage=["excessif", "bon"]), profil="C ou (A)C",
   kids=[
    N("Sols minéraux bruts non climatiques", "L'absence d'évolution est due à un facteur local (érosion, apport récent, action humaine) et non au climat.",
      "Même sous un climat favorable, un sol peut rester brut si l'érosion le décape sans cesse ou si des dépôts frais le recouvrent.",
      f=dict(climat=["azonal"]), kids=[
       N("Sols minéraux bruts d'érosion", "Roche ou matériau mis à nu par l'érosion.", f=dict(topographie=["pente", "sommet"]), sg=["lithique", "regosolique"]),
       N("Sols minéraux bruts d'apport", "Dépôt récent (alluvial, colluvial, éolien, volcanique) n'ayant pas encore évolué.", f=dict(topographie=["plaine_alluviale", "bas_pente"]), sg=["alluvial", "colluvial", "eolien", "volcanique"]),
       N("Sols minéraux bruts anthropiques", "Matériaux remaniés ou déposés par l'homme (déblais, remblais, mines, carrières).", f=dict(materiau=["divers"], topographie=["toutes"]), sg=["modal"]),
      ]),
    N("Sols minéraux bruts climatiques", "L'absence d'évolution est imposée par le climat (froid extrême ou aridité).",
      "Sans eau liquide ou sans chaleur, l'altération chimique et la vie biologique sont bloquées.", kids=[
       N("Sols minéraux bruts xériques (désertiques)", "Déserts chauds : regs, hamadas, ergs. Très peu d'eau, végétation absente.", f=dict(climat=["aride"], topographie=["toutes"]), sg=["lithique", "eolien", "alluvial", "croute_saline"],
         ex="Regs et ergs du Sahara (nord du Niger, Ténéré)."),
       N("Sols minéraux bruts des déserts froids (cryiques)", "Régions polaires et haute montagne : le gel bloque l'évolution.", f=dict(climat=["froid", "montagnard"], topographie=["toutes"]), sg=["polygonal", "lithique"]),
      ]),
   ]),
 N("Sols peu évolués", "Début de pédogenèse : un horizon humifère A repose directement sur le matériau (profil AC). L'altération reste faible.",
   "On voit apparaître une couche plus sombre en surface (matière organique), mais le reste du profil ressemble encore beaucoup au matériau de départ.",
   f=dict(processus=["faible"], complexe=["variable"], drainage=["bon"]), profil="A C",
   kids=[
    N("Sols peu évolués à permagel (cryiques)", "Climat froid : un horizon humifère se forme mais le sol est gelé en profondeur.", f=dict(climat=["froid"], vegetation=["prairie"], aptitude=["faible", "paturage"]), kids=[
       N("Sols peu évolués humifères à permagel", "Horizon humifère sur sol gelé en permanence.", sg=["modal", "hydromorphe"]),
    ]),
    N("Sols peu évolués humifères", "Climat froid et humide (montagne) : la matière organique s'accumule sur un matériau peu altéré.", f=dict(climat=["montagnard", "froid"], vegetation=["prairie", "foret_resineux"], complexe=["desature"], aptitude=["paturage", "foret"]), kids=[
       N("Rankers", "Horizon A humifère acide directement sur roche siliceuse (granite, schiste).", "Le ranker est l'équivalent acide de la rendzine : même profil A sur roche, mais la roche est pauvre en calcium.",
         f=dict(materiau=["roche_acide"], topographie=["pente"]), profil="A R", sg=["modal", "lithique", "podzolique", "brunifie"]),
       N("Sols humifères lithocalciques", "Horizon humifère épais sur éboulis calcaires de montagne.", f=dict(materiau=["calcaire"]), sg=["modal"]),
    ]),
    N("Sols peu évolués xériques", "Climat aride ou subdésertique : un peu de matière organique et de calcaire, profil faiblement différencié.", f=dict(climat=["aride", "sahelien"], vegetation=["steppe"], complexe=["sature"], drainage=["excessif", "bon"], aptitude=["paturage"]), kids=[
       N("Sols gris subdésertiques", "Sols clairs, pauvres en matière organique, souvent calcaires ou gypseux, des marges désertiques.", sg=["modal", "encroutement_calcaire", "gypseux", "sale", "alcali"]),
    ]),
    N("Sols peu évolués non climatiques", "Le jeune âge du sol est dû à un facteur local : érosion permanente ou apport régulier de matériaux.",
      "C'est la sous-classe la plus répandue des sols jeunes, notamment dans les vallées et sur les dunes du Sahel.", f=dict(climat=["azonal"]), kids=[
       N("Sols peu évolués d'érosion", "Le sol est rajeuni en permanence par l'érosion sur les pentes.", f=dict(topographie=["pente"], aptitude=["conservation", "foret"]), sg=["lithique", "regosolique"]),
       N("Sols peu évolués d'apport", "Le sol se forme sur des dépôts régulièrement renouvelés (alluvions, colluvions, sables éoliens, cendres).", f=dict(topographie=["plaine_alluviale", "bas_pente"], aptitude=["cultures", "irrigation"]),
         sg=["alluvial", "colluvial", "eolien", "volcanique", "hydromorphe", "vertique", "sale"],
         ex="Alluvions du fleuve Niger, sols dunaires (« dior ») cultivés en mil."),
       N("Sols peu évolués anthropiques", "Sols jeunes issus de matériaux rapportés ou fortement remaniés par l'homme (terrasses, remblais).", f=dict(topographie=["toutes"], aptitude=["cultures"]), sg=["modal"]),
    ]),
   ]),
 N("Vertisols", "Sols argileux riches en argiles gonflantes (smectites) : larges fentes de retrait en saison sèche, faces de glissement luisantes, autobrassage (profil A(B)C homogène et sombre).",
   "Quand ils sèchent, les vertisols se fendent profondément ; quand ils se mouillent, ils gonflent et deviennent collants. Ce mouvement mélange le sol sur lui-même. Ils sont fertiles mais difficiles à travailler.",
   f=dict(processus=["vertisolisation"], materiau=["argile_gonflante", "roche_basique"], complexe=["sature"], climat=["tropical_sec", "sahelien", "mediterraneen", "steppique"], vegetation=["savane", "prairie"], aptitude=["irrigation", "cultures"], drainage=["temporaire"]),
   profil="A (B) C",
   kids=[
    N("Vertisols topomorphes (drainage externe nul ou réduit)", "En position basse (bas-fonds, plaines) : l'eau s'accumule, la topographie crée la vertisolisation.", f=dict(topographie=["depression", "plaine_alluviale"]), kids=[
       N("Vertisols topomorphes à structure arrondie en surface", "Surface grumeleuse à structure fine (« self-mulching ») sur au moins 15 cm.", sg=["modal", "hydromorphe", "sale", "alcali", "calcaire"]),
       N("Vertisols topomorphes à structure anguleuse dès la surface", "Structure prismatique ou en blocs dès la surface.", sg=["modal", "hydromorphe", "sale", "alcali", "gypseux"]),
    ]),
    N("Vertisols lithomorphes (drainage externe possible)", "Sur pentes faibles : c'est la roche-mère (basalte, marne) qui fournit les argiles gonflantes.", f=dict(topographie=["bas_pente", "pente"], materiau=["roche_basique", "argile_gonflante", "calcaire"], drainage=["bon"]), kids=[
       N("Vertisols lithomorphes à structure arrondie en surface", "Surface grumeleuse sur au moins 15 cm.", sg=["modal", "calcaire", "encroutement_calcaire"]),
       N("Vertisols lithomorphes à structure anguleuse dès la surface", "Structure anguleuse dès la surface.", sg=["modal", "calcaire", "gypseux"]),
    ]),
   ]),
 N("Andosols", "Sols développés sur matériaux volcaniques : riches en allophanes et en matière organique, très légers (densité faible), forte rétention d'eau et fixation du phosphore.",
   "Les cendres volcaniques s'altèrent vite en minéraux mal cristallisés qui piègent l'humus. Le sol est noir, très poreux et onctueux au toucher.",
   f=dict(processus=["andosolisation"], materiau=["volcanique"], topographie=["toutes"], drainage=["bon"], vegetation=["foret_feuillus", "foret_dense", "prairie"], aptitude=["cultures", "foret", "amendement"]), profil="A (B) C",
   kids=[
    N("Andosols des pays froids et tempérés", "Climats frais d'altitude ou tempérés humides.", f=dict(climat=["tempere_humide", "montagnard", "froid"]), kids=[
       N("Andosols humifères (désaturés)", "Très riches en humus, acides.", f=dict(complexe=["desature"]), sg=["modal", "podzolique", "hydromorphe"]),
       N("Andosols saturés", "Complexe riche en bases.", f=dict(complexe=["sature"]), sg=["modal", "brunifie"]),
       N("Andosols vitriques", "Encore riches en verres volcaniques non altérés.", f=dict(complexe=["variable"]), sg=["modal"]),
    ]),
    N("Andosols des pays tropicaux", "Volcans des régions tropicales humides.", f=dict(climat=["tropical_humide", "tropical_sec"]), kids=[
       N("Andosols tropicaux désaturés (humifères)", "Humifères et acides.", f=dict(complexe=["desature"]), sg=["modal", "hydromorphe", "rajeuni"]),
       N("Andosols tropicaux saturés", "Riches en bases, souvent sous climat à saison sèche.", f=dict(complexe=["sature"]), sg=["modal", "vertique"]),
       N("Andosols vitriques tropicaux", "Cendres récentes encore vitreuses.", f=dict(complexe=["variable"]), sg=["modal"]),
    ]),
   ]),
 N("Sols calcimagnésiques", "Sols dont l'évolution est dominée par le calcium ou le magnésium (calcaire, dolomie, gypse) : humus stable (mull calcique), structure grumeleuse, complexe saturé.",
   "Le calcaire agit comme un « frein » : il neutralise les acides et colle l'humus aux argiles. Le sol reste peu épais et peu différencié tant que le calcaire n'est pas dissous.",
   f=dict(processus=["calcimagnesique"], materiau=["calcaire"], complexe=["sature"], drainage=["bon"], climat=["azonal"], vegetation=["prairie", "foret_feuillus", "steppe"], aptitude=["cultures", "paturage"]), profil="A C ou A (B) C",
   kids=[
    N("Sols carbonatés", "Le calcaire actif est présent dans tout le profil.", kids=[
       N("Rendzines", "Horizon A humifère, foncé et grumeleux, directement sur la roche calcaire (profil A-C).", "La rendzine est le sol calcaire le plus simple : un horizon noir riche en humus posé sur des cailloux calcaires.",
         f=dict(topographie=["pente", "sommet"]), profil="A C", sg=["modal", "initial", "dolomitique", "brunifie", "humifere"]),
       N("Sols bruns calcaires", "Un horizon (B) brun d'altération apparaît, le calcaire reste présent dans tout le profil.", profil="A (B) C", sg=["modal", "encroutement_calcaire", "hydromorphe", "vertique"]),
       N("Sols humo-calcaires", "Très humifères, sur roches calcaires en climat frais.", f=dict(climat=["montagnard", "tempere_humide"]), sg=["modal", "hydromorphe"]),
    ]),
    N("Sols saturés (décarbonatés)", "Le calcaire a été dissous en surface, mais le complexe reste saturé en calcium.", kids=[
       N("Sols bruns calciques", "Profil A(B)C décarbonaté, saturé en calcium.", profil="A (B) C", sg=["modal", "lessive", "hydromorphe", "vertique"]),
       N("Sols humo-calciques", "Très humifères, décarbonatés mais saturés.", sg=["modal", "hydromorphe"]),
    ]),
    N("Sols gypseux", "Le gypse (sulfate de calcium) remplace le calcaire, surtout en climat aride.", f=dict(materiau=["gypse"], climat=["aride", "sahelien", "mediterraneen"], vegetation=["steppe"], aptitude=["paturage", "amendement"]), kids=[
       N("Rendzines gypseuses", "Horizon humifère sur gypse.", profil="A C", sg=["modal"]),
       N("Sols bruns gypseux", "Horizon (B) sur matériau gypseux.", profil="A (B) C", sg=["modal", "encroutement_calcaire", "sale"]),
    ]),
   ]),
 N("Sols isohumiques", "Sols à humus très évolué, incorporé profondément et progressivement (la teneur décroît régulièrement avec la profondeur), sous végétation herbacée de climat à saison sèche.",
   "Sous les prairies et les steppes, les racines des graminées meurent chaque année en profondeur : la matière organique s'installe dans tout le profil, ce qui donne des sols sombres, épais et fertiles.",
   f=dict(processus=["isohumique"], complexe=["sature"], drainage=["bon"], topographie=["sommet", "bas_pente"], vegetation=["prairie", "steppe"], materiau=["eolien", "divers"], aptitude=["cultures", "paturage"]), profil="A (B) C",
   kids=[
    N("Sols isohumiques à pédoclimat très humide en saison froide", "Climat tempéré continental humide.", f=dict(climat=["tempere_continental"], vegetation=["prairie"]), kids=[
       N("Brunizems", "Sols de prairie humide : épais, foncés, légèrement désaturés.", f=dict(complexe=["peu_desature"]), sg=["modal", "lessive", "hydromorphe", "vertique"]),
    ]),
    N("Sols isohumiques à pédoclimat frais en saison pluvieuse", "Steppes des climats continentaux (pluies au printemps-été, hiver froid).", f=dict(climat=["steppique", "tempere_continental"]), kids=[
       N("Chernozems", "Terres noires des steppes, très riches en humus, calcaire en profondeur.", "Les chernozems (« terre noire » en russe) sont parmi les sols les plus fertiles du monde : greniers à blé d'Ukraine et de Russie.",
         f=dict(materiau=["eolien"]), sg=["modal", "lessive", "encroutement_calcaire", "alcali"]),
       N("Sols châtains", "Couleur brun-châtain, moins d'humus que les chernozems, climat plus sec.", sg=["modal", "encroutement_calcaire", "alcali", "sale"]),
       N("Sols bruns steppiques", "Encore plus pauvres en humus, transition vers les sierozems.", sg=["modal", "encroutement_calcaire", "gypseux"]),
       N("Sierozems", "Sols gris des steppes désertiques, très faiblement humifères.", f=dict(climat=["aride", "steppique"], vegetation=["steppe"]), sg=["modal", "encroutement_calcaire", "gypseux", "sale"]),
    ]),
    N("Sols isohumiques à pédoclimat chaud en saison pluvieuse", "Régions subtropicales et tropicales sèches (pluies en saison chaude).", f=dict(climat=["sahelien", "mediterraneen", "aride"], vegetation=["steppe", "savane"]), kids=[
       N("Sols bruns subarides", "Sols bruns faiblement humifères des steppes à saison des pluies chaude.", "Très présents au Sahel (zones 300-500 mm) ; sols sableux à sablo-argileux, à protéger contre l'érosion éolienne.",
         sg=["modal", "encroutement_calcaire", "vertique", "hydromorphe", "sale", "alcali"], ex="Zones pastorales et agropastorales du Sahel nigérien."),
       N("Sols châtains subtropicaux", "Équivalents chauds des sols châtains.", sg=["modal", "encroutement_calcaire"]),
       N("Sols marron", "Sols bruns-rougeâtres sous végétation méditerranéenne sèche.", f=dict(climat=["mediterraneen"]), sg=["modal", "encroutement_calcaire", "vertique"]),
       N("Sols bruns-rouges subarides", "Teinte rouge plus marquée, climat plus chaud.", sg=["modal", "encroutement_calcaire", "sale"]),
       N("Sierozems subtropicaux", "Sols gris très pauvres en humus des marges désertiques chaudes.", f=dict(climat=["aride"]), sg=["modal", "gypseux", "sale"]),
    ]),
   ]),
 N("Sols brunifiés", "Sols à humus doux (mull) bien lié aux argiles et au fer : couleur brune, bonne structure, horizon (B) d'altération ou Bt d'accumulation d'argile.",
   "C'est le sol typique des forêts de feuillus et des campagnes tempérées. Le fer libéré par l'altération colore le sol en brun et stabilise la structure.",
   f=dict(processus=["brunification"], vegetation=["foret_feuillus"], drainage=["bon"], topographie=["toutes"], materiau=["divers"], aptitude=["cultures", "foret"]), profil="A (B) C ou A E Bt C",
   kids=[
    N("Sols brunifiés des pays tempérés humides", "Climat atlantique, pluies réparties sur l'année.", f=dict(climat=["tempere_humide"]), kids=[
       N("Sols bruns", "Profil A(B)C, horizon (B) brun d'altération sans accumulation d'argile.", profil="A (B) C", sg=["modal", "eutrophe", "acide", "ocreux", "lessive", "hydromorphe", "humifere"]),
       N("Sols lessivés", "L'argile migre de la surface (horizon E appauvri) vers la profondeur (horizon Bt).", "Le lessivage est un transport mécanique de l'argile par l'eau qui s'infiltre : la surface devient limoneuse et battante, la profondeur plus argileuse.",
         f=dict(processus=["brunification", "lessivage"]), profil="A E Bt C", sg=["modal", "glossique", "pseudogley", "degrade", "podzolique", "acide"]),
    ]),
    N("Sols brunifiés des pays tempérés continentaux", "Hivers froids, végétation de forêt-steppe.", f=dict(climat=["tempere_continental"]), kids=[
       N("Sols gris forestiers", "Transition entre chernozems et sols lessivés.", f=dict(processus=["brunification", "lessivage"]), sg=["modal", "lessive", "hydromorphe"]),
       N("Sols bruns continentaux", "Sols bruns sous forêts de climat continental.", sg=["modal", "lessive"]),
    ]),
    N("Sols brunifiés des pays tropicaux", "Climat tropical, sur roches riches en bases.", f=dict(climat=["tropical_sec", "tropical_humide"], materiau=["roche_basique"], complexe=["sature"]), kids=[
       N("Sols bruns eutrophes tropicaux", "Sols bruns riches en bases sur roches basiques, très fertiles.", f=dict(vegetation=["savane", "foret_feuillus"]), sg=["modal", "vertique", "hydromorphe", "ferrugineux"]),
    ]),
   ]),
 N("Sols podzolisés", "Sols acides où des complexes organiques entraînent le fer et l'aluminium vers la profondeur : horizon blanchi cendreux (E) au-dessus d'horizons d'accumulation sombres et rouille (Bh, Bs).",
   "Sous les landes et les forêts de résineux, la litière acide libère des acides qui « dissolvent » le fer et l'aluminium. Ceux-ci descendent et se déposent plus bas, laissant une couche blanche comme de la cendre.",
   f=dict(processus=["podzolisation"], materiau=["roche_acide", "eolien"], complexe=["desature"], vegetation=["foret_resineux"], drainage=["bon"], topographie=["toutes"], aptitude=["foret", "amendement"]), profil="O A E Bh Bs C",
   kids=[
    N("Sols podzolisés des climats tempérés", "Climats tempérés humides et frais.", f=dict(climat=["tempere_humide", "montagnard"]), kids=[
       N("Podzols", "Podzolisation complète : horizon E très net, B spodique épais.", profil="O A E Bh Bs C", sg=["humo_ferrugineux", "humique", "ferrugineux", "induré"]),
       N("Sols podzoliques", "Podzolisation moins marquée, horizon E discontinu.", sg=["modal", "lessive", "pseudogley"]),
       N("Sols ocre podzoliques", "Horizon B ocre riche en complexes alumino-humiques, sans E net (montagne).", sg=["modal", "humifere"]),
       N("Sols cryptopodzoliques humifères", "Podzolisation peu visible, très humifères (haute montagne).", f=dict(climat=["montagnard"]), sg=["cryptopodzolique"]),
    ]),
    N("Sols podzolisés des climats froids (boréaux)", "Taïga boréale.", f=dict(climat=["froid"]), kids=[
       N("Podzols boréaux", "Podzols sous taïga, souvent à permagel profond.", sg=["modal", "humo_ferrugineux"]),
    ]),
    N("Sols podzolisés hydromorphes", "La podzolisation s'accompagne d'un engorgement par une nappe.", f=dict(drainage=["temporaire", "permanent"], topographie=["depression", "plaine_alluviale"]), kids=[
       N("Podzols à gley", "Podzol avec nappe permanente en profondeur.", sg=["gley", "humique"]),
       N("Sols podzoliques à pseudogley", "Nappe perchée temporaire.", sg=["pseudogley"]),
       N("Podzols de nappe tropicaux", "Sables blancs des régions tropicales humides à nappe fluctuante.", f=dict(climat=["tropical_humide"], vegetation=["foret_dense"]), sg=["humique", "modal"]),
    ]),
   ]),
 N("Sols à sesquioxydes de fer", "Sols où les oxydes et hydroxydes de fer (sesquioxydes) s'individualisent et colorent le profil en rouge ou ocre ; argiles 2/1 (fersiallitiques) ou surtout kaolinite (ferrugineux).",
   "Sous climat chaud à saison sèche, le fer libéré par l'altération se concentre : couleurs rouges, taches, concrétions, voire cuirasses. Ce sont les sols les plus courants d'Afrique de l'Ouest soudano-sahélienne.",
   f=dict(drainage=["bon"], topographie=["sommet", "bas_pente", "pente"], materiau=["divers"], vegetation=["savane"], aptitude=["cultures"]), profil="A (B) C ou A E Bt C",
   kids=[
    N("Sols fersiallitiques", "Climats méditerranéen et subtropical : fer cristallisé (hématite), argiles 2/1 conservées, complexe saturé ou peu désaturé (« sols rouges méditerranéens »).", f=dict(processus=["fersiallitisation"], climat=["mediterraneen"], vegetation=["foret_feuillus", "steppe"]), kids=[
       N("Sols fersiallitiques à réserve calcique", "Calcaire ou complexe saturé en profondeur (terra rossa).", f=dict(complexe=["sature"], materiau=["calcaire"]), sg=["modal", "encroutement_calcaire", "vertique", "lessive"]),
       N("Sols fersiallitiques sans réserve calcique", "Complexe peu désaturé, souvent lessivés.", f=dict(complexe=["peu_desature"]), sg=["modal", "lessive", "hydromorphe", "rouge"]),
       N("Sols fersiallitiques acides", "Complexe désaturé, transition vers les sols ferrallitiques.", f=dict(complexe=["desature"]), sg=["modal", "lessive"]),
    ]),
    N("Sols ferrugineux tropicaux", "Climat tropical à saison sèche marquée : kaolinite dominante, fer individualisé en taches et concrétions, complexe peu désaturé.",
      "Sols de base de l'agriculture pluviale soudano-sahélienne (mil, sorgho, arachide, coton). Ils sont fragiles : battance, érosion, cuirassement si on les dénude.",
      f=dict(processus=["ferruginisation"], climat=["tropical_sec", "sahelien"], complexe=["peu_desature"], aptitude=["cultures", "conservation", "foret"]), kids=[
       N("Sols ferrugineux tropicaux peu lessivés", "Pas ou peu de migration d'argile ; souvent sableux (zone sahélienne).", f=dict(materiau=["eolien", "roche_acide"]), sg=["modal", "tache", "concretions", "hydromorphe"],
         ex="Sols « dior » et sols dunaires fixés du Sahel."),
       N("Sols ferrugineux tropicaux lessivés", "Horizon E appauvri et Bt d'accumulation d'argile ; fréquents en zone soudanienne.", f=dict(processus=["ferruginisation", "lessivage"]), profil="A E Bt C",
         sg=["modal", "tache", "concretions", "induré", "cuirasse", "hydromorphe"], ex="Plateaux cuirassés et glacis du Burkina Faso et du sud-ouest du Niger."),
       N("Sols ferrugineux tropicaux appauvris", "Départ latéral d'argile en surface, sans Bt marqué.", sg=["modal", "tache", "hydromorphe"]),
    ]),
   ]),
 N("Sols ferrallitiques", "Altération totale des minéraux primaires : perte de la silice et des bases, accumulation de kaolinite, d'hydroxydes de fer (goethite, hématite) et d'aluminium (gibbsite). Profils très épais, couleurs rouges ou jaunes.",
   "Sous climat chaud et humide, des siècles de pluie « lavent » la roche jusqu'à ne laisser que les éléments les plus insolubles : fer et aluminium. Le sol est profond mais chimiquement pauvre.",
   f=dict(processus=["ferrallitisation"], climat=["tropical_humide"], vegetation=["foret_dense", "savane"], drainage=["bon"], topographie=["sommet", "pente"], materiau=["divers"], aptitude=["foret", "cultures", "amendement"]), profil="A B C (très épais)",
   kids=[
    N("Sols ferrallitiques faiblement désaturés", "Saison sèche marquée, complexe encore assez riche en bases.", f=dict(complexe=["peu_desature"], climat=["tropical_humide", "tropical_sec"]), kids=[
       N("Sols ferrallitiques faiblement désaturés typiques", "Profil complet, sans caractère secondaire.", sg=["rouge", "jaune", "modal"]),
       N("Sols ferrallitiques faiblement désaturés appauvris", "Surface appauvrie en argile.", sg=["modal", "concretions", "induré"]),
       N("Sols ferrallitiques faiblement désaturés remaniés", "Horizons supérieurs remaniés, ligne de cailloux.", sg=["remanie", "modal"]),
       N("Sols ferrallitiques faiblement désaturés rajeunis", "Érosion ayant réexposé un matériau moins altéré.", sg=["rajeuni"]),
       N("Sols ferrallitiques faiblement désaturés lessivés", "Migration verticale d'argile.", f=dict(processus=["ferrallitisation", "lessivage"]), sg=["modal", "hydromorphe"]),
    ]),
    N("Sols ferrallitiques moyennement désaturés", "Climat humide à courte saison sèche.", f=dict(complexe=["peu_desature"]), kids=[
       N("Sols ferrallitiques moyennement désaturés typiques", "Profil complet.", sg=["rouge", "jaune", "modal"]),
       N("Sols ferrallitiques moyennement désaturés humifères", "Horizon humifère épais (altitude).", f=dict(climat=["tropical_humide", "montagnard"]), sg=["humifere"]),
       N("Sols ferrallitiques moyennement désaturés appauvris", "Surface appauvrie.", sg=["modal", "concretions"]),
       N("Sols ferrallitiques moyennement désaturés remaniés", "Profil remanié.", sg=["remanie", "induré"]),
       N("Sols ferrallitiques moyennement désaturés rajeunis", "Rajeunis par l'érosion.", sg=["rajeuni"]),
    ]),
    N("Sols ferrallitiques fortement désaturés", "Climat équatorial très humide : complexe très pauvre, aluminium échangeable.", f=dict(complexe=["desature"]), kids=[
       N("Sols ferrallitiques fortement désaturés typiques", "Profil complet.", sg=["rouge", "jaune", "modal"]),
       N("Sols ferrallitiques fortement désaturés humifères", "Très humifères (altitude).", f=dict(climat=["tropical_humide", "montagnard"]), sg=["humifere"]),
       N("Sols ferrallitiques fortement désaturés appauvris", "Surface appauvrie.", sg=["modal", "hydromorphe"]),
       N("Sols ferrallitiques fortement désaturés remaniés", "Profil remanié.", sg=["remanie", "induré"]),
       N("Sols ferrallitiques fortement désaturés rajeunis", "Rajeunis par l'érosion.", sg=["rajeuni"]),
       N("Sols ferrallitiques fortement désaturés podzoliques", "Début de podzolisation sur matériaux sableux.", f=dict(processus=["ferrallitisation", "podzolisation"]), sg=["podzolique"]),
    ]),
   ]),
 N("Sols hydromorphes", "Sols marqués par un excès d'eau prolongé : réduction du fer (gley gris-bleu), alternance oxydation/réduction (pseudogley à taches rouille), ou accumulation de matière organique (tourbe, anmoor).",
   "Quand l'eau chasse l'air du sol, les micro-organismes utilisent le fer à la place de l'oxygène : il devient soluble et gris. Là où l'air revient, il rouille en taches orangées.",
   f=dict(processus=["hydromorphie"], climat=["azonal"], topographie=["depression", "plaine_alluviale", "littoral"], drainage=["permanent", "temporaire"], vegetation=["hygrophile"], materiau=["alluvions", "divers"], complexe=["variable"], aptitude=["irrigation"]), profil="A G ou A g",
   kids=[
    N("Sols hydromorphes organiques", "Plus de 30 % de matière organique sur au moins 40 cm : tourbes.", "La tourbe se forme quand les débris végétaux s'accumulent dans l'eau plus vite qu'ils ne se décomposent.",
      f=dict(materiau=["organique"], drainage=["permanent"], aptitude=["faible", "conservation"]), profil="H (horizons tourbeux)", kids=[
       N("Sols tourbeux fibreux", "Tourbe peu décomposée.", sg=["oligotrophe", "mesotrophe", "eutrophe"]),
       N("Sols tourbeux semi-fibreux", "Tourbe moyennement décomposée.", sg=["oligotrophe", "mesotrophe", "eutrophe"]),
       N("Sols tourbeux altérés", "Tourbe très décomposée (saprique).", sg=["oligotrophe", "mesotrophe", "eutrophe"]),
    ]),
    N("Sols hydromorphes moyennement organiques", "Horizon humifère épais (8 à 30 % de matière organique) sur horizon minéral engorgé.", f=dict(drainage=["permanent"]), kids=[
       N("Sols humiques à gley", "Horizon humifère sur gley.", sg=["modal", "calcaire", "acide", "sale"]),
       N("Sols à anmoor", "Humus noir, pâteux, mêlé à la matière minérale.", sg=["modal", "calcaire", "acide"]),
       N("Sols tourbeux à gley", "Mince horizon tourbeux sur gley.", sg=["modal"]),
    ]),
    N("Sols hydromorphes minéraux ou peu humifères", "Moins de 8 % de matière organique : l'hydromorphie se lit surtout dans les couleurs.", kids=[
       N("Sols hydromorphes à gley", "Nappe permanente : horizon gris-bleu réduit.", f=dict(drainage=["permanent"]), profil="A Go Gr", sg=["modal", "lessive", "sale", "vertique", "calcaire"],
         ex="Bas-fonds rizicoles et vallées des « dallols » au Niger."),
       N("Sols hydromorphes à pseudogley", "Nappe perchée temporaire : horizon bariolé (gris et rouille).", f=dict(drainage=["temporaire"]), profil="A g", sg=["modal", "tache", "concretions", "lessive", "induré"]),
       N("Sols hydromorphes à redistribution du calcaire ou du gypse", "La nappe redistribue le calcaire ou le gypse (amas, encroûtements).", f=dict(materiau=["calcaire", "gypse"], complexe=["sature"]), sg=["encroutement_calcaire", "gypseux", "sale"]),
       N("Sols hydromorphes à amphigley", "Engorgement à la fois par une nappe profonde et une nappe perchée.", f=dict(drainage=["permanent", "temporaire"]), sg=["modal"]),
    ]),
   ]),
 N("Sols sodiques (salsodiques)", "Sols dominés par les sels solubles ou par le sodium échangeable : salure (conductivité élevée) et/ou alcalisation (pH > 8,5, argiles dispersées, structure dégradée).",
   "L'eau qui s'évapore laisse ses sels : en excès, ils assoiffent les plantes. Si le sodium prend la place du calcium sur les argiles, le sol devient compact, imperméable et très alcalin.",
   f=dict(processus=["salinisation", "sodisation"], materiau=["sale", "alluvions"], climat=["aride", "sahelien", "azonal"], topographie=["depression", "littoral", "plaine_alluviale"], drainage=["nappe_salee", "temporaire"], complexe=["sodique"], vegetation=["hygrophile", "steppe"], aptitude=["amendement", "paturage", "faible"]), profil="A C ou A Btna C",
   kids=[
    N("Sols sodiques à structure non dégradée", "Les sels solubles dominent : la structure reste floconneuse (salins).", f=dict(processus=["salinisation"]), kids=[
       N("Sols salins (solontchaks)", "Fortes teneurs en sels solubles, efflorescences blanches en surface, pH < 8,5.", "Reconnaissables à leur croûte blanche en saison sèche ; on les récupère par lessivage à l'eau douce et drainage.",
         sg=["modal", "croute_saline", "chlorure", "hydromorphe", "gypseux"]),
       N("Sols salins à alcali", "Salés et à sodium échangeable élevé, structure encore stable grâce aux sels.", f=dict(complexe=["sodique"]), sg=["modal", "hydromorphe"]),
    ]),
    N("Sols sodiques à structure dégradée", "Le sodium a dispersé les argiles : structure massive ou en colonnettes, pH élevé.", f=dict(processus=["sodisation"]), kids=[
       N("Sols à alcali non lessivés", "Sodium dans tout le profil, structure massive, pH > 8,5.", sg=["modal", "hydromorphe", "vertique"]),
       N("Sols à alcali lessivés (solonetz)", "Horizon Bt à structure en colonnettes riche en sodium.", "Le gypse est le remède classique : son calcium remplace le sodium, puis l'eau entraîne le sodium.",
         profil="A E Btna C", sg=["modal", "solodise", "hydromorphe"]),
       N("Solods", "Stade final : sodium lessivé, horizon supérieur acide et blanchi.", f=dict(complexe=["desature"]), sg=["modal", "hydromorphe"]),
    ]),
   ]),
]
