#!/bin/bash

sleep 10

cd /var/www/html

if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
    
    echo "Configuring database connection..."
    wp config create \
        --dbname=$SQL_DATABASE \
        --dbuser=$SQL_USER \
        --dbpass=$SQL_PASSWORD \
        --dbhost=mariadb \
        --allow-root
        
    echo "Installing WordPress..."
    wp core install \
        --url=$WP_URL \
        --title="$WP_TITLE" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --skip-email \
        --allow-root
        
    echo "Creating secondary user..."
    wp user create \
        $WP_USER \
        $WP_USER_EMAIL \
        --role=author \
        --user_pass=$WP_USER_PASSWORD \
        --allow-root
        
    chown -R www-data:www-data /var/www/html
fi

echo "Configuring Redis..."
wp config set WP_REDIS_HOST redis --allow-root
wp config set WP_REDIS_PORT 6379 --raw --allow-root

wp plugin install redis-cache --activate --allow-root
wp redis enable --allow-root

echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm8.2 -F
