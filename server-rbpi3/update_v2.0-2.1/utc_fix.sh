#!/bin/bash

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
   echo "This script must be run as root. For example sudo ./utc_fix.sh backup_file.sql" 1>&2
   exit 1
fi

if [ -z "$1" ]; then
   echo Usage: ./utc_fix.sh /var/backups/suplaDATE.sql
   exit 1
fi

if [ ! -e "$1" ]; then
   echo $1 not found!
   exit 1
fi

file=$1

if [ ${file: -3} == ".gz" ]; then
   gunzip $1
   file=`echo -n $file | sed 's/\.gz//'` 
fi

if [ ! -e /var/www/html/app/DoctrineMigrations/Version20170818114139.php ]; then
  echo CLOUD v2.1 not detected
fi

mysql -u root -praspberry << EOF
DROP DATABASE IF EXISTS supla_utc_fix;
CREATE DATABASE IF NOT EXISTS supla_utc_fix DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
EOF

mysql -u root -praspberry supla_utc_fix < $file

mysql -u root -praspberry supla << EOF
UPDATE supla_temperature_log a JOIN supla_utc_fix.supla_temperature_log b ON a.id = b.id SET a.date = b.date WHERE b.id IS NOT NULL;
UPDATE supla_temphumidity_log a JOIN supla_utc_fix.supla_temphumidity_log b ON a.id = b.id SET a.date = b.date WHERE b.id IS NOT NULL;
DROP DATABASE IF EXISTS supla_utc_fix;
EOF

gzip $file
cp ./update_files_v2.0-2.1/var/www/html/app/DoctrineMigrations/Version20170818114139.php /var/www/html/app/DoctrineMigrations/Version20170818114139.php
cp ./update_files_v2.0-2.1/var/www/html/src/SuplaApiBundle/Controller/ApiChannelController.php /var/www/html/src/SuplaApiBundle/Controller/ApiChannelController.php

echo FINISH!
