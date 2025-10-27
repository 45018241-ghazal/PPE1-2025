# Journal de bord du projet encadré
## Travail sur Git et la manipulation de fichiers

- J'ai synchronisé le dépôt local avec git pull (Exercise 2.b)
- J'ai vérifié l'historique des commits avec git log (Exercise 2.b)
- Je prépare la première modification locale (Exercise 2.c)

Exercice 1 : lire les lignes d’un fichier en bash

Réponse 1 — Pourquoi ne pas utiliser cat?
La commande cat sert seulement à afficher le contenu d’un fichier. Ici, on veut lire le fichier ligne par ligne pour pouvoir faire des traitements sur chaque ligne.Avec while read -r line; do ... done < fichier, on peut lire chaque ligne directement et utiliser les variables dans le script.

Réponse 2 — Comment transformer "urls/fr.txt" en paramètre du script ? 
Dans le script, on remplace le nom du fichier écrit directement (urls/fr.txt) par une variable qui contient le premier argument donné lors de l’exécution. Exemple : URLS_FILE="$1" Puis, on lit ce fichier avec : done < "$URLS_FILE" Ainsi, quand on lance le script, on peut donner n’importe quel fichier.

Réponse 2.1 — Valider l’argument:
Pour vérifier qu’un argument est bien fourni et que le fichier existe,on ajoute un petit test au début :
if [ "$#" -ne 1 ]; then
  echo "usage: $0 <fichier_urls>"
  exit 1
fi
URLS_FILE="$1"
if [ ! -f "$URLS_FILE" ]; then
  echo "error: file not found: $URLS_FILE"
  exit 1
fi
Cela veut dire que s’il n’y a pas exactement un argument, ou si le fichier n’existe pas,
le script affiche un message d’erreur et s’arrête (exit 1).

Réponse 3 — Comment afficher le numéro de ligne avant chaque URL ?
On utilise une variable compteur:
n=0
while read -r line; do
  [ -z "$line" ] && continue
  n=$((n+1))
  echo -e "$n\t$url"
done < "$URLS_FILE"
