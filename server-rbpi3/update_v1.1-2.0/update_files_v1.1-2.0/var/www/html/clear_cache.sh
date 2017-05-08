#!/bin/sh
cd /var/www/html
php bin/console cache:clear --env=prod
php bin/console cache:clear --env=dev
chown -R www-data *
chgrp -R www-data *
