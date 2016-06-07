FROM alpine:edge
MAINTAINER Adrian Hobbs <adrianhobbs@gmail.com>
ENV 	PACKAGE="syncthing tzdata" \
	USER="syncthing" \
	HOME="/var/lib/$USER" \
	TZ="Australia/Sydney"

# Install package using --no-cache to update index and remove unwanted files
RUN 	apk add --no-cache $PACKAGE && \
	cp /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo "$TZ" > /etc/timezone

USER $USER

CMD ["/usr/bin/syncthing","-home=/var/lib/syncthing"]

