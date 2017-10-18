
 # SUPLA-CLOUD
 
 [![Latest release](https://img.shields.io/github/release/SUPLA/supla-cloud.svg)](https://github.com/SUPLA/supla-cloud/releases/latest)
 [![Build Status](https://travis-ci.org/SUPLA/supla-cloud.svg?branch=master)](https://travis-ci.org/SUPLA/supla-cloud)

Your home connected. www.supla.org

<img src="https://www.supla.org/assets/img/app-preview-en.png" height="500">

## Installation

In order to run SUPLA-CLOUD, you need to have PHP 7.x and MySQL database.

Download the [release archive](https://github.com/SUPLA/supla-cloud/releases/latest) and extract it to a desired directory on your server.

Adjust the configuration by editing the `app/config/parameters.yml` file.

## Development

Application is written with [Symfony](https://symfony.com/) and [Doctrine](http://www.doctrine-project.org/) on backend. 
Frontend uses [jQuery](https://jquery.com/) and [Vue.js](https://vuejs.org/).

You need to have [composer](https://getcomposer.org/) and [NodeJS](https://nodejs.org/) installed.

### Downloading dependencies
```
composer install
```

### Populating database with sample data

Once you download dev dependencies, you may run the following command to
drop, create the database and populate it with sample data.

```
php bin/console supla:dev:dropAndLoadFixtures -e dev
```
The user created by the fixtures is `user@supla.org` and the password is `pass`.

### Downloading frontend dependencies and building the sources
```
composer run-script webpack
```

The above command also generates a config file `app/config/config_dev.yml` required to run the application.

### Run webpack dev-server when writing frontend code

Enable application support of webpack dev server in your `app/config/parameters.yml`:

```
use_webpack_dev_server: true
```

And then run:

```
cd src/Frontend && npm run dev
```
