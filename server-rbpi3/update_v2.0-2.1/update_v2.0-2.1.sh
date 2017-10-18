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
   echo "This script must be run as root. For example sudo ./update_v2.0-2.1.sh" 1>&2
   exit 1
fi

if [ -e /var/www/html/app/DoctrineMigrations/Version20170818114139.php ]; then
  echo CLOUD v2.1 already installed
  exit 1
fi

if grep "supla cloud 2.0" /var/www/html/src/SuplaBundle/Resources/views/Account/view.html.twig 2> /dev/null > /dev/null; then
  echo CLOUD v2.0 detected
else
  echo CLOUD v2.0 not detected
  exit 1
fi

now=$(date +"%m%d%Y%H%M%S")

mysqldump -u root -praspberry supla > /var/backups/supla"$now".sql
gzip /var/backups/supla"$now".sql

[ -e /etc/init.d/supla-server ] && /etc/init.d/supla-server stop
[ -e /etc/init.d/supla-scheduler ] && /etc/init.d/supla-scheduler stop

[ -e /usr/sbin/supla-server_v2.0 ] || cp /usr/sbin/supla-server /usr/sbin/supla-server_v2.0

[ -d /var/www/html_old_v2.0 ] || mv /var/www/html /var/www/html_old_v2.0

cp /var/www/html_old_v2.0/app/config/parameters.yml ./update_files_v2.0-2.1/var/www/html/app/config/
cp -r update_files_v2.0-2.1/* /

grep "supla_autodiscover_server" /var/www/html/app/config/parameters.yml > /dev/null 2>&1 || echo "    supla_autodiscover_server: ~" >> /var/www/html/app/config/parameters.yml

cd /var/www/html
./clear_cache.sh

php bin/console --no-interaction doctrine:migrations:migrate

systemctl daemon-reload
/etc/init.d/apache2 restart
/etc/init.d/supla-server start
/etc/init.d/supla-scheduler start

echo "FINISH!"
