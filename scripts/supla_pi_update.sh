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

NOW=$(date +"%Y%m%d%H%M%S")
tempdir=`mktemp -d`

cd $tempdir

if [ -e /etc/init.d/supla-server ]; then
 /etc/init.d/supla-server stop
fi

if [ -e /etc/init.d/supla-dev ]; then
 /etc/init.d/supla-dev stop
fi

/etc/init.d/apache2 stop

if [ -e /var/www/html/app/config/parameters.yml ]; then
   git clone https://github.com/SUPLA/supla-cloud || exit 1

   mv /var/www/html /var/www/html_old_"$NOW"
   mv ./supla-cloud /var/www/html

   cp /var/www/html_old_"$NOW"/app/config/parameters.yml /var/www/html/app/config/parameters.yml
   chown -R www-data:www-data /var/www/html

   cd /var/www/html

   grep supla_server_list app/config/parameters.yml 2> /dev/null > /dev/null || \
     echo "    supla_server_list: ~" >> app/config/parameters.yml

   if [ ! -e app/bootstrap.php.cache ]; then
     cp /var/www/html_old_"$NOW"/app/bootstrap.php.cache app/
   fi 

   if [ ! -e clear_cache.php ]; then
     cp /var/www/html_old_"$NOW"/clear_cache.sh ./
   fi

   if [ ! -e vendor ]; then
     cp -r /var/www/html_old_"$NOW"/vendor ./
   fi

   ./clear_cache.sh

fi

cd $tempdir
git clone https://github.com/SUPLA/raspberry || exit 1

if [ -e /usr/sbin/supla-server ]; then
   cp /usr/sbin/supla-server /usr/sbin/supla-server_"$NOW"
   cp raspberry/server-rbpi3/usr/sbin/supla-server /usr/sbin/

   chown root:root /usr/sbin/supla-server
   chmod +x /usr/sbin/supla-server
fi

if [ -e /usr/sbin/supla-dev ]; then
   cp /usr/sbin/supla-dev /usr/sbin/supla-dev_"$NOW"
   cp raspberry/ext01/usr/sbin/supla-dev /usr/sbin/
   
   chown root:root /usr/sbin/supla-dev
   chmod +x /usr/sbin/supla-dev   
fi

cd
rm -r $tempdir


if [ -e /etc/init.d/supla-server ]; then
 /etc/init.d/supla-server start
fi

if [ -e /etc/init.d/supla-dev ]; then
 /etc/init.d/supla-dev start
fi 

if [ -e /etc/init.d/apache2 ]; then
/etc/init.d/apache2 start
fi

echo FINISH
