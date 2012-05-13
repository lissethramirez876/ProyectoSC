#!/bin/bash

# Title: NSscript

#
# SYNOPSIS:
#
# : NSscript {<options>...}

#
# DESCRIPTION:
#
# Este script instala el Simulador de Redes NS 2 y el TCPLAB
#
# 

#
# LICENSE: GPL
# 
#

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# Variable: user
#
# Nombre de usuario.
#user=`users | cut -f2 -d\ `

# Variable: root_state
#
# Permisos para ejecución del comando
root_state=`whoami`

# Variable: paquetes
#
# Lista de paquetes estandar.
paquetes="g++ gcc-4.3 g++-4.3 x-dev libx11-dev libxmu-dev x11proto-core-dev xorg-dev xgraph"


#multimedia="alsa alsa-base listen gxine istanbul w32codecs mplayer xine-ui"

# Variable: checkuser
#
# Si su valor es 0 se hara seleccion de usuario si no se supondra que ya se ha elegida
checkuser="0"

# Function: test_command
#
# Probando el estado de salida de otros comandos.
test_command(){
	if [ "$1" -ne "0" ]; then
		echo "ERROR # ${1} : ${2}"
		exit $1
	fi
}

# Function: test_root_mode
#
# Comprueba que el script se este corriendo con permisos de superusuario.
test_root_mode(){	
	if [ $root_state != "root" ]; then
		echo "Error: Se debe ejecutar el script con permisos de Root"
		exit	
	fi
}

#Antes de comenzar debemos comprobar que tenemos permisos de superusuario
test_root_mode

# Function: get_user
#
# Esta funcion permite la eleccion del usuario correcto
get_user(){
	
	if [ "$checkuser" = "0" ]; then

		echo "Por Favor seleccione un usuario de la lista"
		echo ""
	
		for users in $(ls /home):
		do
			if [ "$users" != "lost+found" ]; then
				echo "	$users" | sed s/://g
			fi
		done
	
		echo ""
		echo "Usuario: "
		read user
	
		if [ "$user" == "lost+found" ] || [ ! -d /home/"$user" ]; then
			echo "El usuario ingresado no existe, por favor elija el usuario correcto"
			read user
		else
			echo "Bienvenido(a): $user"
			$checkuser = 1
		fi
	fi
}

# Function: Verificar
#
# Verifica la existencia de los paquetes necesarios para el funcionamiento del simulador e instala los paquetes faltantes.

verificar(){
	echo "---------- Instalando los paquetes basicos ----------"
	sleep 3
	apt-get -y --force-yes install $paquetes 
	test_command $? "Problemas al instalar los paquetes faltantes."
	echo "---------- Se han instalado los paquetes base ----------"
}

# Function: instalar
#
instalar(){
	get_user
	echo "------------------  Instalando Paquetes NS 2 y TCPLAB -----------------------"
	sleep 3
	test_command $? "Problemas al instalar los paquetes NS 2 y TCPLAB."
	echo "---------- Se han instalado los paquetes NS 2 y TCPLAB----------"
	
}

# Function: ayuda
#
# Muestra la ayuda del _script_.
ayuda(){
	echo "\
Usage: $(basename $0) {<options>...}

DESCRIPCIÓN

Este script instala el Simulador de Redes NS 2 y el TCPLAB

OPTIONS

-h, --help

Muestra la ayuda del programa.

--verificar

Verifica la existencia de los paquetes necesarios para el funcionamiento del simulador e instala los paquetes faltantes.

--instalar

Instala el NS 2 y el TCPLAB
"
}

if [ "$#" -eq 0 ]; then
	ayuda; exit 1;
fi

while [[ $1 == -* ]]; do 
	case "$1" in
		-h|--help) ayuda; exit 0;;
		--verificar) verificar; shift;;
		--instalar) instalar; shift;;
		*) echo "Opción invalida..."; exit 1;;
	esac
done
