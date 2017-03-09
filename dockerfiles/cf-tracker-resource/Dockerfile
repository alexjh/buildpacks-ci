FROM bash

# http://www.magicermine.com/demos/curl/curl/curl-7.30.0.ermine.tar.bz2
RUN cd /tmp && wget http://www.magicermine.com/demos/curl/curl/curl-7.30.0.ermine.tar.bz2 && tar xvf curl-7.30.0.ermine.tar.bz2 curl-7.30.0.ermine/curl.ermine && mv curl-7.30.0.ermine/curl.ermine /bin/curl && rm curl-7.30.0.ermine.tar.bz2

# https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
ADD jq-linux64 /bin/jq
RUN chmod 755 /bin/jq

# Copy in resources
ENV TMPDIR /tmp
RUN mkdir -p /opt/resource/
COPY check in out /opt/resource/

