#!/bin/bash

PROGNAME=`basename $0`
###########################################################################
# Basé sur http://forum.ubuntu-fr.org/viewtopic.php?pid=3560900

HELP="
Utilisation:
$PROGNAME OPTION

Permet de rebooter une freebox v5 (ADSL ou HD).
Fonctionne uniquement en LAN.

Options :
 rebootAdsl    reboot le boitier ADSL
 rebootHD      reboot le boitier HD
 rebootOffHD   reboot le boitier HD s'il est éteint
 rebootOnHD    reboot le boitier HD s'il est allumé

"
# Code télécommande accessible dans le menu
# "Informations générales" de la freebox HD
CODE_FREEBOX=
# Il est également possible de le renseigner dans
# le fichier ~/.freebox_code

# Identifiant du boîtier HD
ID_BOITIER=1

###########################################################################

if [ a$1 == a ] ; then
    echo "$HELP" >&2
    exit 1
fi

test -f $HOME/.freebox_code && CODE_FREEBOX=`cat $HOME/.freebox_code | sed 's/ //g'`

if [ a$CODE_FREEBOX == a ] ; then
    echo "Vous devez renseigner le code freebox dans le script." >&2
    exit 1
fi

# Simule un appui sur la touche $1
# Simule un appui long si $2 vaut "long"
# Liste keys :
#     power : la touche rouge on/off
#     list : la touche d’affichage de la liste des chaînes entre power et tv
#     tv : la touche verte TV de commutation péritel.
#     0 à 9 : les touches 0 à 9
#     back : la touche jaune en dessous du 7
#     swap : la touche en dessous du 9
#     info, mail, help, pip : les touches bleues à droite des numéros de chaîne
#     epg, media, options : fonctionnalités "secondaires" de ces mêmes touches
#     vol_inc, vol_dec : volume+ et volume-
#     prgm_inc, prgm_dec : program+ et program-
#     ok : touche OK
#     up, right, down, left : les touches directionnelles entourant le OK
#     mute : la touche de mise en sourdine
#     home : la touche free
#     rec : la touche d’enregistrement
#     bwd : la touche de retour en arrière (<<)
#     prev : la touche "précédent" (|<<)
#     play : la touche lecture/pause
#     fwd : la touche d’avance rapide (>>)
#     next : la touche "suivant" (>>|)
#     red : le bouton rouge (B)
#     green : le bouton vert (A)
#     yellow : le bouton jaune (Y)
#     blue : le bouton bleu (X)

simulerAppui() {
    if [ "$#" -eq 1 ]
    then
        isLong=false
    else
        if [ "$#" -eq 2 ]
        then
            isLong=true
        else
            echo "Usage : simulerAppui <key> [long]"
            return 2
        fi
    fi
    wget -q -O /dev/null "http://hd${ID_BOITIER}.freebox.fr/pub/remote_control?code=${CODE_FREEBOX}&key=${1}&long=${isLong}"
    echo -n '*'
}

# Conduit sur l'item radio si l'on
# est dans la troisieme colonne
accueilColonne3Haut() {
    simulerAppui left
    sleep 1
    simulerAppui down
    sleep 1
    simulerAppui right
    sleep 1
    simulerAppui left
    sleep 1
    simulerAppui down
    sleep 1
    simulerAppui right
    sleep 1
    simulerAppui left
    sleep 1
    simulerAppui down
    sleep 1
    simulerAppui right
}

# Conduit sur l'item en haut de la
# colonne courante sur la page
# d'accueil
accueilLigneHaut() {
    accueilColonne3Haut
    sleep 1
    simulerAppui left
    sleep 1
    accueilColonne3Haut
    sleep 1
    simulerAppui left
    sleep 1
    accueilColonne3Haut
    sleep 1
    simulerAppui left
    sleep 1
    accueilColonne3Haut
    sleep 1
    simulerAppui left
}

# Conduit sur l'item Replay si l'on
# est sur la deuxieme ligne
accueilLigne2Droite() {
    simulerAppui ok
    sleep 3
    simulerAppui red
    sleep 2
    simulerAppui left
    sleep 2
    simulerAppui ok
    sleep 3
    simulerAppui red
    sleep 2
    simulerAppui left
    sleep 2
    simulerAppui ok
    sleep 3
    simulerAppui red
    sleep 2
    simulerAppui left
    sleep 2
    simulerAppui ok
    sleep 3
    simulerAppui red
    sleep 2
    simulerAppui home
}

# Va dans le menu parametre
# quand le boitier est allume
gotoParam() {
    simulerAppui home
    sleep 5
    accueilLigneHaut
    sleep 1
    simulerAppui up
    sleep 1
    simulerAppui up
    sleep 1
    accueilLigne2Droite
    sleep 1
    simulerAppui right
    sleep 1
    simulerAppui right
    sleep 1
    simulerAppui down
    sleep 1
    simulerAppui ok
}
# Va dans le menu parametre
# quand le boitier est allume
gotoParamOld() {
    simulerAppui home
    sleep 5
    accueilLigneHaut
    sleep 1
    simulerAppui up
    sleep 1
    simulerAppui up
    sleep 1
    accueilLigne2Droite
    sleep 1
    simulerAppui right
    sleep 1
    simulerAppui down
    sleep 1
    simulerAppui ok
}

goOverDisqueDur() {
    gotoParam
    sleep 1
    # On va l'item disque dur du menu param
    simulerAppui up
    sleep 1
    simulerAppui left
    sleep 1
    simulerAppui up
    sleep 1
    simulerAppui left
    sleep 1
    simulerAppui up
    sleep 1
    simulerAppui left
    sleep 1
}

# Va dans le menu info Reseau
# quand le boitier est allume
gotoInfoReseau() {
    goOverDisqueDur
    # On est sur l'item disque dur
    # On va sur information reseau
    simulerAppui left
    sleep 1
    simulerAppui up
    sleep 1
    simulerAppui ok
}

gotoInfoGenerales() {
    goOverDisqueDur
    sleep 1
    # On est sur l'item disque dur
    # On va sur information reseau
    simulerAppui left
    sleep 1
    simulerAppui up
    sleep 1
    simulerAppui left
    sleep 1
    simulerAppui ok
}


# Redemarre le modem adsl si le
# boitier HD est allume
redemarrerAdslSiOn() {
    gotoInfoReseau
    sleep 1
    simulerAppui down
    sleep 1
    # Ce ok lance le redemarrage
    simulerAppui ok
#    # On ressort du menu
#    sleep 1
#    simulerAppui red
#    sleep 1
#    simulerAppui red
#    sleep 1
#    simulerAppui red
}

# Redemarre le modem HD si le
# boitier HD est allume
redemarrerHDSiOn() {
    gotoInfoGenerales
    sleep 1
    simulerAppui down
    sleep 1
    # Ce ok lance le redemarrage
    simulerAppui ok
}

preDisplay() {
    N=$1
    for I in `seq 1 $N`
    do
	echo -n .
    done
    for I in `seq 1 $N`
    do
	tput cub1
    done

}

case $1 in
     rebootAdsl)
	preDisplay 73
        # Redemarre le modem adsl
        # dans tous les cas
        simulerAppui power
        sleep 5
        redemarrerAdslSiOn
        sleep 1
        simulerAppui power
	sleep 5
	if ping -c 1 hd${ID_BOITIER}.freebox.fr >/dev/null 2>&1; then
	    preDisplay 69
            redemarrerAdslSiOn
            sleep 1
            simulerAppui power
	fi
	exit 0
        ;;
     rebootHD)
	preDisplay 151
        # Redemarre le modem HD
        # dans tous les cas
        simulerAppui power
        sleep 5
        redemarrerHDSiOn
        sleep 1
        simulerAppui power
        sleep 5
	if ping -c 1 hd${ID_BOITIER}.freebox.fr >/dev/null 2>&1; then
            redemarrerHDSiOn
	    sleep 60
            simulerAppui power
	fi
	exit 0
	;;
     rebootOffHD)
	preDisplay 1
        # Redemarre le modem HD
        # si Off
        simulerAppui power
        sleep 5
        exec $0 rebootOnHD
	exit 0
	;;
     rebootOnHD)
	preDisplay 72
        # Redemarre le modem HD
        # si On
        redemarrerHDSiOn
	sleep 60
        simulerAppui power
	exit 0
	;;
    *)
	echo "$HELP" >&2
        #exec $0 rebootHD
	exit 1
esac
echo