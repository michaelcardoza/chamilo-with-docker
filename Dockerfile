FROM php:7.4-apache

RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libfreetype6-dev \
		libjpeg-dev \
		libmagickwand-dev \
		libpng-dev \
		libzip-dev \
		libicu-dev \
        libmcrypt-dev \
        zlib1g-dev \
        g++ \
        unixodbc-dev \
        libxml2-dev \
        libaio-dev \
        libmemcached-dev \
        freetds-dev \
        libssl-dev \
        openssl \
        libldap2-dev
	; \
	\
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j "$(nproc)" \
        bcmath \
        exif \
        gd \
        pdo \
        pdo_mysql \
        zip \
        intl \
        opcache \
        ldap

RUN	pecl install \
    imagick-3.4.4 \
    apcu

RUN docker-php-ext-enable \
    imagick \
    apcu

# Configure and start Apache
ADD ./config/chamilo.conf /etc/apache2/sites-available/chamilo.conf
RUN a2enmod headers
RUN a2ensite chamilo
RUN a2enmod rewrite
RUN /etc/init.d/apache2 restart

CMD ["apache2-foreground"]