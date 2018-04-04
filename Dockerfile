FROM php:7.2-fpm

# Dependencies
RUN apt-get update

RUN apt-get install -y \
    libmcrypt-dev \
    libpq-dev \
    libicu-dev \
    zlib1g-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libjpeg-dev \
    libpng-dev \
    libmcrypt-dev \
    git \
    wget \
    gnupg \
    cron \
    rsyslog \
    python \
    imagemagick

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-png-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install intl bcmath gd mysqli mbstring zip exif opcache pdo_mysql json

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --filename=composer --install-dir=/usr/local/bin

# Xdebug
RUN pecl install -o -f xdebug

# PHP-CS-Fixer
RUN wget http://cs.sensiolabs.org/download/php-cs-fixer-v2.phar -O php-cs-fixer \
    && chmod a+x php-cs-fixer \
    && mv php-cs-fixer /usr/local/bin/php-cs-fixer

# Redis
RUN pecl install -o -f redis \
    && echo "extension=redis.so" > /usr/local/etc/php/conf.d/redis.ini

# Frontend dependencies
RUN curl -sL https://deb.nodesource.com/setup_9.x | bash - \
    && apt-get update \
    && apt-get install nodejs

# Cleanup
RUN apt-get clean \
    && rm -rf /tmp/pear \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf /tmp/* /var/tmp/*

# Configuration
COPY conf/php.ini /usr/local/etc/php/php.ini
COPY conf/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
COPY conf/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0777 /usr/local/bin/entrypoint.sh

# Cron
ADD conf/crontab /etc/cron.d/app

EXPOSE 9000
WORKDIR /var/www/html

VOLUME ["/var/www/html"]
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]
