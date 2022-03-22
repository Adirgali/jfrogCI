FROM bash:5.1-alpine3.15

RUN apk add curl jq

ADD script4con.sh /home/script4con.sh

WORKDIR /home

CMD bash script4con.sh ping