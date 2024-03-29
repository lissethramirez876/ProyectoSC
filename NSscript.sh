#!/bin/bash

# Title: NSscript
# SYNOPSIS:
# : NSscript {<options>...}
# DESCRIPTION:
#
# Este script instala el Simulador de Redes NS 2 y el TCPLAB
#
# LICENSE: GPL
# 
#
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# Variable: user
#
# Nombre de usuario.
#user=`users | cut -f2 -d\ `

# Variable: root_state Nombre (required)

# Permisos para ejecución del comando
root_state=`whoami`

# Variable: paquetes
#
# Lista de paquetes estandar.
paquetes="g++ gcc-4.3 g++-4.3 libx11-dev libxmu-dev x11proto-core-dev xorg-dev xgraph unrar build-essential autoconf automake libc6 libotcl1 tk8.4 gnuplot libtool tk8.4-dev tcl8.4-dev"
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
	echo "------------------  Instalando NS 2 -----------------------"
	sleep 3
	mkdir /home/$user/simulador/
	cd /home/$user/simulador/
	rm -R ns-allinone-2.34/
	#wget http://sourceforge.net/projects/nsnam/files/allinone/ns-allinone-2.34/ns-allinone-2.34.tar.gz
	#descomprimir el archivo en un directorio
	tar -xzvf ns-allinone-2.34.tar.gz
	
	#buscando de SHLIB_LD="ld -shared" a SHLIB_LD="gcc -shared"
	cd /home/$user/simulador/ns-allinone-2.34/otcl-1.13/
	find /home/$user/simulador/ns-allinone-2.34/otcl-1.13/configure | xargs perl -pi -e 's/SHLIB_LD="ld -shared"/SHLIB_LD="gcc -shared"/g'
	find /home/$user/simulador/ns-allinone-2.34/nam-1.14/Makefile.in | xargs perl -pi -e 's/CC=@CC@/CC=gcc-4.3/g'
	find /home/$user/simulador/ns-allinone-2.34/ns-2.34/Makefile.in | xargs perl -pi -e 's/CC=@CC@/CC=gcc-4.3/g'
	find /home/$user/simulador/ns-allinone-2.34/otcl-1.13/Makefile.in | xargs perl -pi -e 's/CC=@CC@/CC=gcc-4.3/g'
	find /home/$user/simulador/ns-allinone-2.34/tclcl-1.19/Makefile.in | xargs perl -pi -e 's/CC=@CC@/CC=gcc-4.3/g'
	find /home/$user/simulador/ns-allinone-2.34/nam-1.14/Makefile.in | xargs perl -pi -e 's/CPP=@CXX@/CPP=g++-4.3/g'
	find /home/$user/simulador/ns-allinone-2.34/ns-2.34/Makefile.in | xargs perl -pi -e 's/CPP=@CXX@/CPP=g++-4.3/g'
	find /home/$user/simulador/ns-allinone-2.34/otcl-1.13/Makefile.in | xargs perl -pi -e 's/CPP=@CXX@/CPP=g++-4.3/g'
	find /home/$user/simulador/ns-allinone-2.34/tclcl-1.19/Makefile.in | xargs perl -pi -e 's/CPP=@CXX@/CPP=g++-4.3/g'
	
	echo "Empieza instalacion de TCPLAB"
	#mv tcp-lab /home/$user/simulador/
	cd /home/$user/simulador/
	#COPIAR ARCHIVOS/DIRECTORIOS
	cp -R tcp-lab/trunk/rpi ns-allinone-2.34/ns-2.34/rpi
	cp -R tcp-lab/trunk/rpi/rpi-tcl ns-allinone-2.34/ns-2.34/tcl/rpi
	cp -R ns-allinone-2.34/ns-2.34/rpi/rpi-c++/* ns-allinone-2.34/ns-2.34/rpi
	
	#RESPALDO de archivos originales
	cd /home/$user/simulador/ns-allinone-2.34/ns-2.34/tcp
	mv tcp.cc tcp.cc-backup
	mv tcp.h tcp.h-backup
	mv tcp-full.cc tcp-full.cc-backup
	mv tcp-full.h tcp-full.h-backup
	
	cd /home/$user/simulador/ns-allinone-2.34/ns-2.34/tcl/lib
	mv ns-default.tcl ns-default.tcl-backup
	mv ns-queue.tcl ns-queue.tcl-backup
	
	cd /home/$user/simulador/ns-allinone-2.34/tclcl-1.19
	mv tracedvar.h tracedvar.h-backup
	mv tracedvar.cc tracedvar.cc-backup
	
	#ENLACE SIMBOLICOS
	ln -s /home/$user/simulador/tcp-lab/trunk/tcp/my-tcp-full-2.34/tcp.h /home/$user/simulador/ns-allinone-2.34/ns-2.34/tcp/tcp.h
	ln -s /home/$user/simulador/tcp-lab/trunk/tcp/my-tcp-full-2.34/tcp.cc /home/$user/simulador/ns-allinone-2.34/ns-2.34/tcp/tcp.cc
	ln -s /home/$user/simulador/tcp-lab/trunk/tcp/my-tcp-full-2.34/tcp-full.cc /home/$user/simulador/ns-allinone-2.34/ns-2.34/tcp/tcp-full.cc
	ln -s /home/$user/simulador/tcp-lab/trunk/tcp/my-tcp-full-2.34/tcp-full.h /home/$user/simulador/ns-allinone-2.34/ns-2.34/tcp/tcp-full.h
	ln -s /home/$user/simulador/tcp-lab/trunk/tcp/my-tcp-full-2.34/tcp-full-newreno.cc /home/$user/simulador/ns-allinone-2.34/ns-2.34/tcp/tcp-full-newreno.cc
	ln -s /home/$user/simulador/tcp-lab/trunk/rpi/redefine-ns2/ns-default.tcl-2.33 /home/$user/simulador/ns-allinone-2.34/ns-2.34/tcl/lib/ns-default.tcl
	ln -s /home/$user/simulador/tcp-lab/trunk/rpi/redefine-ns2/ns-queue.tcl-2.33 /home/$user/simulador/ns-allinone-2.34/ns-2.34/tcl/lib/ns-queue.tcl
	ln -s /home/$user/simulador/tcp-lab/trunk/tclcl-1.19/tracedvar.h /home/$user/simulador/ns-allinone-2.34/tclcl-1.19/tracedvar.h
	ln -s /home/$user/simulador/tcp-lab/trunk/tclcl-1.19/tracedvar.cc /home/$user/simulador/ns-allinone-2.34/tclcl-1.19/tracedvar.cc
	
	#MODIFICAR MAKEFILE de ns2.34 (el archivo ns2.34/makefile.in )
	cd /home/$user/simulador/ns-allinone-2.34/ns-2.34/
	mv Makefile.in Makefile.in-backup
	cd /home/$user/simulador/tcp-lab/
	cp	 Makefile.in /home/$user/simulador/ns-allinone-2.34/ns-2.34/
	
	#instalar el paquete
	cd /home/$user/simulador/ns-allinone-2.34
	./install 
	echo "instalacion de ns terminada..........."

	echo PATH=$PATH:/home/$user/simulador/ns-allinone-2.34/ns-2.34 >> ~/.bashrc
	echo export NS=/home/$user/simulador/ns-allinone-2.34/ns-2.34  >> ~/.bashrc
	echo export TCPLAB=/home/$user/simulador/tcp-lab/trunk/includes/tcl >> ~/.bashrc
	echo export TCPLABRPI=/home/$user/simulador/tcp-lab/trunk/rpi/rpi-tcl >> ~/.bashrc
	echo export NSVER=2.34 >> ~/.bashrc
	
	source ~/.bashrc
	test_command $? "Problemas al instalar los paquetes NS 2."
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

****************************************  P A S O   1  ********************************************************************************
--verificar
Verifica la existencia de los paquetes necesarios para la instalación del simulador.



****************************************  P A S O   2  ********************************************************************************
--instalar
Instala el NS 2 y el TCPLAB

****************************************  A Y U D A    ********************************************************************************
-h, --help
Muestra la ayuda del programa.

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
