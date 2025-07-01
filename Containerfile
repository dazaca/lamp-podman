FROM fedora:latest

# Instala Apache, PHP, mysqli y FPM
RUN dnf -y install httpd php php-mysqlnd php-fpm && \
    dnf clean all

# Crea el socket directory de PHP-FPM
RUN mkdir -p /run/php-fpm

# Configura permisos por si Apache ejecuta como apache:apache
RUN chown -R apache:apache /run/php-fpm /var/lib/php /var/www/html

# Crea punto de montaje para código fuente desde el host (¡sin copiar!)
VOLUME ["/var/www/html"]

# Expón el puerto web
EXPOSE 80

# Comando que arranca php-fpm y luego httpd en primer plano
CMD /bin/bash -c "php-fpm && httpd -DFOREGROUND"

RUN dnf install -y php-pecl-xdebug && \
    echo -e "\n\
zend_extension=xdebug.so\n\
xdebug.mode=debug\n\
xdebug.start_with_request=yes\n\
xdebug.client_host=host.containers.internal\n\
xdebug.client_port=9003\n\
xdebug.log=/tmp/xdebug.log\n" \
> /etc/php.d/15-xdebug.ini

