# Labo : paramètres mesurés sur le terrain et profils attendus des sous-classes.
# Le calcul (même règle que l'application) est décrit dans analyse() ci-dessous.
from facets import FACETS

def _facet(name, exclude=()):
    return [(k, v[0], v[1]) for k, v in FACETS[name][2].items() if k not in exclude]

# kind="choice" : options (id, libellé, explication)
# kind="range"  : min, max, step, unit, tol (tolérance : à moins de tol hors de la plage, demi-point)
PARAMS = [
 dict(id="horizons", label="Horizons visibles", kind="choice", weight=3,
      expl="Les couches que l'on voit en creusant une fosse. Leur succession est le meilleur indice du processus qui a formé le sol.",
      options=[
       ("aucun", "Aucun horizon : roche ou matériau presque intact", "Pas de couche sombre en surface, le matériau est à peine transformé."),
       ("a_c", "Un horizon sombre (A) directement sur le matériau", "Une couche plus foncée en surface, puis tout de suite la roche ou le matériau d'origine."),
       ("a_b_c", "A, puis un horizon brun d'altération (B), puis le matériau", "Entre la surface et la roche, une couche brune transformée, sans accumulation nette."),
       ("argile", "Horizon clair appauvri sur un horizon enrichi en argile", "L'argile a migré : la couche du haut est plus claire et légère, celle du bas plus collante."),
       ("cendreux", "Horizon blanchi cendreux sur un horizon sombre ou rouille", "Couche gris-blanc comme de la cendre, au-dessus d'une couche noire ou couleur rouille."),
       ("concretions", "Taches, concrétions ou cuirasse de fer", "Petites billes dures rouges/noires, taches ocre, ou carapace durcie."),
       ("alteration", "Altération rouge ou ocre très épaisse (plusieurs mètres)", "La roche est pourrie sur une grande épaisseur ; tout le profil est rouge ou jaune."),
      ]),
 dict(id="couleur", label="Couleur dominante", kind="choice", weight=2,
      expl="La couleur révèle la matière organique (noir), le fer oxydé (rouge, ocre) ou l'excès d'eau (gris-bleu, taches rouille).",
      options=[
       ("noir", "Noir", "Riche en matière organique bien décomposée."),
       ("brun_fonce", "Brun foncé", "Matière organique assez abondante liée à l'argile."),
       ("brun", "Brun", "Humus actif et fer peu cristallisé (sols brunifiés)."),
       ("rouge", "Rouge", "Fer oxydé sous forme d'hématite, sol bien aéré."),
       ("ocre", "Ocre / jaune", "Fer oxydé hydraté (goethite)."),
       ("beige", "Beige / gris clair", "Pauvre en matière organique, souvent calcaire ou en climat sec."),
       ("blanc", "Blanc / cendreux", "Matériau lavé de son fer et de son humus, ou couvert de sels."),
       ("gris_bleu", "Gris-bleu / verdâtre", "Fer réduit : eau stagnante en permanence (gley)."),
       ("bariole", "Gris taché de rouille", "Alternance d'engorgement et d'assèchement (pseudogley)."),
      ]),
 dict(id="texture", label="Texture (toucher)", kind="choice", weight=2,
      expl="Ce que l'on sent en frottant un peu de terre humide entre les doigts.",
      options=[
       ("sableuse", "Sableuse : rugueuse, ne colle pas", "Les grains se sentent et ne tiennent pas ensemble."),
       ("limoneuse", "Limoneuse : douce, farineuse", "Toucher soyeux, comme du talc."),
       ("argileuse", "Argileuse : collante, plastique", "On peut modeler un boudin qui ne casse pas."),
       ("volcanique", "Très légère, onctueuse (cendres volcaniques)", "Terre très légère, grasse au toucher, sur cendres ou lapillis."),
       ("organique", "Fibreuse, tourbe", "Débris végétaux peu décomposés, spongieux."),
       ("caillouteuse", "Caillouteuse", "Beaucoup de cailloux ou de graviers."),
      ]),
 dict(id="structure", label="Structure", kind="choice", weight=2,
      expl="La façon dont la terre s'assemble en mottes.",
      options=[
       ("grumeleuse", "Grumeleuse : petites mottes rondes", "Structure aérée, signe d'une bonne activité biologique."),
       ("particulaire", "Particulaire : grains libres", "Pas de mottes : le sable coule entre les doigts."),
       ("fentes", "Larges fentes et faces luisantes", "En saison sèche, fentes de plus de 1 cm ; mottes à faces lisses et brillantes."),
       ("colonnes", "Colonnes ou prismes très durs", "Gros blocs verticaux à sommet arrondi, très compacts (excès de sodium)."),
       ("massive", "Massive / compacte", "Pas d'agrégats nets, bloc compact."),
      ]),
 dict(id="effervescence", label="Effervescence à l'acide (calcaire)", kind="choice", weight=2,
      expl="Une goutte d'acide chlorhydrique dilué fait mousser le calcaire. Test simple pour savoir si le sol est calcaire.",
      options=[
       ("aucune", "Aucune", "Pas de calcaire libre."),
       ("faible", "Faible", "Quelques bulles : un peu de calcaire."),
       ("forte", "Forte", "Forte mousse : sol riche en calcaire."),
      ]),
 dict(id="eau", label="Excès d'eau", kind="choice", weight=3,
      expl="Le sol reste-t-il gorgé d'eau ? L'excès d'eau prive le sol d'oxygène et change sa couleur.",
      options=[
       ("jamais", "Jamais engorgé, bien drainé", "L'eau s'infiltre ou s'écoule rapidement."),
       ("temporaire", "Engorgé une partie de l'année", "Taches rouille et grises : l'eau stagne pendant la saison des pluies."),
       ("permanent", "Engorgé en permanence", "Nappe d'eau proche de la surface toute l'année."),
      ]),
 dict(id="pente", label="Position / pente", kind="choice", weight=1,
      expl="La position dans le paysage : l'eau et les matériaux descendent des pentes vers les bas-fonds.",
      options=[
       ("depression", "Bas-fond / dépression", "Point bas où l'eau s'accumule."),
       ("plat", "Plaine ou plateau plat", "Terrain horizontal."),
       ("faible", "Pente faible (moins de 5 %)", "Légère inclinaison."),
       ("forte", "Pente forte (plus de 5 %)", "Versant marqué, érosion possible."),
      ]),
 dict(id="climat", label="Climat", kind="choice", weight=2,
      expl="Le climat de la région règle l'intensité de l'altération et le bilan d'eau.",
      options=_facet("climat", exclude=("azonal",))),
 dict(id="vegetation", label="Végétation", kind="choice", weight=1,
      expl="La végétation naturelle du lieu fournit la matière organique et reflète le climat.",
      options=_facet("vegetation", exclude=("variee",))),
 dict(id="profondeur", label="Profondeur du sol", kind="range", weight=1, min=0, max=300, step=5, unit="cm", tol=15,
      expl="Épaisseur de terre au-dessus de la roche dure ou du matériau non transformé."),
 dict(id="ph", label="pH (eau)", kind="range", weight=2, min=3.0, max=10.5, step=0.1, unit="", tol=0.3,
      expl="Acidité du sol : moins de 5,5 = acide, 6,5 à 7,5 = neutre, plus de 8,5 = très alcalin (sodium)."),
 dict(id="mo", label="Matière organique", kind="range", weight=2, min=0, max=80, step=0.5, unit="%", tol=0.5,
      expl="Part de matière organique dans l'horizon de surface. Moins de 1 % : très pauvre ; plus de 30 % : tourbe."),
 dict(id="ce", label="Salinité (conductivité)", kind="range", weight=3, min=0, max=40, step=0.5, unit="dS/m", tol=1,
      expl="Conductivité électrique de l'extrait de sol : au-delà de 4 dS/m, le sol est salé."),
]

NON_SALE = dict(ce=(0, 4))

# Profil attendu par classe, puis précisions par sous-classe (elles remplacent la valeur de la classe).
PROFILES = {
 "I":   dict(NON_SALE, horizons=["aucun"], mo=(0, 1), structure=["particulaire", "massive"], vegetation=["nulle", "steppe"]),
 "I.1": dict(),
 "I.2": dict(climat=["aride", "froid", "montagnard"]),
 "II":  dict(NON_SALE, horizons=["a_c"], mo=(1, 5)),
 "II.1": dict(climat=["froid"]),
 "II.2": dict(climat=["montagnard", "froid"], mo=(5, 20), ph=(4, 6), couleur=["noir", "brun_fonce"]),
 "II.3": dict(climat=["aride", "sahelien"], mo=(0, 1.5), ph=(7, 8.5), couleur=["beige"], vegetation=["steppe"]),
 "II.4": dict(),
 "III": dict(NON_SALE, texture=["argileuse"], structure=["fentes"], ph=(6.5, 8.5), couleur=["noir", "brun_fonce"],
             climat=["tropical_sec", "sahelien", "mediterraneen", "steppique"], pente=["depression", "plat", "faible"], profondeur=(50, 200), mo=(1, 4)),
 "III.1": dict(pente=["depression", "plat"], eau=["temporaire"]),
 "III.2": dict(pente=["faible"], eau=["jamais"]),
 "IV":  dict(NON_SALE, texture=["volcanique"], mo=(5, 30), ph=(4.5, 6.5), couleur=["noir", "brun_fonce"], structure=["grumeleuse"], eau=["jamais"]),
 "IV.1": dict(climat=["tempere_humide", "montagnard", "froid"]),
 "IV.2": dict(climat=["tropical_humide", "tropical_sec"]),
 "V":   dict(NON_SALE, eau=["jamais"], structure=["grumeleuse"], profondeur=(10, 60), horizons=["a_c", "a_b_c"]),
 "V.1": dict(effervescence=["forte"], ph=(7.8, 8.7), couleur=["noir", "brun_fonce", "beige"]),
 "V.2": dict(effervescence=["aucune", "faible"], ph=(6.5, 7.7), couleur=["brun_fonce", "brun"]),
 "V.3": dict(effervescence=["aucune", "faible"], ph=(7, 8.5), ce=(2, 8), couleur=["beige", "blanc"], climat=["aride", "sahelien", "mediterraneen"]),
 "VI":  dict(NON_SALE, mo=(2, 8), structure=["grumeleuse"], eau=["jamais"], profondeur=(60, 200), pente=["plat", "faible"],
             vegetation=["prairie", "steppe"], horizons=["a_c", "a_b_c"]),
 "VI.1": dict(climat=["tempere_continental"], ph=(5.5, 7), couleur=["brun_fonce", "noir"], effervescence=["aucune"], vegetation=["prairie"]),
 "VI.2": dict(climat=["steppique", "tempere_continental"], ph=(7, 8.5), couleur=["noir", "brun_fonce"], effervescence=["faible", "forte"]),
 "VI.3": dict(climat=["sahelien", "mediterraneen", "aride"], ph=(7, 8.5), couleur=["brun", "beige"], mo=(0.5, 3), vegetation=["steppe", "savane"]),
 "VII": dict(NON_SALE, couleur=["brun"], ph=(5, 7), mo=(2, 8), structure=["grumeleuse"], horizons=["a_b_c", "argile"], eau=["jamais"],
             profondeur=(40, 150), vegetation=["foret_feuillus"], effervescence=["aucune"]),
 "VII.1": dict(climat=["tempere_humide"]),
 "VII.2": dict(climat=["tempere_continental"]),
 "VII.3": dict(climat=["tropical_sec", "tropical_humide"], ph=(6, 7.5)),
 "VIII": dict(NON_SALE, horizons=["cendreux"], couleur=["blanc"], texture=["sableuse"], ph=(3.5, 5.5), vegetation=["foret_resineux"],
              eau=["jamais"], structure=["particulaire"], effervescence=["aucune"]),
 "VIII.1": dict(climat=["tempere_humide", "montagnard"]),
 "VIII.2": dict(climat=["froid"]),
 "VIII.3": dict(eau=["temporaire", "permanent"], pente=["depression", "plat"]),
 "IX":  dict(NON_SALE, eau=["jamais"], effervescence=["aucune"]),
 "IX.1": dict(couleur=["rouge"], climat=["mediterraneen"], ph=(6, 8), horizons=["a_b_c", "argile"], profondeur=(50, 200), vegetation=["foret_feuillus", "steppe"]),
 "IX.2": dict(couleur=["ocre", "rouge"], climat=["tropical_sec", "sahelien"], horizons=["concretions", "argile"], ph=(5.5, 7),
              texture=["sableuse", "limoneuse"], mo=(0.3, 2), vegetation=["savane"]),
 "X":   dict(NON_SALE, climat=["tropical_humide"], couleur=["rouge", "ocre"], horizons=["alteration"], profondeur=(150, 300),
             texture=["argileuse", "limoneuse"], eau=["jamais"], effervescence=["aucune"], vegetation=["foret_dense", "savane"]),
 "X.1": dict(ph=(5.6, 6.5), climat=["tropical_humide", "tropical_sec"]),
 "X.2": dict(ph=(5.0, 5.5)),
 "X.3": dict(ph=(4.0, 4.9)),
 "XI":  dict(NON_SALE, eau=["permanent", "temporaire"], couleur=["gris_bleu", "bariole", "noir"], pente=["depression", "plat"], vegetation=["hygrophile"]),
 "XI.1": dict(texture=["organique"], mo=(30, 80), couleur=["noir"], eau=["permanent"]),
 "XI.2": dict(mo=(8, 29.5), eau=["permanent"], couleur=["noir", "gris_bleu"]),
 "XI.3": dict(mo=(0, 7.5), couleur=["gris_bleu", "bariole"]),
 "XII": dict(pente=["depression", "plat"], climat=["aride", "sahelien", "mediterraneen", "steppique"], ph=(7.5, 10.5)),
 "XII.1": dict(ce=(4, 40), ph=(7.5, 8.5), structure=["grumeleuse", "particulaire", "massive"], couleur=["beige", "blanc", "gris_bleu"]),
 "XII.2": dict(ph=(8.5, 10.5), structure=["colonnes", "massive"]),
}

# Échantillons d'exemple : (nom, mesures, sous-classe attendue en tête).
PRESETS = [
 ("Sol rouge profond de forêt tropicale", dict(climat="tropical_humide", couleur="rouge", profondeur=250, horizons="alteration", ph=4.5, eau="jamais", vegetation="foret_dense"), "X.3"),
 ("Argile noire à fentes d'une plaine sahélienne", dict(climat="sahelien", texture="argileuse", structure="fentes", couleur="noir", ph=7.8, pente="depression", eau="temporaire"), "III.1"),
 ("Sable blanc cendreux sous les pins", dict(climat="tempere_humide", horizons="cendreux", couleur="blanc", texture="sableuse", ph=4.0, vegetation="foret_resineux"), "VIII.1"),
 ("Bas-fond gris engorgé toute l'année", dict(eau="permanent", couleur="gris_bleu", pente="depression", mo=3, vegetation="hygrophile"), "XI.3"),
 ("Croûte blanche salée en bordure de mare", dict(ce=15, ph=8.2, couleur="blanc", pente="depression", climat="sahelien"), "XII.1"),
 ("Sol ocre à concrétions de savane soudanienne", dict(climat="tropical_sec", couleur="ocre", horizons="concretions", texture="sableuse", ph=6.2, vegetation="savane"), "IX.2"),
 ("Sol brun forestier tempéré", dict(climat="tempere_humide", couleur="brun", horizons="a_b_c", ph=6.0, mo=4, vegetation="foret_feuillus"), "VII.1"),
 ("Sol sombre et peu épais sur calcaire", dict(effervescence="forte", ph=8.2, profondeur=30, couleur="noir", structure="grumeleuse"), "V.1"),
 ("Sol noir léger sur cendres volcaniques", dict(texture="volcanique", couleur="noir", mo=12, ph=5.5, climat="tropical_humide"), "IV.2"),
 ("Roche presque nue au désert", dict(horizons="aucun", mo=0.2, climat="aride", vegetation="nulle"), "I.2"),
]

def merged_profiles(order):
    out = {}
    for code in order:
        if code not in PROFILES: continue
        parent = code.split(".")[0]
        p = dict(PROFILES.get(parent, {})) if "." in code else {}
        p.update(PROFILES[code]); out[code] = p
    return out

def analyse(params, profiles, measures):
    """Même calcul que LabAnalyzer (Dart). Retourne [(code, indice, ...)] trié."""
    w = {p["id"]: p["weight"] for p in params}; tol = {p["id"]: p.get("tol", 0) for p in params}
    provided = sum(w[k] for k in measures)
    res = []
    for i, (code, prof) in enumerate(profiles.items()):
        total = sum(w[k] for k in prof); considered = 0; half = 0  # half = demi-points (2 = concordant, 1 = proche)
        for k, v in measures.items():
            if k not in prof: continue
            considered += w[k]; e = prof[k]
            if isinstance(e, tuple):
                lo, hi = e; d = lo - v if v < lo else (v - hi if v > hi else 0)
                half += 2 * w[k] if d == 0 else (w[k] if d <= tol[k] + 1e-9 else 0)
            else:
                half += 2 * w[k] if v in e else 0
        if considered == 0: continue
        corr = half / (2 * considered); cov = considered / provided
        res.append((code, corr * (0.6 + 0.4 * cov), considered / total, i))
    res.sort(key=lambda r: (-round(r[1], 9), -round(r[2], 9), r[3]))
    return res
