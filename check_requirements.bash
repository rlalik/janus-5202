#!/bin/bash

# Reset
Clear='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Orange='\033[48:2:255:165:0m' # Orange
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

###########################################
# ---- Installing packages functions ---- #
###########################################
function map_package_name() {
	package="$1"
	distro="$2"
	case "$package:$distro" in
        # ---- g++ ----
        g++:debian|g++:ubuntu) echo "g++" ;;
        g++:fedora|g++:centos|g++:rhel|g++:almalinux|g++:rocky) echo "gcc-c++" ;;

        # ---- make ----
        make:*) echo "make" ;;

        # ---- libusb ----
        libusb:debian|libusb:ubuntu) echo "libusb-1.0-0-dev" ;;
        libusb:fedora|libusb:centos|libusb:rhel|libusb:almalinux|libusb:rocky) echo "libusbx-devel" ;;

        # ---- gnuplot ----
        gnuplot:*) echo "gnuplot" ;;
        gnuplot-wx:fedora) echo "gnuplot-wx" ;;
        gnuplot-wx:*) echo "UNAVAILABLE" ;;

        # ---- pkgconf ----
        pkgconf:*) echo "pkgconf" ;;

        # ---- python3 ----
        python3:*) echo "python3" ;;

        # ---- tkinter ----
        tkinter:debian|tkinter:ubuntu) echo "python3-tk" ;;
        tkinter:fedora|tkinter:centos|tkinter:rhel|tkinter:almalinux|tkinter:rocky) echo "python3-tkinter" ;;

        # ---- pillow ----
        pillow:debian|pillow:ubuntu) echo "python3-pil" ;; # ma si userà pip
        pillow:fedora) echo "python3-Pillow" ;;
        pillow:centos|pillow:rhel|pillow:almalinux|pillow:rocky) echo "python3-Pillow" ;;

        # ---- imagetk ----
        imagetk:debian|imagetk:ubuntu) echo "python3-pil.imagetk" ;;
        imagetk:fedora) echo "python3-Pillow-tk" ;;
        imagetk:rhel|imagetk:centos|imagetk:almalinux|imagetk:rocky) echo "python3-Pillow-tk" ;;

        *)
            echo "UNKNOWN"
            ;;
    esac
	
}


function installPackage() {
	package="$1"
	distro="$2"

	realPkg=$(map_package_name "$package" "$distro")
	echo "Installing package: $realPkg"
	
	case "$distro" in 
		debian|ubuntu)
			sudo apt install -y "$realPkg"
			res=$?
			if [ $res -ne 0 ]; then
				echo -e "${Red}Cannot install $realPkg through 'sudo apt install $realPkg'"
				return -1
			else
				echo -e "${Green}$realPkg installed${Clear}"
			fi
			;;
		fedora)
			sudo dnf install -y "$realPkg"
			if [ $res -ne 0 ]; then
				echo -e "${Red}Cannot install $realPkg through 'sudo dnf install $realPkg'"
				return -1
			else
				echo -e "${Green}$realPkg installed${Clear}"
			fi
			;;
		rhel)
			sudo yum install -y "$realPkg"
			if [ $res -ne 0 ]; then
				echo -e "${Red}Cannot install $realPkg through 'sudo yum install $realPkg'"
				return -1
			else
				echo -e "${Green}$realPkg installed${Clear}"
			fi
			;;
		*)
			echo "Unsupported distro: $distro"
			return 1
			;;
	esac
}


function InstallUsb() {
	echo "Installing libusb-1.0.so ..."
	sudo apt-get install libusb-1.0-0-dev
	sudo updatedb && locate libusb.h && locate libusb-1.0.so
	res=$?
	if [ $res -eq 0 ]; then
		echo -e "${Green}libusb-1.0 installed!!${Clear}"
		return -1
	else
		echo -e "${Red}Cannot install libusb-1.0 through 'sudo apt-get install libusb-1.0.0-dev"
	fi
	echo
}


function InstallWxt() {
	echo -e "${Red}wxt terminal is not supported by your gnuplot version installed.{Clear}"
	echo "Please, try to install gnuplot from source:"
	echo -e "${Yellow} "
	echo " --- Required wxgt3 dev library --- "
	echo " on debian: sudo apt install libwxgtk3.0-gtk3-dev build-essential"
	echo " on RedHat: sudo yum install wxgtk3-dev build-base"
	echo " wget https://sourceforge.net/projects/gnuplot/files/latest/download -O gnuplot.tar.gz"
	echo " tar -xvf gnuplot .tar.gz"
	echo " ./configure --with-wx"
	echo " make"
	echo -e " sudo make install ${Clear}"
	echo
	return -1
}



##########################################
#  ---- Check Package Installation ----  #
##########################################
function checkTool() {
    if command -v "$1" >/dev/null 2>&1; then
        echo -e "${Green}OK ${Clear}"
        return 0
    else
        echo -e "${Red}MISSING ${Clear}"
        return 1
    fi
}

function checkTools() {
	mMissing=1
    for tool in "$@"; do
        if command -v "$tool" >/dev/null 2>&1; then
			mMissing=$((mMissing-1))
			echo -e "${Green}OK ${Clear}"
			return 0
		fi
    done
	echo -e "${Red}MISSING ${Clear}"
    return 1
}


check_python_module() {
    module="$1"
    python3 -c "import $module" >/dev/null 2>&1
	res=$?
	if [ $res -eq 0 ]; then
		echo -e "${Green}OK ${Clear}"
		return 0
	else
		echo -e "${Red}MISSING ${Clear}"
		return 1
	fi
}


#################################
#  ----  General Summary -----  #
#################################
function generalSummary() {
	echo " PACKAGE    |  STATUS"
	echo " ---------------------"
	
	#g++
	echo -n " g++        |  "
	checkTool g++
	
	#make
	echo -n " make       |  "
	checkTool make
	
	#Libusb
	echo -n " libusb     |  "
	# debian-like
	usblib="/usr/lib/x86_64-linux-gnu/libusb-1.0.so"
	if [ -e $usblib ]; then
		echo -e "${Green}OK ${Clear}"
	else
		echo -e "${Red}MISSING ${Clear}"
	fi
	
	#Pkgconf
	echo -n " pkgconf    |  "
	checkTools pkgconf pkg-config
	
	#Gnuplot
	echo -n " gnuplot    |  "
	checkTool gnuplot
	
	#WithWXT
	echo -n " (with wxt) |  "
	availableTerms=$(gnuplot -e "set print '-'; print GPVAL_TERMINALS")
	if echo $availableTerms | grep -q "wxt"; then
		echo -e "${Green}OK ${Clear}"
	else
		echo -e "${Red}MISSING ${Clear}"
	fi
	
	#Python3
	echo -n " python3    |  "
	checkTool python3

	#tkinter
	echo -n " tkinter    |  "
	check_python_module	tkinter

	#Pillow
	echo -n " pillow     |  "
	check_python_module PIL	
	
	#TkImage
	echo -n " imagetk    |  "
	python3 -c "from PIL import ImageTk" 2>/dev/null
	res1=$?
	if [ $res1 -eq 0 ]; then
		echo -e "${Green}OK ${Clear}"
	else
		echo -e "${Red}MISSING ${Clear}"
	fi
}

###################################
###################################
# ---- MAIN ---- #
mDistro=$1
if [ -z $mDistro ]; then
	echo -e "${Yellow}Linux distribution missing"
	echo -e "Please, run the script with the linux distribution in use"
	echo -e "It can be faound in /etc/os-release, ID key${Clear}"
	exit 1
fi
distOk=1

# ---- Check if the script is run as root
isroot=`id -u`

echo -e "${Green}"
echo "######################################################################"
echo "#     #####  ######  #####  #   #     #####  #####  #####  #####     #"
echo "#     #      #    #  #      ##  #     #      #      #   #  #         #"
echo "#     #      # ## #  ####   # # #  -  ####   ####   # # #  #####     #"
echo "#     #      #    #  #      #  ##     #      #      #  #       #     #"
echo "#     #####  #    #  #####  #   #     #      #####  #   #  #####     #"
echo "######################################################################"
echo -e "${Clear}"

echo "CAEN FERSlib/Janus REQUIREMENTS CHECK:"

# ----- Package installed variables
iGpp=0
iMake=0
iLibusb=0
iPkgconf=0
iGnuplot=0
iWithwxt=0
iPython3=0
iTkinter=0
iPillow=0
iTkimage=0
iMissing=0

echo 
#echo -e " PACKAGE  ........  STATUS ${Clear}"
echo " PACKAGE    |  STATUS"
echo " ---------------------"
#echo " ---------------------------"

# ---- g++ ----
echo -n " g++        |  "
if checkTool g++; then
	iGpp=1
else
	iMissing=$(( iMissing+1 ))
fi

# ---- make ---- 
echo -n " make       |  "
if checkTool make; then
	iMake=1
else
	iMissing=$(( iMissing+1 ))
fi

# ---- Libusb ---- 
#echo -n " libusb   ........  "
echo -n " libusb     |  "
# debian-like
usblib="/usr/lib/x86_64-linux-gnu/libusb-1.0.so"
usblib="/usr/include/libusb-1.0/libusb.h"
# Let's have a look on libusb.h
if [ -e $usblib ]; then
	echo -e "${Green}OK ${Clear}"
	iLibusb=1
else
	echo -e "${Red}MISSING ${Clear}"
	iMissing=$((iMissing+1))
fi

# ---- Pkgconf ---- 
#echo -n " pkgconf  ........  "
echo -n " pkgconf    |  "
if checkTools pkgconf pkg-config; then
	iPkgconf=1
else
	iMissing=$((iMissing+1))
fi

# ---- Gnuplot ---- 
#echo -n " gnuplot  ........  "
echo -n " gnuplot    |  "

if checkTool gnuplot; then
	iGnuplot=1
else
	iMissing=$((iMissing+1))
fi

# ---- WithWXT ---- 
#echo -n " (with wxt) ......  "
echo -n " (with wxt) |  "
availableTerms=$(gnuplot -e "set print '-'; print GPVAL_TERMINALS")
if echo $availableTerms | grep -q "wxt"; then
	echo -e "${Green}OK ${Clear}"
	iWithwxt=1
else
	echo -e "${Orange}MISSING ${Clear}"
	iMissing=$((iMissing+1))
fi

# ---- Python3 ---- 
#echo -n " python3  ........  "
echo -n " python3    |  "
if checkTool python3; then
	iPython3=1
else
	iMissing=$((iMissing+1))
fi

# ---- tkinter ---- 
#echo -n " tkinter  ........  "
echo -n " tkinter    |  "
if check_python_module tkinter; then
	iTkinter=1
else
	iMissing=$((iMissing+1))
fi

# ---- Pillow ---- 
#echo -n " pillow  .........  "
echo -n " pillow     |  "
if check_python_module PIL; then
	iPillow=1
else
	iMissing=$((iMissing+1))
fi

# ---- ImageTK ----
#echo -n " tkImage ........  "
echo -n " imagetk    |  "
python3 -c "from PIL import ImageTk" 2>/dev/null
res1=$?
if [ $res1 -eq 0 ]; then
	echo -e "${Green}OK ${Clear}"
	iTkimage=1
else
	echo -e "${Red}MISSING ${Clear}"
	iMissing=$((iMissing+1))
fi
	
echo


if [ $iMissing -gt 0 ]; then
	echo -e "${Red}$iMissing package(s) missing...${Clear}"
	# ---- It can be run alone. In that case, do not try to install
	# package for the unsopported linux distribution
	case "$mDistro" in
		ubuntu|Ubuntu|debian|Debian)
			mDistro="debian"
			;;
		fedora|Fedora)
			mDistro="fedora"
			;;
		cenots|Centos|rhel|RedHat|redhat|Almalinux|almalinux|rocky|Rocky)
			mDistro="rhel"
			;;
		*)
			distOk=0
			echo -e "${Yellow}$iMissing package(s) still missing" 
			echo -e "You may not be able to install/run FERSlib/Janus succesfully ${Clear}"
			exit -2
			;;
	esac
		
	
	echo "Do you want to install the missing package(s)?"
	echo "N.B: Sudo privileges are required"
	while true; do
		read -p "[y][n]:" choice

		case "$choice" in
			y|Y)
				if sudo -v; then
					echo "Sudo authentication succesfull"
					echo "Installing missing package(s)"
					if [ $iGpp -eq 0 ]; then
						installPackage g++ $mDistro
						res=$?
						if [ $res -eq 0 ]; then iMissing=$((iMissing-1)) iGpp=1; fi
					fi
					if [ $iMake -eq 0 ]; then
						installPackage make $mDistro
						res=$?
						if [ $res -eq 0 ]; then iMissing=$((iMissing-1)) iMake=1; fi
					fi
					if [ $iLibusb -eq 0 ];  then 
						installPackage libusb $mDistro
						res=$?
						if [ $res -eq 0 ]; then iMissing=$((iMissing-1)) iLibusb=1; fi
					fi
					if [ $iPkgconf -eq 0 ]; then 
						installPackage Pkgonf $mDistro					
						res=$?
						if [ $res -eq 0 ]; then iMissing=$((iMissing-1)); iPkgconf=1; fi
					fi
					if [ $iGnuplot -eq 0 ]; then 
						installPackage gnuplot $mDistro
						res=$?
						if [ $res -eq 0 ]; then iMissing=$((iMissing-1)); iGnuplot=1; fi
					fi
					if [ $iWithwxt -eq 0 ]; then 
						availableTerms=$(gnuplot -e "set print '-'; print GPVAL_TERMINALS") 
						res=$?
						if [ $res -eq 0 ]; then 
							iMissing=$((iMissing-1)); 
							iWithwxt=1
						else
							InstallWxt
						fi
					fi
					if [ $iPython3 -eq 0 ]; then 
						installPackage python3 $mDistro 
						res=$?
						if [ $res -eq 0 ]; then iMissing=$((iMissing-1)); iPython3=1; fi
					fi
					if [ $iTkinter -eq 0 ]; then 
						installPackage tkinter $mDistro
						res=$?
						if [ $res -eq 0 ]; then iMissing=$((iMissing-1)); iTkinter=1; fi
					fi
					if [ $iPillow -eq 0 ]; then 
						installPackage pillow $mDistro 
						res=$?
						if [ $res -eq 0 ]; then iMissing=$((iMissing-1)); iPillow=1; fi
					fi
					if [ $iTkimage -eq 0 ]; then 
						installPackage imagetk $mDistro
						res=$?
						if [ $res -eq 0 ]; then iMissing=$((iMissing-1)); iTkimage=1; fi
					fi
			
				else
					echo "Sudo authentication failed"
				fi
				break
				;;
			n|N)
				echo "Installation skipped"
				echo -e "${Yellow}WARNING: you may not be able to install/run FERSlib/Janus succesfully ${Clear}"
				exit -2
				break
				;;
		esac
	done
	generalSummary
fi

if [ $iMissing -gt 0 ] && [ $distOk -eq 1 ]; then 
	echo -e "${Yellow}$iMissing package(s) still missing" 
	echo -e "You may not be able to install/run FERSlib/Janus succesfully ${Clear}"
	if [ iMissing -eq 1 ] && [ $iWithwxt -eq 0 ]; then
		exit 3
	else
		exit 2
	fi
else 
	echo -e "${Green}Check requirements completed${Clear}"
	exit 0
fi