FROM php:5-apache

MAINTAINER Florian JUDITH <florian.judith.b@gmail.com>

ENV GLPI_VERSION=9.1.3
ENV GLPI_URL=https://github.com/glpi-project/glpi/releases/download/$GLPI_VERSION/glpi-$GLPI_VERSION.tgz
ENV TERM=xterm

RUN apt-get update -y
RUN apt-get install -y \
	cron \
	#git \
	bzip2 \
	wget \
	nano

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Download & Install needed php extensions: ldap, imap, zlib, gd, soap
RUN apt-get install -y php5-ldap libldap2-dev && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap

RUN a2enmod rewrite expires

RUN apt-get install -y php5-imap libssl-dev libc-client2007e-dev libkrb5-dev && \
    docker-php-ext-configure imap --with-imap-ssl --with-kerberos && \
    docker-php-ext-install imap

RUN apt-get install -y libpng12-dev libjpeg-dev && \
    docker-php-ext-configure gd --with-jpeg-dir=/usr/lib && \
    docker-php-ext-install gd

RUN apt-get -y install zlib1g-dev && \
    docker-php-ext-install zip && \
    apt-get purge --auto-remove -y zlib1g-dev

RUN docker-php-ext-install mysqli

RUN docker-php-ext-install pdo_mysql

RUN apt-get -y install re2c libmcrypt-dev && \
    docker-php-ext-install mcrypt

RUN apt-get -y install php-soap libxml2-dev && \
	docker-php-ext-install soap

RUN apt-get -y install php5-xmlrpc libxslt-dev && \
	docker-php-ext-install xmlrpc xsl

# Download & Install GLPI
RUN cd /var/www/html && \
	wget ${GLPI_URL} && \
	tar --strip-components=1 -xvf glpi-${GLPI_VERSION}.tgz

# Change owner for security reasons
RUN chown -R www-data:www-data /var/www/html/*
RUN chown www-data:www-data /var/lib/php5

WORKDIR /var/www/html

EXPOSE 80
CMD ["apache2-foreground"]