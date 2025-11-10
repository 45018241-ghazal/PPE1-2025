#!/usr/bin/env bash

#  Validation des arguments
if [ $# -ne 2 ]; then
  echo "Ce programme demande deux arguments : 1 fichier d'entrée contenant des urls et 1 fichier sortie"
  exit 1
fi

FICHIER_URLS=$1
FICHIER_HTML=$2

if [ ! -f "$FICHIER_URLS" ]; then
  echo "Ce programme demande un fichier d'entrée valide"
  exit 1
fi


(
  NB_LIGNE=0

  #  En-tête HTML + début du tableau
  cat <<'EOF'
<html>
  <head>
    <meta charset="UTF-8" />
  </head>
  <body>
    <table>
      <tr><th>Numero</th><th>Adresse</th><th>ReponseRequete</th><th>EncodageEnUTF8</th><th>NombreDeMots</th></tr>
EOF

  #  Boucle sur les URLs
  while IFS= read -r LINE; do
    # Ignorer les lignes vides
    [ -z "$LINE" ] && continue

    #Normaliser l’URL
        URL="$LINE"
    case "$URL" in
      http://*|https://*) ;;
      *) URL="https://$URL" ;;
    esac


    # Traiter seulement les lignes avec http/https (après normalisation)
    [[ $URL =~ ^https?:// ]] || continue

      NB_LIGNE=$((NB_LIGNE + 1))

      # récupération du code + content-type
      CODE_ET_ENCODAGE=$(curl -s -L -i -o "tmp.txt" -w "%{http_code}\n%{content_type}" "$LINE")

      # extraction du code HTTP
      CODE=$(echo "$CODE_ET_ENCODAGE" | head -n 1)

      # Si il y a une erreur réseau, écrire une ligne d'erreur
      if [ "$CODE" -eq 0 ]; then
        printf '      <tr><td>%d</td><td>%s</td><td>ERREUR</td><td>ERREUR</td><td>ERREUR</td></tr>\n' \
          "$NB_LIGNE" "$LINE"
        continue
      fi

      # extraction du charset
      ENCODAGE=$(echo "$CODE_ET_ENCODAGE" | grep -E -o "charset=.*")

      # Vérifie si c'est de l'UTF-8
      if [[ "$ENCODAGE" =~ UTF-8|utf-8 ]]; then
        ENCODAGE_OU_PAS="OUI"
      else
        ENCODAGE_OU_PAS="NON"
      fi

      # Nombre de mots
      NB_MOTS=$(lynx -dump -stdin -nolist < "tmp.txt" | wc -w)

      # Ligne du tableau HTML
      printf '      <tr><td>%d</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>\n' \
        "$NB_LIGNE" "$LINE" "$CODE" "$ENCODAGE_OU_PAS" "$NB_MOTS"

  done < "$FICHIER_URLS"

  # supprimer le fichier temporaire
  rm -f tmp.txt

  # fin du tableau et de la page HTML
  cat <<'EOF'
    </table>
  </body>
</html>
EOF

) > "$FICHIER_HTML"
