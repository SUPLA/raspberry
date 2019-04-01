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
##


if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root. For example sudo ./$(basename "$0") 2.3.5" 1>&2
   exit 1

fi

if [ -z "$*" ]; then
   echo "Please add version to update. For example sudo ./$(basename "$0") 2.3.5" 1>&2
   exit 1
fi

#Ustawienie zmiennych
now=$(date +"%m%d%Y%H%M%S")
KATALOG=`pwd`

# Backup bazy danych wraz z procedurami
mysqldump --routines -u root --password='raspberry' supla > /var/backups/supla"$now".sql
gzip /var/backups/supla"$now".sql

# Backup Supla-Cloud
[ -d /var/www/html_old_"$now" ] || mv /var/www/html /var/www/html_old_"$now"

# Pobieranie Supla-Cloud
wget https://github.com/SUPLA/supla-cloud/releases/download/v$1/supla-cloud-v$1.tar.gz

# Pobieranie Supla-Core
git clone https://github.com/SUPLA/supla-core

# Kompilowanie Supla-Server i Supla-Scheduler
cd supla-core/supla-server/Release && make all
cd ../../supla-scheduler/Release && make all
cd ../../../

# Zatrzymywanie serwisów Supli
[ -e /etc/init.d/supla-server ] && /etc/init.d/supla-server stop
[ -e /etc/init.d/supla-scheduler ] && /etc/init.d/supla-scheduler stop

# Backup Supla-Server i Supla-Scheduler
[ -e /usr/sbin/supla-server_"$now" ] || cp /usr/local/bin/supla-server /usr/local/bin/supla-server_"$now"
[ -e /usr/sbin/supla-scheduler_"$now" ] || cp /usr/local/bin/supla-scheduler /usr/local/bin/supla-scheduler_"$now"

# Przenoszenie nowych wersji Supla-Server i Supla-Scheduler
mv supla-core/supla-server/Release/supla-server /usr/local/bin/
mv supla-core/supla-scheduler/Release/supla-scheduler /usr/local/bin/

# Instalacja nowej wersji Supla-Cloud
mkdir /var/www/html
tar -zxf supla-cloud-v$1.tar.gz -C /var/www/html
cp /var/www/html_old_"$now"/app/config/parameters.yml /var/www/html/app/config/

# Opcja - dopisać w razie potrzeby brakujące wpisy w pliku paramaters.yml wg poniższego przykładu
#grep "recaptcha_enabled" /var/www/html/app/config/parameters.yml > /dev/null 2>&1 || echo "    recaptcha_enabled: false" >> /var/www/html/app/config/parameters.yml

cd /var/www/html

php bin/console --no-interaction doctrine:migrations:migrate
chown -R www-data:www-data /var/www/html

# Czyszczenie niepotrzebnych plików poinstalacyjnych
cd $KATALOG
rm -fr supla-core
rm -fr supla-cloud-v$1.tar.gz

# Opcjonalnie - kopiowanie skrytpów dla zdarzeń
#cp /var/www/html_old_"$now"/src/SuplaBundle/Command/SimulateEventsCommand.php /var/www/html/src/SuplaBundle/Command
#cp /var/www/html_old_"$now"/src/SuplaBundle/Command/events.yml /var/www/html/src/SuplaBundle/Command


# Restart i uruchomienie Supli
systemctl daemon-reload
/etc/init.d/apache2 restart
/etc/init.d/supla-server start
/etc/init.d/supla-scheduler start

echo "FINISH!"
