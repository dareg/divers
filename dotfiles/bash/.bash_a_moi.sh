#Permet la complétition avec la touche tab des variables contenant un chemin
shopt -s direxpand
#Sans
# ls $HOME/Doc -> tab -> ls \$HOME/Documents
#Avec
# ls $HOME/Doc -> tab -> ls /home/utilisateur/Documents

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
