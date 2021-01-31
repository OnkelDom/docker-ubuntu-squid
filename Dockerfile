FROM docker.io/ubuntu:20.04
MAINTAINER Dominik Lenhardt <dominik.lenhardt@dvag.com>

ENV DANTE_VER 1.4.2
ENV DANTE_URL https://www.inet.no/dante/files/dante-$DANTE_VER.tar.gz
ENV DANTE_SHA 4c97cff23e5c9b00ca1ec8a95ab22972813921d7fbf60fc453e3e06382fc38a7
ENV DANTE_FILE dante.tar.gz
ENV DANTE_TEMP dante
ENV DANTE_DEPS build-essential curl
ENV WORKERS 20

RUN set -xe \
    && addgroup --system --gid 5000 --quiet sockd \
    && adduser --quiet --system --disabled-login --ingroup sockd --uid 5000 --home /home/sockd sockd \
    && apt-get update \
    && apt-get install -y $DANTE_DEPS \
    && mkdir $DANTE_TEMP \
    && cd $DANTE_TEMP \
    && curl -sSL $DANTE_URL -o $DANTE_FILE \
    && echo "$DANTE_SHA *$DANTE_FILE" | shasum -c \
    && tar xzf $DANTE_FILE --strip 1 \
    && ./configure \
    && make install \
    && cd .. \
    && rm -rf $DANTE_TEMP \
    && apt-get purge -y --auto-remove $DANTE_DEPS \
    && rm -rf /var/lib/apt/lists/* 

CMD sockd -f /etc/sockd.conf -p /tmp/sockd.pid -N $WORKERS
