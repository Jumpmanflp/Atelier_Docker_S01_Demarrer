#!/usr/bin/env bash
# Vérification automatique de l'atelier « Démarrer » (EPSI - Séance 1)
# Usage : ./verifier.sh

CONTENEUR="mon-site"
IMAGE="httpd:2.4"
PORT="8080"
# Code de validation à saisir dans 360Learning (encodé pour ne pas être lu d'un coup d'œil)
CODE_B64="Q09OVEVORVVSLTQ3MjE="

reussis=0
total=0

verifier() {
  local description="$1"; shift
  total=$((total + 1))
  if "$@" >/dev/null 2>&1; then
    echo "  [OK]  $description"
    reussis=$((reussis + 1))
  else
    echo "  [KO]  $description"
    [ -n "$AIDE" ] && echo "        -> $AIDE"
  fi
  AIDE=""
}

echo ""
echo "Vérification de l'atelier « Démarrer »"
echo "--------------------------------------------------"

AIDE="Docker n'est pas disponible : relancez votre Codespace (voir étape 2)."
verifier "Docker est disponible" docker info

AIDE="Lancez l'étape 3 : docker run hello-world"
verifier "L'image hello-world a été téléchargée" docker image inspect hello-world

AIDE="Lancez l'étape 4 en nommant bien le conteneur « $CONTENEUR »."
verifier "Le conteneur « $CONTENEUR » existe" docker container inspect "$CONTENEUR"

AIDE="Le conteneur doit utiliser l'image $IMAGE (étape 4)."
verifier "Il utilise l'image $IMAGE" \
  test "$(docker container inspect -f '{{.Config.Image}}' "$CONTENEUR" 2>/dev/null)" = "$IMAGE"

AIDE="Démarrez-le : docker start $CONTENEUR"
verifier "Il est démarré" \
  test "$(docker container inspect -f '{{.State.Running}}' "$CONTENEUR" 2>/dev/null)" = "true"

AIDE="Le port $PORT doit être publié avec l'option -p $PORT:80 (étape 4)."
verifier "Le port $PORT est publié" \
  test -n "$(docker port "$CONTENEUR" 80 2>/dev/null | grep ":$PORT")"

AIDE="Relisez l'étape 6 : la page doit contenir le mot Bonjour."
verifier "La page d'accueil a été personnalisée" \
  bash -c "curl -s --noproxy localhost http://localhost:$PORT | grep -qi bonjour"

AIDE="Ouvrez votre site au moins une fois (étape 5)."
verifier "Le serveur a reçu au moins une visite" \
  bash -c "docker logs $CONTENEUR 2>&1 | grep -q 'GET /'"

echo "--------------------------------------------------"
echo "Résultat : $reussis / $total"
echo ""

if [ "$reussis" -eq "$total" ]; then
  echo "Bravo, l'atelier est terminé !"
  echo "Votre code de validation : $(echo "$CODE_B64" | base64 -d)"
  echo "Saisissez-le dans le quiz de la séance sur 360Learning."
  exit 0
else
  echo "Corrigez les points [KO] puis relancez ./verifier.sh"
  exit 1
fi
