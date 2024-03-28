#!/usr/bin/env sh

# Check if user www-data exists
if grep "^www\-data\:" /etc/passwd; then
    # Check if www-data owns the group www-data
    if [ $(id -g -n www-data) != "www-data" ]; then
        # Change the group ownership to www-data
        chown -R www-data:www-data /var/www/html
    fi
    # Check if UID is not 1000
    if [ $(id -u www-data) -ne 1000 ]; then
        # Change the UID and GID of the user to 1000
        sed -i 's/^www-data:\([^:]*\):[0-9]*:\([0-9]*\)/www-data:\1:1000:1000/' /etc/passwd
    fi
    # Check if GID is not 1000
    if [ $(id -g www-data) -ne 1000 ]; then
        # Change the GID to 1000
        sed -i 's/^www-data:\([^:]*\):[0-9]*/www-data:\1:1000/' /etc/group
    fi
else
    # Check if group www-data exists
    if grep "^www\-data:" /etc/group; then
        # Check if GID is not 1000
        if ! getent group www-data | cut -d: -f3 | grep -q '^1000$'; then
            # Change the GID to 1000
            sed -i 's/^www-data:\([^:]*\):[0-9]*/www-data:\1:1000/' /etc/group
            # Create user www-data with UID and GID set to 1000
            adduser -u 1000 -D -S -G www-data -s /sbin/nologin -h /var/www www-data
        fi
    else
        # Create group www-data with GID set to 1000
        addgroup -g 1000 -S www-data
        # Create user www-data with UID and GID set to 1000
        adduser -u 1000 -D -S -G www-data -s /sbin/nologin -h /var/www www-data
    fi
fi

# Create the php-fpm log directory
mkdir -p /var/log/php-fpm
chown -Rf www-data:www-data /var/log/php-fpm
# Create the php-fpm run directory
mkdir -p /var/run/php-fpm
chown -Rf www-data:www-data /var/run/php-fpm
# Create the php-fpm conf directory
mkdir -p /usr/local/etc/php-fpm.d
chown -Rf www-data:www-data /usr/local/etc/php-fpm.d
# Create the php-fpm root directory
mkdir -p /var/www/html
chown -Rf www-data:www-data /var/www/html
