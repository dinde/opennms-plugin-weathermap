#!/bin/bash

## opennms-install-weathermap.sh
##
# Author: David "Dinde" <kayser@euroserv.com>
# Version: 1.0
# Licence:
##

## Functions
# Distrib dectection
function os_detect(){
	echo "NOTICE: Detecting if this script is compatible with OS detection."
	if [ -f /etc/redhat-release ] ; then
		DISTRO='rpm'
		echo "NOTICE: rpm based distro detected."
	elif [ -f /etc/debian_version ] ; then
		DISTRO='deb'
		echo "NOTICE: deb based distro detected."
	else
		echo "FATAL: I can't detect your distro. Supported distro are: debian/ubuntu, centos/redhat."
		exit 1
	fi
}

function get_deps(){
	if [ "$DISTRO" = 'deb' ] ; then
	        echo "NOTICE: Getting dependencies ..."
	        apt-get install -y librrds-perl libgd-gd2-perl librrd4 unzip
	elif [ "$DISTRO" = 'rpm' ] ; then
	        echo "NOTICE: Getting dependencies ..."
	        yum install -y unzip patch perl-GD rrdtool-perl
	fi
}
function get_pkg(){
	echo "NOTICE: Downloading the sources ..."
	git clone https://github.com/dinde/opennms-plugin-weathermap.git opennms-plugin-weathermap
	if [ "$?" != "0" ] ; then
		echo "WARNING: git is not installed ! Trying to wget it."
		wget https://github.com/dinde/opennms-plugin-weathermap/archive/master.zip -O opennms-plugin-weathermap.zip
		if [ "$?" != "0" ] ; then
			echo "FATAL: wget failed as well ! Not more method left, exiting ..."
			exit 1
		else 
			echo "NOTICE: opennms-plugin-weathermap.zip downloaded to $(pwd) !"
			unzip opennms-plugin-weathermap.zip 
			mv opennms-plugin-weathermap-master opennms-plugin-weathermap
			if [ "$?" != "0" ] ; then
				echo "Can't extract the zip archive. unzip is missing, exiting ..."
				exit 1
			fi
		fi
	fi
}

function deploy_deb(){
	echo "NOTICE: Deploying files for deb based distro ..."
	if [ -d "/usr/share/opennms/jetty-webapps/opennms/" ] ; then
		cp -ar opennms-plugin-weathermap/webapps/weathermap/ /usr/share/opennms/jetty-webapps/opennms/
		echo "SUCCESS: webapps deployed !"
	else
		echo "FATAL: webapps folder is missing, exiting ..."
		exit 1
	fi
	
	if [ -d "/etc/opennms/" ] ; then
		cp -ar opennms-plugin-weathermap/configs/etc/opennms/weathermap/ /etc/opennms/
		cp -ar opennms-plugin-weathermap/configs/etc/opennms/weathermap.enable /etc/opennms/
		echo "SUCCESS: configuration files deployed !"
	else
		echo "FATAL: /etc/opennms/ folder is missing, exiting ..."
		exit 1
	fi

	if [ -d "/usr/share/opennms/bin/" ] ; then
		cp -ar opennms-plugin-weathermap/patchs/weathermap4-rrd-1.2RC3/patched_files/weathermap4rrd /usr/share/opennms/bin/
		chmod +x /usr/share/opennms/bin/weathermap4rrd
		echo "SUCCESS: weathermap4rrd deployed !"
	else
		echo "FATAL: Opennms bin folder is missing, exiting ..."
		exit 1
	fi
	
	if [ -f "/usr/share/opennms/jetty-webapps/opennms/WEB-INF/dispatcher-servlet.xml" ] ; then
		patch /usr/share/opennms/jetty-webapps/opennms/WEB-INF/dispatcher-servlet.xml < opennms-plugin-weathermap/patchs/opennms-webapps/dispatcher-servlet.xml.patch
		echo "SUCCESS: dispatcher-servlet.xml patched !"
	else
		echo "FATAL: dispatcher-servlet.xml is missing, exiting ..."
		exit 1
	fi

	if [ -d "/etc/cron.d/" ] ; then
		if [ ! -f "/etc/cron.d/opennms_weathermap" ] ; then
			echo -e "#\!/bin/bash\n#*/5 * * * if [ -f /etc/opennms/weathermap.enable ] ; then for i in \$(ls /etc/opennms/weathermap/*.conf) ; do /usr/share/opennms/bin/weathermap4rrd -c \$i ; done fi" > /etc/cron.d/opennms_weathermap
			chmod +x /etc/cron.d/opennms_weathermap
			echo "SUCCESS: crontab deployed to /etc/cron.d/opennms_weathermap !"
		else
			echo "WARNING: files already exists."
		fi
	else
		echo "FATAL: cron is not installed, exiting ..."
	fi
}

function deploy_rpm(){
	echo "NOTICE: Deploying files for rpm based distro ..."
    if [ -d "/opt/opennms/jetty-webapps/opennms/" ] ; then
        cp -ar opennms-plugin-weathermap/webapps/weathermap/ /opt/opennms/jetty-webapps/opennms/
        echo "SUCCESS: webapps deployed !"
    else
        echo "FATAL: webapps folder is missing, exiting ..."
        exit 1
    fi

    if [ -d "/opt/opennms/etc/" ] ; then
        cp -ar opennms-plugin-weathermap/configs/etc/opennms/weathermap/ /opt/opennms/etc/
        cp -ar opennms-plugin-weathermap/configs/etc/opennms/weathermap.enable /opt/opennms/etc/
        echo "SUCCESS: configuration files deployed !"
    else
        echo "FATAL: /etc/opennms/ folder is missing, exiting ..."
        exit 1
    fi

    if [ -d "/opt/opennms/bin/" ] ; then
        cp -ar opennms-plugin-weathermap/patchs/weathermap4-rrd-1.2RC3/patched_files/weathermap4rrd /opt/opennms/bin/
        chmod +x /opt/opennms/bin/weathermap4rrd
		echo "SUCCESS: weathermap4rrd deployed !"
    else
        echo "FATAL: Opennms bin folder is missing, exiting ..."
        exit 1
    fi

    if [ -f "/opt/opennms/jetty-webapps/opennms/WEB-INF/dispatcher-servlet.xml" ] ; then
        patch /opt/opennms/jetty-webapps/opennms/WEB-INF/dispatcher-servlet.xml < opennms-plugin-weathermap/patchs/opennms-webapps/dispatcher-servlet.xml.patch
        echo "SUCCESS: dispatcher-servlet.xml patched !"
    else
        echo "FATAL: dispatcher-servlet.xml is missing, exiting ..."
        exit 1
    fi

    if [ -d "/etc/cron.d/" ] ; then
        if [ ! -f "/etc/cron.d/opennms_weathermap" ] ; then
            echo -e "#\!/bin/bash\n#*/5 * * * if [ -f /opt/opennms/etc/weathermap.enable ] ; then for i in \$(ls /opt/opennms/etc/weathermap/*.conf) ; do /opt/opennms/bin/weathermap4rrd -c \$i ; done fi" > /etc/cron.d/opennms_weathermap
            chmod +x /etc/cron.d/opennms_weathermap
            echo "SUCCESS: crontab deployed to /etc/cron.d/opennms_weathermap !"
        else
            echo "WARNING: files already exists."
        fi
    else
        echo "FATAL: cron is not installed, exiting ..."
    fi

}

## Start
os_detect

get_deps

get_pkg

if [ "$DISTRO" = 'deb' ] ; then
	deploy_deb
elif [ "$DISTRO" = 'rpm' ] ; then
	deploy_rpm
else
	echo "FATAL: How did you arrive until here ... Distribution not detected, exiting ...."
fi

echo "ENDED: Don't forget to check out all required dependecies."
echo "INFO: It's now time to configure your default map thru default.conf file !!!"
echo "HELP ?: For more informations, visit: https://github.com/dinde/opennms-plugin-weathermap/ & http://www.owns.fr !"

exit 0
