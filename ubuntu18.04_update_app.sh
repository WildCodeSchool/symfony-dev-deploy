#!/bin/bash

# Get app name from parameter or ask user for it (copy and paste all code between "if" and "fi" in your terminal)
if [[ -z ${1} ]] && [[ -z "${appname}" ]]; then
    read -p "Enter the name of your app without hyphens (eg. myawesomeapp):" appname
else
    appname=${1:-${appname}}
fi

# Go inside the app directory
cd /var/www/${appname}
if [ ! $? = 0 ]; then
    exit 1
fi

# Pull the latest changes
git pull
if [ ! $? = 0 ]; then
    exit 1
fi

# Install PHP dependencies
composer install
if [ ! $? = 0 ]; then
    exit 1
fi

# Install JS dependencies
yarn install
if [ ! $? = 0 ]; then
    exit 1
fi

# Build assets
yarn build
if [ ! $? = 0 ]; then
    exit 1
fi

# Set ownership to Apache
chown -R www-data:www-data /var/www/${appname}
if [ ! $? = 0 ]; then
    exit 1
fi

# Set files permissions to 644
find /var/www/${appname} -type f -exec chmod 644 {} \;
if [ ! $? = 0 ]; then
    exit 1
fi

# Set folders permissions to 755
find /var/www/${appname} -type d -exec chmod 755 {} \;
if [ ! $? = 0 ]; then
    exit 1
fi

# Execute database migrations
php bin/console doctrine:migrations:migrate -n

# Clear the cache
php bin/console cache:clear
if [ ! $? = 0 ]; then
    exit 1
fi
