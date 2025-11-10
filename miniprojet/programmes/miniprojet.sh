#!/usr/bin/env bash


#  Validation des arguments

if [ "$#" -ne 2 ]; then
  echo "usage: $0 <fichier_urls_entree> <fichier_sortie_tsv>" >&2
  exit 1
fi

FICHIER_URLS="$1"
FICHIER_SORTIE="$2"

if [ ! -f "$FICHIER_URLS" ]; then
  echo "error: file not found: $FICHIER_URLS" >&2
  exit 1
fi

# Génération du tableau TSV

(
  # Ligne d'en-tête
  echo -e "Numero\tAdresse\tCode_HTTP\tEncodage\tNombre_mots"

  NB_LIGNE=0

    #  Boucle sur les URLs
  while IFS= read -r LINE; do
    # ignorer les lignes vides
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
      URL="$LINE"

      # récupération du code + content-type
      CODE_ET_ENCODAGE=$(curl -s -L -i -o "tmp.txt" -w "%{http_code}\n%{content_type}" "$URL")

      # extraction du code HTTP
      CODE=$(echo "$CODE_ET_ENCODAGE" | head -n 1)

      # Si erreur réseau
      if [ "$CODE" -eq 0 ]; then
        printf '%d\t%s\tERREUR\tERREUR\tERREUR\n' "$NB_LIGNE" "$URL"
        continue
      fi

      # extraction du charset proprement
      CTYPE=$(echo "$CODE_ET_ENCODAGE" | tail -n 1)
      ENCODAGE=$(echo "$CTYPE" | grep -E -o "charset=[^;[:space:]]*" | cut -d= -f2)
      [ -z "$ENCODAGE" ] && ENCODAGE="-"

    # Vérifie si c'est de l'UTF-8
      if [[ "$ENCODAGE" =~ UTF-8|utf-8 ]]; then
        ENCODAGE_OU_PAS="OUI"
      else
        ENCODAGE_OU_PAS="NON"
      fi

      # Nombre de mots
      NB_MOTS=$(lynx -dump -stdin -nolist < "tmp.txt" 2>/dev/null | wc -w | tr -d ' ')

      # ligne tabulaire TSV
      printf '%d\t%s\t%s\t%s\t%s\n' \
        "$NB_LIGNE" "$URL" "$CODE" "$ENCODAGE_OU_PAS" "$NB_MOTS"


  done < "$FICHIER_URLS"

  # supprimer le fichier temporaire
  rm -f tmp.txt

) > "$FICHIER_SORTIE"


column -t -s $'\t' "$FICHIER_SORTIE"
