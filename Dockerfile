FROM wordpress

RUN set -x \
    && apt-get update \
    && apt-get install -y libldap2-dev iproute2 dhcpcd5 net-tools ldap-utils iputils-ping \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install ldap \
    && apt-get purge -y --auto-remove libldap2-dev

# COPY wp-config.php /var/www/html/

# COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# COPY apache2-foreground /usr/local/bin/
# WORKDIR /var/www/html

# EXPOSE 8090
# CMD ["apache2-foreground"]