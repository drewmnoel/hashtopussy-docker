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

# Preconfigure DB
ADD db.php /srv/http/inc/db.php

# Add custom startup
ADD startServers.sh /usr/sbin/start-servers
RUN chmod +x /usr/sbin/start-servers && chown http:http /srv/http/ -R
