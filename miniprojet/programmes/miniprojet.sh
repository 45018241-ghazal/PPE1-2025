#!/usr/bin/env bash
(
if [ "$#" -ne 1 ]; then
  echo "usage: $0 <fichier_urls>"
  exit 1
fi

URLS_FILE="$1"
if [ ! -f "$URLS_FILE" ]; then
  echo "error: file not found: $URLS_FILE"
  exit 1
fi

#Ligne d'en-tête
echo -e "line\turl\tcode_HTTP\tencodage\tnombre_mots"


n=0 #compteur

while IFS= read -r line;
  do
    [ -z "$line" ] && continue
    n=$((n+1))

    #Normaliser l’URL
    url="$line"
    case "$url" in
      http://*|https://*) ;;
      *) url="https://$url" ;;
    esac

    #le code de http
    http_code=$(curl -s -o /dev/null -w '%{http_code}' "$url")

    #Content Type
    ctype=$(curl -sI "$url" | grep -i '^content-type:' | tail -n1)
    #Extraire le charset du Content Type
    charset=$(echo "$ctype" | grep -io 'charset=[^;[:space:]]*' | cut -d= -f2)
    [ -z "$charset" ] && charset="-"

    #le nombre de mots
    words=$(lynx -dump -nolist "$url" 2>/dev/null | wc -w | tr -d ' ')

    echo -e "$n\t$url\t$http_code\t$charset\t$words"
  done < "$URLS_FILE"
) | column -t -s $'\t'
