ARG BASEIMG
FROM ${BASEIMG} 

ARG MAINTAINER
LABEL Maintainer="${MAINTAINER}"

RUN apk add inotify-tools certbot openssl ca-certificates 
RUN apk add bash mc nano

ARG SCRIPTPATH
WORKDIR ${SCRIPTPATH}
ENV PATH="/opt:$PATH"

COPY include_params/. /etc/nginx/
COPY ssl-options/ /etc/ssl-options

COPY conf.d/. /etc/nginx/templates/

COPY entrypoint.sh nginx-letsencrypt
RUN chmod +x nginx-letsencrypt


#COPY conf.d/merge.conf /etc/nginx/templates/
#COPY conf.d/andybeak.conf /etc/nginx/templates/
#COPY conf.d/websocket_breakdown.conf /etc/nginx/templates/
#

#ARG FQDN
#ENV export FQDN=${FQDN}
#ARG HOSTNAME
#ENV export HOSTNAME=${HOSTNAME}
#ARG ADMINEMAIL
#ENV export ADMINEMAIL=${ADMINEMAIL}
#ENV export XNGINX_BASE=${BASEIMG}
