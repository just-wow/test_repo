FROM debian:jessie

ARG SF_MIRROR="deac-riga"
ENV NETATALK_VERSION=3.1.12
ENV BUILD_DEPS="build-essential libevent-dev libssl-dev libgcrypt11-dev libkrb5-dev libpam0g-dev libwrap0-dev libdb-dev libtdb-dev libmysqlclient-dev libavahi-client-dev libacl1-dev libldap2-dev libcrack2-dev systemtap-sdt-dev libdbus-1-dev libdbus-glib-1-dev libglib2.0-dev libtracker-sparql-1.0-dev libtracker-miner-1.0-dev file"


WORKDIR netatalk-$NETATALK_VERSION


RUN export DEBIAN_FRONTEND=noninteractive &&\
  apt-get update && apt-get install --no-install-recommends --fix-missing -y curl &&\
    curl -SL "http://$SF_MIRROR.dl.sourceforge.net/project/netatalk/netatalk/$NETATALK_VERSION/netatalk-$NETATALK_VERSION.tar.gz" | tar xvz -C / &&\
  apt-get install --no-install-recommends --fix-missing -y $BUILD_DEPS tracker avahi-daemon && \
  ./configure --prefix=/usr --sysconfdir=/etc --with-init-style=debian-systemd \
  --without-libevent --without-tdb --with-cracklib --enable-krbV-uam \
  --with-pam-confdir=/etc/pam.d --with-dbus-sysconf-dir=/etc/dbus-1/system.d \
  --with-tracker-pkgconfig-version=1.0 &&\
  make &&  make install &&\
  apt-get -q -y purge --auto-remove $BUILD_DEPS curl \
  tracker-gui libgl1-mesa-dri &&\
  apt-get install -y \
  libevent-2.0 libavahi-client3 libevent-core-2.0 libwrap0 libtdb1 \
  libmysqlclient18 libcrack2 libdbus-glib-1-2 &&\
  apt-get -q -y autoclean &&\
  apt-get -q -y autoremove &&\
  apt-get -q -y clean &&\
  rm -rf /netatalk* &&\
  rm -rf /usr/share/man &&\
  rm -rf /usr/share/doc &&\
  rm -rf /usr/share/icons &&\
  rm -rf /usr/share/poppler &&\
  rm -rf /usr/share/mime &&\
  rm -rf /usr/share/GeoIP &&\
  rm -rf /var/lib/apt/lists* &&\
  rm -rf /netatalk-$NETATALK_VERSION/* &&\
  mkdir /shares

COPY afp.conf /etc
COPY afpd.sh /usr/bin

RUN chmod +x /usr/bin/afpd.sh

EXPOSE 139 445 137/udp 548

VOLUME /shares

ENTRYPOINT ["/usr/bin/afpd.sh"]
