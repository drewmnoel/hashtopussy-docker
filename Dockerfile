FROM greyltc/lamp

ENV TARBALL https://github.com/s3inlc/hashtopussy/archive/master.tar.gz

RUN cd /srv/http \
    && curl -LO $TARBALL \
    && tar -xf master.tar.gz hashtopussy-master/src/ \
    && mv hashtopussy-master/src/* . \
    && rm -r info.php master.tar.gz hashtopussy-master \
    && chown http:http . -R

# Patch Apache to allow htaccess
ADD 01-htaccess.patch /01-htaccess.patch
RUN pacman -Sy --noconfirm patch \
    && cd / \
    && patch -p0 < 01-htaccess.patch \
    && pacman -Rcs --noconfirm patch \
    && rm /01-htaccess.patch \
    && cleanup-image

# Add support for libsodium
ADD 02-makefile.patch /02-makefile.patch
RUN pacman -Sy --noconfirm --needed base-devel libsodium \
    && cd /tmp \
    && curl -LO https://pecl.php.net/get/libsodium-1.0.6.tgz \
    && echo "987df388210b498f3acf8ada368e56bece5b2b5ffe64564ecfffc27f17f1242f libsodium-1.0.6.tgz" | sha256sum -c - \
    && tar -xvf libsodium-1.0.6.tgz \
    && cd libsodium-1.0.6 \
    && phpize \
    && ./configure \
    && patch -p0 < /02-makefile.patch \
    && make test install \
    && echo "extension=libsodium.so" > /etc/php/conf.d/libsodium.ini \
    && rm /02-makefile.patch \
    && pacman -Rcs --noconfirm autoconf automake bison fakeroot file flex gc \
       groff guile libatomic_ops libmpc libtool m4 make patch pkg-config \
       sudo texinfo \
    && cleanup-image

# Preconfigure DB
ADD db.php /srv/http/inc/db.php

# Add custom startup
ADD startServers.sh /usr/sbin/start-servers
RUN chmod +x /usr/sbin/start-servers && chown http:http /srv/http/ -R
