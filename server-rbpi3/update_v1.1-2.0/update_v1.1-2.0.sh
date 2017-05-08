#!/bin/sh

##
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
# 
# @author Przemyslaw Zygmunt przemek@supla.org
##

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root. For example sudo ./supla_pi_update.sh" 1>&2
   exit 1
fi

if [ ! -d "/var/www/html/src/AppBundle" ]; then

   if grep "supla cloud 2.0" /var/www/html/src/SuplaBundle/Resources/views/Account/view.html.twig 2> /dev/null > /dev/null; then
     echo CLOUD v2.0 already installed
   else
     echo "Unknown CLOUD version"
   fi

   exit 1
fi

now=$(date +"%m%d%Y%H%M%S")

apt-get update
apt-get -y upgrade

mysqldump -u root -praspberry supla > /var/backups/supla"$now".sql
gzip /var/backups/supla"$now".sql


if dpkg --list | grep php7 2> /dev/null > /dev/null; then
  echo PHP7 already installed
else

   if grep stretch /etc/apt/sources.list 2> /dev/null > /dev/null; then
      echo stretch respority already added
   else
      echo "deb http://mirrordirector.raspbian.org/raspbian/ stretch main contrib non-free rpi" >> /etc/apt/sources.list
      echo "Package: *\nPin: release n=jessie\nPin-Priority: 600" > /etc/apt/preferences
      apt-get update
   fi

   x="$(dpkg --list | grep php | awk '/^ii/{ print $2}')"
   apt-get -y --purge remove $x
   apt-get install -y -t stretch libapache2-mod-php7.0 php7.0-mysql php7.0-curl php7.0-intl php-pear php7.0-mbstring php7.0-zip 
fi

if dpkg --list | grep ntp 2> /dev/null > /dev/null; then
  echo NTP already installed
else
  apt-get install -y ntp
  mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql -praspberry
fi

[ -e /etc/init.d/supla-server ] && /etc/init.d/supla-server stop
[ -e /etc/init.d/supla-scheduler ] && /etc/init.d/supla-scheduler stop

[ -e /usr/sbin/supla-server_v1.1 ] || cp /usr/sbin/supla-server /usr/sbin/supla-server_v1.1 
[ -d /var/www/html_old_v1.1 ] || mv /var/www/html /var/www/html_old_v1.1 

cp /var/www/html_old_v1.1/app/config/parameters.yml ./update_files_v1.1-2.0/var/www/html/app/config/
cp -r update_files_v1.1-2.0/* /

if ! grep use_webpack_dev_server /var/www/html/app/config/parameters.yml 2> /dev/null > /dev/null; then
  echo "    use_webpack_dev_server: false" >> /var/www/html/app/config/parameters.yml
fi

if ! grep supla_server_list /var/www/html/app/config/parameters.yml 2> /dev/null > /dev/null; then
  echo "\n    supla_server_list: ~" >> /var/www/html/app/config/parameters.yml
fi

ls /etc/rc*.d |grep supla-server 2> /dev/null > /dev/null || update-rc.d supla-server defaults
ls /etc/rc*.d |grep supla-scheduler 2> /dev/null > /dev/null || update-rc.d supla-scheduler defaults

cd /var/www/html
./clear_cache.sh

php bin/console --no-interaction doctrine:migrations:migrate

if ! grep "supla:maintenance min" /etc/crontab 2> /dev/null > /dev/null; then
   echo "* *     * * *   root   php /var/www/html/bin/console supla:maintenance min 2>> /var/log/maintenance-min.err.log > /var/log/maintenance-min.log" >> /etc/crontab
fi

if ! grep "supla:maintenance day" /etc/crontab 2> /dev/null > /dev/null; then
   echo "1 22     * * *   root   php /var/www/html/bin/console supla:maintenance day 2>> /var/log/maintenance-day.err.log > /var/log/maintenance-day.log" >> /etc/crontab
fi

if ! grep "supla:generate-schedules-executions" /etc/crontab 2> /dev/null > /dev/null; then
   echo "1 */4    * * *   root   php /var/www/html/bin/console supla:generate-schedules-executions 2>> /var/log/generate-schedules-executions.err.log > /var/log/generate-schedules-executions.log" >> /etc/crontab
fi

systemctl daemon-reload
/etc/init.d/apache2 restart
/etc/init.d/supla-server start
/etc/init.d/supla-scheduler start

echo "FINISH!"
