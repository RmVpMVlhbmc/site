FROM alpine:latest

RUN set -ex \
    && apk add --no-cache shadow \
    && apk add --no-cache apache2 apache2-ctl php8 php8-apache2 php8-dom php8-exif php8-fileinfo php8-mbstring php8-openssl php8-pdo php8-pdo_sqlite php8-pecl-imagick php8-xml php8-zip

RUN set -ex \
    && sed -i 's/#LoadModule rewrite_module modules\/mod_rewrite.so/LoadModule rewrite_module modules\/mod_rewrite.so/' /etc/apache2/httpd.conf \
    && sed -Ei 's/AllowOverride [nN]one/AllowOverride All/' /etc/apache2/httpd.conf \
    && printf 'MaxSpareServers 2\nMinSpareServers 1\n' >> /etc/apache2/httpd.conf

RUN set -ex \
    && chown -R apache:apache /var/www/localhost/htdocs \
    && groupmod -g 1000 apache \
    && usermod -u 1000 apache

RUN set -ex \
    && rm -f /var/www/localhost/htdocs/index.html

COPY --chown=apache wordpress /var/www/localhost/htdocs

ENTRYPOINT ["/usr/sbin/apachectl", "-D", "FOREGROUND"]
