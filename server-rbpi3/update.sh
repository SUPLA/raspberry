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
   echo "This script must be run as root. For example sudo ./$(basename "$0")" 1>&2
   exit 1

fi

echo "Supla update script. Please wait and do not turn off the update process!"

#Setting variables
get_latest_release_supla_core() {
  curl --silent "https://api.github.com/repos/supla/supla-core/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/^.*\"v//' |
    sed -E 's/\".*$//'
}

get_latest_release_supla_cloud() {
  curl --silent "https://api.github.com/repos/supla/supla-cloud/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/^.*\"v//' |
    sed -E 's/\".*$//'
}

SUPLACORE=`get_latest_release_supla_core`
SUPLACLOUD=`get_latest_release_supla_cloud`
NOW=$(date +"%m%d%Y%H%M%S")
TEMPDIR=`mktemp -d`
cd $tempdir


# Database backup with procedures
mysqldump --routines -u root --password='raspberry' supla > /var/backups/supla"$NOW".sql
gzip /var/backups/supla"$NOW".sql

# Backup Supla-Cloud
[ -d /var/www/html_old_"$NOW" ] || mv /var/www/html /var/www/html_old_"$NOW"

# Downloading Supla-Cloud
wget https://github.com/SUPLA/supla-cloud/releases/download/v$SUPLACLOUD/supla-cloud-v$SUPLACLOUD.tar.gz

# Downloading and unpacking Supla-Core
wget https://github.com/SUPLA/supla-core/archive/v$SUPLACORE.zip
unzip v$SUPLACORE.zip
rm -fr v$SUPLACORE.zip

# Compiling Supla-Server and Supla-Scheduler
cd supla-core-$SUPLACORE/supla-server/Release && make all
cd ../../supla-scheduler/Release && make all
cd ../../../

# Stopping the services Supla-Server and Supla-Scheduller
[ -e /etc/init.d/supla-server ] && /etc/init.d/supla-server stop
[ -e /etc/init.d/supla-scheduler ] && /etc/init.d/supla-scheduler stop

# Backup Supla-Server and Supla-Scheduler
[ -e /usr/sbin/supla-server_"$NOW" ] || cp /usr/local/bin/supla-server /usr/local/bin/supla-server_"$NOW"
[ -e /usr/sbin/supla-scheduler_"$NOW" ] || cp /usr/local/bin/supla-scheduler /usr/local/bin/supla-scheduler_"$NOW"

# Transferring new versions of the Supla-Server and Supla-Scheduler
mv supla-core-$SUPLACORE/supla-server/Release/supla-server /usr/local/bin/
mv supla-core-$SUPLACORE/supla-scheduler/Release/supla-scheduler /usr/local/bin/
cp /usr/local/bin/supla-server /usr/sbin/
cp /usr/local/bin/supla-scheduler /usr/sbin/

# Installation of the new version of Supla-Cloud
mkdir /var/www/html
tar -zxf supla-cloud-v$SUPLACLOUD.tar.gz -C /var/www/html
cp /var/www/html_old_"$NOW"/app/config/parameters.yml /var/www/html/app/config/

# Option - enter, if necessary, missing entries in the parameters.yml file according to the example below
#grep "recaptcha_enabled" /var/www/html/app/config/parameters.yml > /dev/null 2>&1 || echo "    recaptcha_enabled: false" >> /var/www/html/app/config/parameters.yml

cd /var/www/html

php bin/console --no-interaction doctrine:migrations:migrate
chown -R www-data:www-data /var/www/html

# Optional - copying scripts for events
if [ -e /var/www/html_old_"$NOW"/src/SuplaBundle/Command/SimulateEventsCommand.php ]; then
  echo Copying Simulate Events Command...
  cp /var/www/html_old_"$NOW"/src/SuplaBundle/Command/SimulateEventsCommand.php /var/www/html/src/SuplaBundle/Command
  cp /var/www/html_old_"$NOW"/src/SuplaBundle/Command/events.yml /var/www/html/src/SuplaBundle/Command
fi

# Cleaning unnecessary post-installation files
rm -fr var/cache/*
php bin/console cache:warmup
chown -R www-data:www-data var/cache
rm -fr $TEMPDIR

# Restart and launch of the Supla
systemctl daemon-reload
/etc/init.d/apache2 restart
/etc/init.d/supla-server start
/etc/init.d/supla-scheduler start

echo "FINISH!"
