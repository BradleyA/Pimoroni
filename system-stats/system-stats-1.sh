#!/bin/bash
# 	system-stats/system-stats-1.sh  3.75.189  2018-08-12_21:26:10_CDT  https://github.com/BradleyA/pi-display  uadmin  three-rpi3b.cptx86.com 3.74  
# 	   sync to standard script design changes 
# 	system-stats/system-stats-1.sh  2.8.47  2018-02-28_12:46:40_CST  https://github.com/BradleyA/pi-display  uadmin  three-rpi3b.cptx86.com 2.7-7-gca0e0da  
# 	   moved cpu-temperature and syste-stats project into this repository 
# 	system-stats-1.sh	1.12.51	2018-02-23_09:09:04_CST uadmin six-rpi3b.cptx86.com 1.11-3-g63003c3 
# 	   added a comment about project 
# 	../system-stats/system-stats-1.sh	1.4.34	2018-02-21_21:22:51_CST uadmin six-rpi3b.cptx86.com 1.3 
# 	   ruff draft addition display_help cpu-temperature.sh & system-stats-1.sh 
#	system-stats-1.sh	1.0	2017-12-20_22:12:37_CST uadmin rpi3b-two.cptx86.com
#	initial version
###
#   	evaluate different states for raspberry pi
###
DEBUG=0                 # 0 = debug off, 1 = debug on
#       set -x
#       set -v
BOLD=$(tput bold)
NORMAL=$(tput sgr0)
###
display_help() {
echo -e "\n${NORMAL}${0} - >>> NEED TO COMPLETE THIS SOON, ONCE I KNOW HOW IT IS GOING TO WORK :-) <<<"
echo -e "\nUSAGE\n   ${0}"
echo    "   ${0} [--help | -help | help | -h | h | -? | ?]"
echo    "   ${0} [--version | -version | -v]"
echo -e "\nDESCRIPTION\nXXXXXX "
echo -e "\nOPTIONS "
echo -e "\nDOCUMENTATION\n   https://github.com/BradleyA/pi-scripts/tree/master/system-stats-1.sh"
echo -e "\nEXAMPLES\n   ${0}\n\n   XXXXXX\n"
if ! [ "${LANG}" == "en_US.UTF-8" ] ; then
        echo -e "${NORMAL}${0} ${LINENO} [${BOLD}WARNING${NORMAL}]:     Your language, ${LANG}, is not supported.\n\tWould you like to help?\n" 1>&2
fi
}
if [ "$1" == "--help" ] || [ "$1" == "-help" ] || [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "h" ] || [ "$1" == "-?" ] || [ "$1" == "?" ] ; then
        display_help
        exit 0
fi
if [ "$1" == "--version" ] || [ "$1" == "-version" ] || [ "$1" == "version" ] || [ "$1" == "-v" ] ; then
        head -2 ${0} | awk {'print$2"\t"$3'}
        exit 0
fi
###
#	if [ "${DEBUG}" == "1" ] ; then echo -e "> DEBUG ${LINENO}  >${0}<  >${1}<" 1>&2 ; fi
###
echo -e "Need to determine what I want to use in these notes to move forward with this project.  On hold until a later time.\n"
echo -e  " -->  Hostname = " `hostname`

CPUTEMP=$(/usr/bin/vcgencmd measure_temp | \
sed -e 's/?C$//' | \
sed -e 's/temp=//')

CPUTEMP=${CPUTEMP//\'C/}

echo "Celsius =	" $CPUTEMP
echo $CPUTEMP | awk '{print "Fahrenheit =	" 1.8 * $1 +32}'

cat /proc/cpuinfo

echo ""
#	Shows clock frequency, clock can be one of arm, core, h264, isp, v3d, uart, pwm, emmc, pixel, vec, hdmi, dpi. 
for src in arm core h264 isp v3d uart pwm emmc pixel vec hdmi dpi ; do \
	echo -e "$src:\t$(vcgencmd measure_clock $src)" ; \
done

echo ""
echo "/opt/vc/bin/vcgencmd measure_temp"
/opt/vc/bin/vcgencmd measure_temp

echo ""
echo "/opt/vc/bin/vcgencmd measure_volts"
/opt/vc/bin/vcgencmd measure_volts

#	Shows voltage. id can be one of core, sdram_c, sdram_i, sdram_p, and defaults to core if not specified.
echo ""
for id in core sdram_c sdram_i sdram_p ; do \
	echo -e "$id:\t$(vcgencmd measure_volts $id)" ; \
done

echo ""
echo "/usr/bin/vcgencmd measure_temp"
/usr/bin/vcgencmd measure_temp


#	cgencmd get_config [config|int|str] Will print the configurations you have set.
#	Argument can ether be a specific option or int, showing all configs with
#	 number-datatype, or str showing all configurations with datatype sting (aka text). 
echo ""
vcgencmd get_config int



#	Shows how much memory is split between the CPU (arm) and GPU.
echo ""
vcgencmd get_mem arm && vcgencmd get_mem gpu


#	Shows the firmware version
echo ""
vcgencmd version


echo""


#	Here is a script I found on the internet written by Mickaël Le Baillif
#		https://superuser.com/users/177298/micka%c3%abl-le-baillif
#
cat /proc/cpuinfo | \
awk -v FS=':' '                                       \
  /^physical id/ { if(nb_cpu<$2)  { nb_cpu=$2 } }     \
  /^cpu cores/   { if(nb_cores<$2){ nb_cores=$2 } }   \
  /^processor/   { if(nb_units<$2){ nb_units=$2 } }   \
  /^model name/  { model=$2 }                         \
                                                      \
  END{                                                \
   nb_cpu=(nb_cpu+1);                                 \
   nb_units=(nb_units+1);                             \
                                                      \
   print "CPU model:",model;                          \
   print nb_cpu,"CPU,",nb_cores,"physical cores per CPU, total",nb_units,"logical CPU units" \
 }'

#	This is a very cool cluster ssh tool that needs more of my time written by Duncan Ferguson
#		Cluster SSH - Cluster Admin Via SSH https://github.com/duncs/clusterssh/wiki
#
#	The command opens an administration console and an xterm to all
#	    specified hosts. Any text typed into the administration console is
#	    replicated to all windows. All windows may also be typed into directly.

#	More work needed to see how itf I want to use this
#	xinetd - the extended Internet services daemon
#		sudo apt install xinetd
#	
#	xinetd  performs  the  same function as inetd: it starts programs that provide Internet services.
#		Instead of having such servers started at system initialization time, and be dormant until
#		a connection request arrives, xinetd is the only dae‐mon process started and it listens
#		on all service ports for the services listed in its configuration file. When a request



