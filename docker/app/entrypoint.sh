#!/bin/sh
set -e

php-fpm --daemonize && nginx -g 'daemon off;'