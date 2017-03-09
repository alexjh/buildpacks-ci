FROM bash

# https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
ADD jq-linux64 /bin/jq
RUN chmod 755 /bin/jq

# Copy in resources
ENV TMPDIR /tmp
RUN mkdir -p /opt/resource/
COPY check in out /opt/resource/

