####################################
# Opennms's Weathermap Integration #
####################################

- Version: 1.0 - David "Dinde" OH <david@ows.fr> 01/11/2013

=== Features ===
* Based on weathermap4rrd, the perl script has been patched in order to accept Opennms RRDs.
* Two new directives are TARGETIN/TARGETOUT. 
* Backward compatible with previous versions of weathermap4rrd (perl script) TARGET directive.
* Integration inside Opennms Maps section.
* Support multiples WeatherMaps to be displayed with self refresh. (Always use jetty-webapps/opennms/weathermap/img folder to output your png files)
* You can enable/disable the UI integration by changing weathermap.enable file to weathermap.disable

=== Install ===
== Automated ==
  For .deb or .rpm based distributions:
  wget -O - https://raw.github.com/dinde/opennms-plugin-weathermap/master/opennms-install-weathermap.sh | /bin/bash

== Manual ==
* Download or git clone
* https://github.com/dinde/opennms-plugin-weathermap/

* Copy opennms-plugin-weathermap/webapps/weathermap/ folder to:
- Debian: /usr/share/opennms/jetty-webapps/opennms/
- Centos: /opt/opennms/jetty-webapps/opennms/

* Copy opennms-plugin-weathermap/configs/etc/opennms/weathermap/ folder to:
- Debian: /etc/opennms/
- Centos: /opt/opennms/etc/

* Copy opennms-plugin-weathermap/configs/etc/opennms/weathermap.enable to:
- Debian: /etc/opennms/
- Centos: /opt/opennms/etc/

* chmod +x opennms-plugin-weathermap/patchs/weathermap4-rrd-1.2RC3/patched_files/weathermap4-rrd-1.2RC3/patched_files/weathermap4rrd
* Copy opennms-plugin-weathermap/patchs/weathermap4-rrd-1.2RC3/patched_files/weathermap4-rrd-1.2RC3/patched_files/weathermap4rrd to:
- Debian: /usr/share/opennms/bin/
- Centos: /opt/opennms/bin/

* Patch opennms-webapps/WEB-INF/dispatcher-servlet.xml
* Copy opennms-plugin-weathermap/patchs/opennms-webapps/dispatcher-servlet.xml.patch to:
- Debian: /usr/share/opennms/jetty-webapps/opennms/WEB-INF/ 
* cd /usr/share/opennms/jetty-webapps/opennms/WEB-INF/ && patch < dispatcher-servlet.xml.patch
- Centos: /opt/opennms/jetty-webapps/opennms/WEB-INF/
* cd /opt/opennms/jetty-webapps/opennms/WEB-INF/ && patch < dispatcher-servlet.xml.patch
OR
* Backup then Copy patched file for (Opennms > 1.10) opennms-plugin-weathermap/patchs/opennms-webapps/patched_file/dispatcher-servlet.xml to:
- Debian: /usr/share/opennms/jetty-webapps/opennms/WEB-INF/
* cd /usr/share/opennms/jetty-webapps/opennms/WEB-INF/ && mv dispatcher-servlet.xml dispatcher-servlet.xml.ori
- Centos: /opt/opennms/jetty-webapps/opennms/WEB-INF/
* cd /opt/opennms/jetty-webapps/opennms/WEB-INF/ && dispatcher-servlet.xml dispatcher-servlet.xml.ori

* Add a crontab entry:
- Debian: echo -e "#!/bin/bash \n */5 * * * for i in \$(ls /etc/opennms/weathermap/*.conf) \; do /usr/share/opennms/bin/weathermap4rrd -c \$i \; done" > /etc/cron.d/opennms_weathermap
- Centos: echo -e "#!/bin/bash \n */5 * * * for i in \$(ls /opt/opennms/etc/weathermap/*.conf) \; do /opt/opennms/bin/weathermap4rrd -c \$i ; done" > /etc/cron.d/opennms_weathermap
* chmod +x /etc/cron.d/opennms_weathermap

=== Setup ===
* Configure default.conf (keep always this one) and add more file.conf as wanted/needed
* Maps will show up in the Opennms UI as long the output folder is at: jetty-webapps/opennms/weathermap/img/maps/

=== Patched files ===
* weathermap4rrd: (perl) TARGETIN/TARGETOUT
* opennms/WEB-INF/dispatcher-servlet.xml: Added Weathermap definition for menu

=== Added folders/files ===
* jetty-webapps/opennms/weathermap/index.jsp: page displaying the maps (selectbox if many png on img folder). Self refresh 60s
* jetty-webapps/opennms/weathermap/img/maps/default.png: same as example.png, will be replaced when cron activated
* jetty-webapps/opennms/weathermap/img/maps/example.png: an explicative map of the configuration file
* jetty-webapps/opennms/weathermap/img/backgrounds/black.png: a default black background
* jetty-webapps/opennms/weathermap/img/backgrounds/default.png: black background + legends of provided icons
* jetty-webapps/opennms/weathermap/img/backgrounds/psd/default.psd: source of black background + legends of provided icons
* jetty-webapps/opennms/weathermap/img/icons/: pack of icons + the one which came with weathermap4rrd
* /etc/opennms/weathermap.enable: to disable/enable the weathermap link
* /etc/opennms/weathermap/: folder with configuration files for weathermap4rrd 
* /etc/opennms/weathermap/default.conf: default template configuration 

=== Dependencies ===
* perl
* libdbi0 
* libgd-gd2-perl 
* libgd2-xpm 
* librrd4 
* librrds-perl
* crontab
* opennms

=== Thanks ===
  FabriceB, Nicolas AUBIN, defr, Alexandre Fontelle (initial perl version of Weathermap4RRD)

