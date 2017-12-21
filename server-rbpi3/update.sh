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
# @author Michał Wieczorek @michael
# Special thanks to @fracz
##

CLOUD_VERSION=2.1.6
SERVER_VERSION=1.8.5


if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root. For example sudo ./$(basename "$0") 1>&2
   exit 1
fi

now=$(date +"%m%d%Y%H%M%S")

mysqldump -u root -p raspberry supla > /var/backups/supla"$now".sql
gzip /var/backups/supla"$now".sql

wget https://github.com/SUPLA/supla-cloud/releases/download/v${CLOUD_VERSION}/supla-cloud-v${CLOUD_VERSION}.tar.gz
wget https://github.com/SUPLA/supla-core/releases/download/v1.8.5/supla-server-v${SERVER_VERSION}-arm32v7.tgz

[ -e /etc/init.d/supla-server ] && /etc/init.d/supla-server stop
[ -e /etc/init.d/supla-scheduler ] && /etc/init.d/supla-scheduler stop

[ -e /usr/sbin/supla-server_"$now" ] || cp /usr/sbin/supla-server /usr/sbin/supla-server_"$now"
[ -e /usr/sbin/supla-scheduler_"$now" ] || cp /usr/sbin/supla-server /usr/sbin/supla-scheduler_"$now"

tar -zxf supla-server-v${SERVER_VERSION}-arm32v7.tgz
mv ./supla-server-v${SERVER_VERSION}-arm32v7/supla-server /usr/sbin/
mv ./supla-server-v${SERVER_VERSION}-arm32v7/supla-scheduler /usr/sbin/

[ -d /var/www/html_old_"$now" ] || mv /var/www/html /var/www/html_old_"$now"

tar -zxf supla-cloud-v${CLOUD_VERSION}.tar.gz -C /var/www/html

cp /var/www/html_old_"$now"/app/config/parameters.yml /var/www/html/app/config/

grep "recaptcha_enabled > /dev/null 2>&1 || echo "    recaptcha_enabled: false" >> /var/www/html/app/config/parameters.yml

cd /var/www/html

php bin/console --no-interaction doctrine:migrations:migrate

rm -fr ./supla-cloud-${CLOUD_VERSION}.tar.gz
rm -fr  ./supla-server-v${SERVER_VERSION}-arm32v7.tgz
systemctl daemon-reload
/etc/init.d/apache2 restart
/etc/init.d/supla-server start
/etc/init.d/supla-scheduler start

echo "FINISH!"
