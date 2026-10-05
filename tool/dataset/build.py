import json, os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from facets import FACETS
from modifiers import MOD
from tree import TREE
from key_gloss import KEY, GLOSSARY

ROMAN = ["I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII"]
LEVELS = ["classe","sous_classe","groupe","sous_groupe"]
units = []
def check(f):
    for k, vs in f.items():
        assert k in FACETS, k
        for v in vs: assert v in FACETS[k][2], (k, v)

def walk(n, code, parent, depth):
    check(n["f"])
    u = dict(id=code, code=code, level=LEVELS[depth], name=n["name"], description=n["desc"], parent=parent, criteria=n["f"])
    if n["expl"]: u["explanation"] = n["expl"]
    if n["profil"]: u["profile"] = n["profil"]
    if n["ex"]: u["examples"] = n["ex"]
    units.append(u)
    for i, k in enumerate(n["kids"], 1): walk(k, f"{code}.{i}", code, depth + 1)
    for i, m in enumerate(n["sg"], 1):
        lab, expl, f = MOD[m]; check(f)
        units.append(dict(id=f"{code}.{i}", code=f"{code}.{i}", level="sous_groupe", name=lab, description=expl, parent=code, criteria=f, modifier=m))

for i, n in enumerate(TREE): walk(n, ROMAN[i], None, 0)
ids = [u["id"] for u in units]; assert len(ids) == len(set(ids))
for q in KEY:
    for _, t in q["opts"]:
        assert t.startswith("r:") and t[2:] in ROMAN or t in [x["id"] for x in KEY], t

data = dict(
  meta=dict(title="Classification des sols CPCS 1967", source="Commission de Pédologie et de Cartographie des Sols (CPCS), Classification des sols, édition 1967 (Aubert et al.), ENSA Grignon.",
            note="Données de référence reconstituées pour l'apprentissage ; à vérifier et compléter avec le document source.", version=1),
  levels=[dict(id="classe", label="Classe", explanation="Niveau 1 : défini par le processus pédogénétique dominant (degré d'évolution, type d'altération, nature de l'humus, excès d'eau ou de sels)."),
          dict(id="sous_classe", label="Sous-classe", explanation="Niveau 2 : précise les conditions du processus, surtout le pédoclimat (température, humidité) ou le type de drainage."),
          dict(id="groupe", label="Groupe", explanation="Niveau 3 : défini par des caractères morphologiques du profil traduisant l'intensité du processus (horizons présents, accumulations)."),
          dict(id="sous_groupe", label="Sous-groupe", explanation="Niveau 4 : intensité du processus principal ou apparition d'un processus secondaire (hydromorphe, vertique, salé, lessivé…).")],
  criteria=[dict(id=k, label=v[0], explanation=v[1], values=[dict(id=vk, label=vv[0], explanation=vv[1]) for vk, vv in v[2].items()]) for k, v in FACETS.items()],
  units=units,
  key=[dict(id=q["id"], question=q["q"], help=q["aide"], options=[dict(label=l, target=t) for l, t in q["opts"]]) for q in KEY],
  glossary=[dict(term=t, definition=d) for t, d in GLOSSARY],
)
json.dump(data, open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'assets', 'data', 'cpcs_1967.json'), 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
from collections import Counter
print(len(units), Counter(u["level"] for u in units))
