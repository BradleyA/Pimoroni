#!/bin/bash
# 	setup-pi-display.sh  3.306.492  2019-01-07T22:15:31.619818-06:00 (CST)  https://github.com/BradleyA/pi-display  uadmin  six-rpi3b.cptx86.com 3.305  
# 	   testing pi-display-logrotate 
# 	setup-pi-display.sh  3.305.491  2019-01-07T22:09:51.154978-06:00 (CST)  https://github.com/BradleyA/pi-display  uadmin  six-rpi3b.cptx86.com 3.304  
# 	   testing pi-display-logroute 
# 	setup-pi-display.sh  3.304.490  2019-01-07T22:00:41.378445-06:00 (CST)  https://github.com/BradleyA/pi-display  uadmin  six-rpi3b.cptx86.com 3.303-1-g698fde4  
# 	   rename setup-display.sh -> setup-pi-display.sh 
# 	setup-display.sh  3.303.488  2019-01-07T17:21:49.734134-06:00 (CST)  https://github.com/BradleyA/pi-display  uadmin  six-rpi3b.cptx86.com 3.302-7-gbccf6ca  
# 	   testing pi-display-logrotate 
# 	setup-display.sh  3.302.480  2019-01-07T17:09:24.210585-06:00 (CST)  https://github.com/BradleyA/pi-display  uadmin  six-rpi3b.cptx86.com 3.301-2-gf312ca1  
# 	   setup pi-display-logrotate file creation 
# 	setup-display.sh  3.301.477  2019-01-06T21:28:37.100154-06:00 (CST)  https://github.com/BradleyA/pi-display  uadmin  six-rpi3b.cptx86.com 3.300  
# 	   complete testing on one-rpi3b 
# 	setup-display.sh  3.300.476  2019-01-06T21:11:50.940286-06:00 (CST)  https://github.com/BradleyA/pi-display  uadmin  six-rpi3b.cptx86.com 3.299  
# 	   testing new heading 
# 	setup-display.sh  3.269.428  2019-01-03T14:42:35.499629-06:00 (CST)  https://github.com/BradleyA/pi-display.git  uadmin  six-rpi3b.cptx86.com 3.268  
# 	   start creating setup for pi-display 
#
### setup-pi-display.sh
#   production standard 3
#       Order of precedence: environment variable, default code
if [ "${DEBUG}" == "" ] ; then DEBUG="0" ; fi   # 0 = debug off, 1 = debug on, 'export DEBUG=1', 'unset DEBUG' to unset environment variable (bash)
#       set -x
#       set -v
BOLD=$(tput -Txterm bold)
NORMAL=$(tput -Txterm sgr0)
###
display_help() {
echo -e "\n${NORMAL}${0} - setup system to gather and display Docker & System info"
echo -e "\nUSAGE\n   sudo ${0} "
echo    "   sudo ${0} [<CLUSTER>] [<DATA_DIR>] [<ADMUSER>] [ADMGRP] [EMAIL_ADDRESS]"
echo    "   ${0} [--help | -help | help | -h | h | -?]"
echo    "   ${0} [--version | -version | -v]"
echo -e "\nDESCRIPTION\nThis script has to be run as root to create /usr/local/data/<CLUSTER>.  The"
echo    "commands are installed in /usr/local/bin and will store logs, Docker and"
echo    "system information into /usr/local/data/<CLUSTER> directory.  The Docker"
echo    "information includes the number of containers, running containers, paused"
echo    "containers, stopped containers, and number of images.  The system information"
echo    "includes cpu temperature in Celsius and Fahrenheit, the system load, memory"
echo    "usage, and disk usage."
echo -e "\nThe information in /usr/local/data/<CLUSTER>/<hostname> file is created by"
echo    "create-host-info.sh and can be used by display-led.py for Raspberry Pi with"
echo    "Pimoroni Blinkt to display the system information in near real time.  It is"
echo    "also used by create-display-message.sh.  The <hostname> files are copied to"
echo    "each host found in /usr/local/data/<CLUSTER>/SYSTEMS and totaled in a file,"
echo    "/usr/local/data/<CLUSTER>/MESSAGE and MESSAGEHD.  The MESSAGE files include"
echo    "the total number of containers, running containers, paused containers,"
echo    "stopped containers, and number of images.  The MESSAGE files are used by a"
echo    "Raspberry Pi with Pimoroni Scroll-pHAT or Pimoroni Scroll-pHAT-HD to"
echo    "display the information."
echo -e "\nThis script reads /usr/local/data/<CLUSTER>/SYSTEMS file for hosts."
echo    "The hosts are one FQDN or IP address per line for all hosts in a cluster."
echo    "Lines in SYSTEMS file that begin with a # are comments.  The SYSTEMS file is"
echo    "used by Linux-admin/cluster-command/cluster-command.sh, markit/find-code.sh,"
echo    "pi-display/create-message/create-display-message.sh, and other scripts."
echo -e "\nEnvironment Variables"
echo    "If using the bash shell, enter; 'export DEBUG=1' on the command line to set"
echo    "the DEBUG environment variable to '1' (0 = debug off, 1 = debug on).  Use the"
echo    "command, 'unset DEBUG' to remove the exported information from the DEBUG"
echo    "environment variable.  To set an environment variable to be defined at login,"
echo    "add it to ~/.bashrc file or you can modify this script with your default"
echo    "location.  You are on your own defining environment variables if you are"
echo    "using other shells."
echo    "   CLUSTER         (default us-tx-cluster-1/)"
echo    "   DATA_DIR        (default /usr/local/data/)"
echo    "   DEBUG           (default '0')"
echo -e "\nOPTIONS"
echo    "   CLUSTER         name of cluster directory, default us-tx-cluster-1"
echo    "   DATA_DIR        path to cluster data directory, default /usr/local/data/"
echo    "   ADMUSER         site SRE administrator, default is user running script"
echo    "   ADMGRP          site SRE group, default is group running script"
echo    "   EMAIL_ADDRESS   SRE email address"
echo -e "\nDOCUMENTATION\n    https://github.com/BradleyA/pi-display-board"
echo -e "\nEXAMPLES\n   sudo ${0}\n"
echo -e "   sudo ${0} us-tx-cluster-1 /usr/local/data uadmin uadmin\n"
#       After displaying help in english check for other languages
if ! [ "${LANG}" == "en_US.UTF-8" ] ; then
        get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[WARN]${NORMAL}  ${LANG}, is not supported, Would you like to help translate?" 1>&2
#       elif [ "${LANG}" == "fr_CA.UTF-8" ] ; then
#               get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[WARN]${NORMAL}  Display help in ${LANG}" 1>&2
#       else
#               get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[WARN]${NORMAL}  Your language, ${LANG}, is not supported.  Would you like to translate?" 1>&2
fi
}

#       Date and time function ISO 8601
get_date_stamp() {
DATE_STAMP=$(date +%Y-%m-%dT%H:%M:%S.%6N%:z)
TEMP=$(date +%Z)
DATE_STAMP="${DATE_STAMP} (${TEMP})"
}

#       Fully qualified domain name FQDN hostname
LOCALHOST=$(hostname -f)

#       Version
SCRIPT_NAME=$(head -2 "${0}" | awk {'printf $2'})
SCRIPT_VERSION=$(head -2 "${0}" | awk {'printf $3'})

#       UID and GID
USER_ID=$(id -u)
GROUP_ID=$(id -g)

#       Added line because USER is not defined in crobtab jobs
if ! [ "${USER}" == "${LOGNAME}" ] ; then  USER=${LOGNAME} ; fi
if [ "${DEBUG}" == "1" ] ; then get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[DEBUG]${NORMAL}  Setting USER to support crobtab...  USER >${USER}<  LOGNAME >${LOGNAME}<" 1>&2 ; fi

#       Default help and version arguments
if [ "$1" == "--help" ] || [ "$1" == "-help" ] || [ "$1" == "help" ] || [ "$1" == "-h" ] || [ "$1" == "h" ] || [ "$1" == "-?" ] ; then
        display_help | more
        exit 0
fi
if [ "$1" == "--version" ] || [ "$1" == "-version" ] || [ "$1" == "version" ] || [ "$1" == "-v" ] ; then
        echo "${SCRIPT_NAME} ${SCRIPT_VERSION}"
        exit 0
fi

#       INFO
get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[INFO]${NORMAL}  Started..." 1>&2

#       DEBUG
if [ "${DEBUG}" == "1" ] ; then get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[DEBUG]${NORMAL}  Name_of_command >${0}< Name_of_arg1 >${1}< Name_of_arg2 >${2}< Name_of_arg3 >${3}<  Version of bash ${BASH_VERSION}" 1>&2 ; fi

###
#       Must be root to run this script
if ! [ $(id -u) = 0 ] ; then
	display_help | more
	get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[ERROR]${NORMAL}  Use sudo ${0}" 1>&2
	echo -e "\n>>   ${BOLD}SCRIPT MUST BE RUN AS ROOT${NORMAL} <<"  1>&2
        exit 1
fi

#       Order of precedence: CLI argument, environment variable, default code
if [ $# -ge  1 ]  ; then CLUSTER=${1} ; elif [ "${CLUSTER}" == "" ] ; then CLUSTER="us-tx-cluster-1/" ; fi
#       Order of precedence: CLI argument, environment variable, default code
if [ $# -ge  2 ]  ; then DATA_DIR=${2} ; elif [ "${DATA_DIR}" == "" ] ; then DATA_DIR="/usr/local/data/" ; fi
#       Order of precedence: CLI argument, default code
ADMUSER=${3:-$(id -u)}
#       Order of precedence: CLI argument, default code
ADMGRP=${4:-$(id -g)}
#       Order of precedence: CLI argument, environment variable, default code
if [ $# -ge  5 ]  ; then EMAIL_ADDRESS=${5} ; elif [ "${EMAIL_ADDRESS}" == "" ] ; then EMAIL_ADDRESS="root@${LOCALHOST}" ; fi
if [ "${DEBUG}" == "1" ] ; then get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[DEBUG]${NORMAL}  Variable... CLUSTER >${CLUSTER}< DATA_DIR >${DATA_DIR}< ADMUSER >${ADMUSER}< ADMGRP >${ADMGRP}< EMAIL_ADDRESS >${EMAIL_ADDRESS}<" 1>&2 ; fi

#
mkdir -p /usr/local/bin
mkdir -p ${DATA_DIR}/${CLUSTER}/log
mkdir -p ${DATA_DIR}/${CLUSTER}/logrotate

#   Change directory owner and group
chown    ${ADMUSER}:${ADMGRP} /usr/local/bin
chown -R ${ADMUSER}:${ADMGRP} ${DATA_DIR}

#   Change file mode bits
chmod 0775 /usr/local/bin
chmod 0775 ${DATA_DIR}
chmod 0775 ${DATA_DIR}/${CLUSTER}
chmod 0775 ${DATA_DIR}/${CLUSTER}/log
chmod 0775 ${DATA_DIR}/${CLUSTER}/logrotate

#   Move files
cp pi-display                                 ${DATA_DIR}/${CLUSTER}/logrotate
cp blinkt/display-led.py                      /usr/local/bin
cp blinkt/display-led-test.py                 /usr/local/bin
cp create-message/CPU_usage.sh                /usr/local/bin
cp create-message/create-display-message.sh   /usr/local/bin
cp create-message/create-host-info.sh         /usr/local/bin
cp scrollphat/display-message.py              /usr/local/bin
cp scrollphat/display-scrollphat-test.py      /usr/local/bin
cp scrollphathd/display-message-hd.py         /usr/local/bin
cp scrollphathd/display-scrollphathd-test.py  /usr/local/bin

#   Change file owner and group
chown ${ADMUSER}:${ADMGRP} /usr/local/bin/display-led.py
chown ${ADMUSER}:${ADMGRP} /usr/local/bin/display-led-test.py
chown ${ADMUSER}:${ADMGRP} /usr/local/bin/CPU_usage.sh
chown ${ADMUSER}:${ADMGRP} /usr/local/bin/create-display-message.sh
chown ${ADMUSER}:${ADMGRP} /usr/local/bin/create-host-info.sh
chown ${ADMUSER}:${ADMGRP} /usr/local/bin/display-message.py
chown ${ADMUSER}:${ADMGRP} /usr/local/bin/display-scrollphat-test.py
chown ${ADMUSER}:${ADMGRP} /usr/local/bin/display-message-hd.py
chown ${ADMUSER}:${ADMGRP} /usr/local/bin/display-scrollphathd-test.py

#   Change file mode bits
chmod 0664 ${DATA_DIR}/${CLUSTER}/logrotate/pi-display
chmod 0770 /usr/local/bin/display-led.py
chmod 0770 /usr/local/bin/display-led-test.py
chmod 0775 /usr/local/bin/CPU_usage.sh
chmod 0770 /usr/local/bin/create-display-message.sh
chmod 0770 /usr/local/bin/create-host-info.sh
chmod 0770 /usr/local/bin/display-message.py
chmod 0770 /usr/local/bin/display-scrollphat-test.py
chmod 0770 /usr/local/bin/display-message-hd.py
chmod 0770 /usr/local/bin/display-scrollphathd-test.py

#       Check if SYSTEMS file on system
if ! [ -e ${DATA_DIR}/${CLUSTER}/SYSTEMS ] ; then
	echo -e "\n\t${NORMAL}${DATA_DIR}/${CLUSTER}/SYSTEMS file not found ..."
	echo -e "\tCreating ${DATA_DIR}/${CLUSTER}/SYSTEMS file adding local host."
	echo -e "\n\t${BOLD}Edit ${DATA_DIR}/${CLUSTER}/SYSTEMS to add additional hosts.${NORMAL}"
	echo "###     List of hosts in cluster" >    ${DATA_DIR}/${CLUSTER}/SYSTEMS
	echo "#       Used by markit/find-code.sh, Linux-admin/cluster-command/cluster-command.sh," >> ${DATA_DIR}/${CLUSTER}/SYSTEMS
	echo "#       pi-display/create-message/create-display-message.sh, and other scripts." >> ${DATA_DIR}/${CLUSTER}/SYSTEMS
	echo "###" >> ${DATA_DIR}/${CLUSTER}/SYSTEMS
	echo "#       One FQDN or IP address on each line" >> ${DATA_DIR}/${CLUSTER}/SYSTEMS
	echo "###" >> ${DATA_DIR}/${CLUSTER}/SYSTEMS
	echo $(hostname -f) >> ${DATA_DIR}/${CLUSTER}/SYSTEMS
	chown ${ADMUSER}:${ADMGRP} ${DATA_DIR}/${CLUSTER}/SYSTEMS
	chmod 0664 ${DATA_DIR}/${CLUSTER}/SYSTEMS
fi

#	crontab
if [ -e /var/spool/cron/crontabs/${ADMUSER} ] ; then
	echo -e "\n\tCreating a copy of /var/spool/cron/crontabs/${ADMUSER}" 1>&2
	DATE_STAMP=$(date +%Y-%m-%dT%H:%M:%S.%6N%:z)
	cp /var/spool/cron/crontabs/${ADMUSER} /var/spool/cron/crontabs/${ADMUSER}.${DATE_STAMP}
	chown ${ADMUSER}:${ADMGRP} /var/spool/cron/crontabs/${ADMUSER}.${DATE_STAMP}
	chmod 0660 /var/spool/cron/crontabs/${ADMUSER}.${DATE_STAMP}
fi
touch /var/spool/cron/crontabs/${ADMUSER}
#
echo -e "\n\tUpdating /var/spool/cron/crontabs/${ADMUSER}" 1>&2
###	Raspberry Pi with blinkt for pi-display
echo    "# DO NOT EDIT THIS FILE - edit the master and reinstall."  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# "  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# (Cron version -- $Id: crontab.c,v 2.13 1994/01/17 03:20:37 vixie Exp $)"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "#   Edit this file to introduce tasks to be run by cron."  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "#   Raspberry Pi with blinkt for pi-display"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "#   Uncomment the following 7 lines on Raspberry Pi with blinkt installed for pi-display"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# @reboot   /usr/local/bin/display-led-test.py >> /usr/local/data/us-tx-cluster-1/log/`hostname -f`-crontab 2>&1"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# * * * * *            /usr/local/bin/create-host-info.sh >> /usr/local/data/us-tx-cluster-1/log/`hostname -f`-crontab 2>&1"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# * * * * * sleep 5  ; /usr/local/bin/display-led.py >> /usr/local/data/us-tx-cluster-1/log/`hostname -f`-crontab 2>&1"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# * * * * * sleep 20 ; /usr/local/bin/create-host-info.sh >> /usr/local/data/us-tx-cluster-1/log/`hostname -f`-crontab 2>&1"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# * * * * * sleep 25 ; /usr/local/bin/display-led.py >> /usr/local/data/us-tx-cluster-1/log/`hostname -f`-crontab 2>&1"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "* * * * * sleep 40 ; /usr/local/bin/create-host-info.sh >> /usr/local/data/us-tx-cluster-1/log/`hostname -f`-crontab 2>&1"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# * * * * * sleep 45 ; /usr/local/bin/display-led.py >> /usr/local/data/us-tx-cluster-1/log/`hostname -f`-crontab 2>&1"  >> /var/spool/cron/crontabs/${ADMUSER}
###     Raspberry Pi with scroll-pHAT for pi-display
echo -e "#\n#   scroll-pHAT for pi-display"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "#   Uncomment the following 3 lines and the line above which includes sleep 40 ; ... create-host-info.sh ... on Raspberry Pi with scroll-pHAT for pi-display"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# @reboot   /usr/local/bin/display-scrollphat-test.py >> /usr/local/data/us-tx-cluster-1/log/`hostname -f`-crontab 2>&1"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# */2 * * * *      /usr/local/bin/create-display-message.sh >> /usr/local/data/us-tx-cluster-1/log/`hostname -f`-crontab 2>&1"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# 1-59/2 * * * *   /usr/local/bin/display-message.py >> /usr/local/data/us-tx-cluster-1/log/`hostname -f`-crontab 2>&1"  >> /var/spool/cron/crontabs/${ADMUSER}
###	Raspberry Pi with scroll-pHAT-HD for pi-display
echo -e "#\n#   scroll-pHAT-HD for pi-display"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "#   Uncomment the following 3 lines and the line above which includes sleep 40 ; ... create-host-info.sh ... on Raspberry Pi with scroll-pHAT HD for pi-display"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# @reboot   /usr/local/bin/display-scrollphathd-test.py >> /usr/local/data/us-tx-cluster-1/log/`hostname -f`-crontab 2>&1"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# */2 * * * *      /usr/local/bin/create-display-message.sh >> /usr/local/data/us-tx-cluster-1/log/`hostname -f`-crontab 2>&1"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# 1-59/2 * * * *   /usr/local/bin/display-message-hd.py >> /usr/local/data/us-tx-cluster-1/log/`hostname -f`-crontab 2>&1"  >> /var/spool/cron/crontabs/${ADMUSER}
###     All Raspberry Pi's that include any above section to rotate logs for pi-display
echo -e "#\n#   All Raspberry Pi's that include any above section to rotate logs for pi-display"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "#   Uncomment the following line to rotate logs for pi-display"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# 6 */2 * * * /usr/sbin/logrotate -s /usr/local/data/us-tx-cluster-1/logrotate/status /usr/local/data/us-tx-cluster-1/logrotate/pi-display-logrotate >> /usr/local/data/us-tx-cluster-1/log/`hostname -f`-crontab 2>&1"  >> /var/spool/cron/crontabs/${ADMUSER}
###     Prometheus exporter for hardware and OS metrics exposed by *NIX kernels
echo -e "#\n#   Prometheus exporter for hardware and OS metrics exposed by *NIX kernels"  >> /var/spool/cron/crontabs/${ADMUSER}
echo    "# @reboot /usr/local/bin/node_exporter >> /usr/local/data/us-tx-cluster-1/log/`hostname -f`-crontab 2>&1"  >> /var/spool/cron/crontabs/${ADMUSER}
#
chown ${ADMUSER}:crontab /var/spool/cron/crontabs/${ADMUSER}
chmod 0600 /var/spool/cron/crontabs/${ADMUSER}
echo -e "\n\t${BOLD}Edit /var/spool/cron/crontabs/${ADMUSER} using crontab -e" 1>&2
echo -e "\tUncomment the section that is needed for your Raspberry Pi\n${NORMAL}" 1>&2

#	logrotate
#
#
### pi-display-logrotate - logrotate conf file
echo -e "#\n#\n#" > ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "${DATA_DIR}/${CLUSTER}/log/${LOCALHOST}-crontab {"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "    daily"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "    su ${ADMUSER} ${ADMGRP}"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "    rotate 60"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "    create 0644 ${ADMUSER} ${ADMGRP}"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "    compress"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "    size 25"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "    olddir ../logrotate"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "    notifempty"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "    mail ${EMAIL_ADDRESS}"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "    prerotate"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "        /bin/ls -l ${DATA_DIR}/${CLUSTER}/log/${LOCALHOST}-crontab >> ${DATA_DIR}/${CLUSTER}/log/${LOCALHOST}-crontab"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "        /bin/grep -nv '\[INFO\]' ${DATA_DIR}/${CLUSTER}/log/${LOCALHOST}-crontab | grep -iv 'info' > incident.tmp"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "        /bin/grep -B 1 -A 1 -ni '\[WARN\]\|ERROR' ${DATA_DIR}/${CLUSTER}/log/${LOCALHOST}-crontab >> incident.tmp"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "        /usr/bin/sort -n -u incident.tmp | grep -v '\-\-$' > incident"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "        DATE_TMP=\$\(date +%Y-%m-%dT%H:%M:%S\)"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "        cp incident incident-\$DATE_TMP"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "        /bin/rm incident.tmp"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "        /usr/bin/mail -s 'incident report ${LOCALHOST}-crontab' ${EMAIL_ADDRESS} < incident"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "    endscript"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate
echo    "}"  >>  ${DATA_DIR}/${CLUSTER}/logrotate/pi-display-logrotate


#
get_date_stamp ; echo -e "${NORMAL}${DATE_STAMP} ${LOCALHOST} ${0}[$$] ${SCRIPT_VERSION} ${LINENO} ${USER} ${USER_ID}:${GROUP_ID} ${BOLD}[INFO]${NORMAL}  Operation finished." 1>&2
###
