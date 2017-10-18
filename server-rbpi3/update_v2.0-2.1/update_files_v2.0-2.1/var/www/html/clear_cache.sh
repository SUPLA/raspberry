#!/bin/sh
cd /var/www/html
php bin/console cache:clear --no-warmup --env=prod 
php bin/console cache:clear --no-warmup --env=dev
rm -rf ./var/cache/dev
rm -rf ./var/cache/prod
chown -R www-data *
chgrp -R www-data *
