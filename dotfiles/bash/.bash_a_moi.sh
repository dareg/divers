#Permet la complétition avec la touche tab des variables contenant un chemin
shopt -s direxpand

#Sans
# ls $HOME/Doc -> tab -> ls \$HOME/Documents
#Avec
# ls $HOME/Doc -> tab -> ls /home/utilisateur/Documents

#Ajoute à l'historique plutôt que remplacer
shopt -s histappend
export HISTFILESIZE=10000
#Ne garde qu'une seule occurence d'une commande dans l'historique
export HISTCONTROL=ignoredups:erasedups

#Essaye de corriger des petites erreurs sur les noms de dossiers
#cd wii -> cd wiki
shopt -s cdspell

#Permet la complétition automatique avec tab sans prendre en compte la casse
bind -s 'set completion-ignore-case on'

export PS1="\[\e[1;32m\]\u@\h\[\e[m\]:\[\e[1;34m\]\w\[\e[m\] \[\e[1;36m\]\t\[\e[m\]\n\[\e[1;30m\]$\[\e[m\] "
#             |         | ||   |        |         |   |      |           |   |     |   |         |  |
#             |         | ||   |        |         |   |      |           |   |     |   |         |  \e[m marqueur de fin de couleur
#             |         | ||   |        |         |   |      |           |   |     |   |         $ affiche le symbole '$'
#             |         | ||   |        |         |   |      |           |   |     |   \e[1;30m marqueur pour la couleur noir en gras
#             |         | ||   |        |         |   |      |           |   |     \n retour à la ligne
#             |         | ||   |        |         |   |      |           |   \e[m marqueur de fin de couleur
#             |         | ||   |        |         |   |      |           \t affiche le temps au format HH:MM:SS
#             |         | ||   |        |         |   |      \e[1;36m marqueur pour la couleur cyan en gras
#             |         | ||   |        |         |   \e[m marqueur de fin de couleur
#             |         | ||   |        |         \w affiche le chemin
#             |         | ||   |        \e[1;34m marqueur pour la couleur bleu en gras
#             |         | ||   \e[m marqueur de fin de couleur
#             |         | |\h affiche le nom de la machine
#             |         | @ affiche le symbol '@'
#             |         \u affiche le nom d'utilisateur
#             \e[1;32m marqueur pour la couleur vert en gras
#
#Tout les caractères n'affichant rien, par exemple les marqueur de début et de
#fin de couleur doivent être entouré par \[ \]

#Utile pour effectuer des calculs en ligne de commande
function calc(){
	{ awk "BEGIN{print $*}"; }
}

#Génère une chaine de 32 caractères aléatoires pouvant servir de mot de passe
function pass(){
	cat /dev/urandom | tr -dc '[:alnum:]' | fold -w 32 | head -n 1
}

#Vérifie que la somme de controle en argumant est la même que celle produite pour le fichier en argument
checksha256() {
    #$1 somme de contrôle sha256
    #$2 fichier à vérifier
    echo "$1 $2" | sha256sum --check
}

#Règle le clavier en mode qwerty international
setxkbmap -layout us -variant altgr-intl
#La touche caps lock est désormais une touche controle suplémentaire
setxkbmap -option ctrl:nocaps

#Désactive les beep
xset b off

export EDITOR=vim

alias st="git status"
fd(){
	if [ $# -eq 1 ]; then
		find . -iname "*$1*"
	fi
	if [ $# -eq 2 ]; then
		find $2 -iname "*$1*"
	fi
}

fdopen(){
	local OUTFILE=$(mktemp)
	fd $1 > "$OUTFILE"
	if [ $(cat $OUTFILE | wc -l) -eq 1 ]; then
		open "$(cat $OUTFILE)"
	else
		cat "$OUTFILE"
	fi
	rm "$OUTFILE"
}
#
#Désactive C^s et C^q
stty -ixon

f() {
    fff "$@"
    cd "$(cat "${XDG_CACHE_HOME:=${HOME}/.cache}/fff/.fff_d")"
}

export VR_MAX_DEPTH=20
v() {
	IFS="
"
	local D="$(~/logiciels/bin/v.py $*)";
	if [ $? -eq 0 ];then
		cd "$D";
	fi
}

vr() {
	IFS="
"
	local D="$(~/logiciels/bin/v.py -r $*)";
	if [ $? -eq 0 ];then
		cd "$D";
	fi
}
