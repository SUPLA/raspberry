#!/bin/sh

wget https://github.com/SUPLA/raspberry/raw/master/ext01/usr/sbin/supla-dev --no-check-certificate
chmod +x supla-dev
/etc/init.d/supla-dev stop
cp /usr/sbin/supla-dev /usr/sbin/supla-dev_old
cp ./supla-dev /usr/sbin/supla-dev
/etc/init.d/supla-dev start
rm supla-dev
