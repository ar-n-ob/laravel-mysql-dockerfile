# PHP_INI_DIR - /usr/local/etc/php

ARG PHP_VERSION="8.1"

FROM php:${PHP_VERSION}-fpm-alpine

ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS="0" \
    PHP_OPCACHE_MAX_ACCELERATED_FILES="10000" \
    PHP_OPCACHE_MEMORY_CONSUMPTION="192" \
    PHP_OPCACHE_MAX_WASTED_PERCENTAGE="10"

RUN apk update 
RUN apk add --no-cache supervisor
RUN apk add git curl nginx icu-dev
    
RUN docker-php-ext-configure intl
RUN docker-php-ext-install mysqli pdo pdo_mysql bcmath exif opcache intl sockets
RUN docker-php-ext-enable pdo_mysql 

# File Coping
COPY docker/php/php.ini   $PHP_INI_DIR/conf.d/local.ini
COPY docker/php/opcache.ini $PHP_INI_DIR/conf.d/opcache.ini

WORKDIR /var/www/html

COPY . /var/www/html

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN composer install

COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf

ADD docker/app/entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/entrypoint.sh

RUN chown -R www-data:www-data /var/www/html/storage/*

# Permission
RUN chmod 777 /var/www/html/storage/ -R

ENTRYPOINT ["entrypoint.sh"]