ARG BASEIMG
FROM ${BASEIMG} as builder

RUN set -eux
RUN apk update
RUN apk add --no-cache --virtual \
      bash mc nano \
      musl-dev wget git build-base \
      inotify-tools certbot openssl ca-certificates \
      apache2-utils \
      postgresql-libs postgresql-dev \
      build-base .build-deps gcc musl-dev \ 
      libffi-dev openssl-dev python3-dev libressl-dev

RUN pip install --upgrade pip setuptools wheel 
RUN pip install cython
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h
RUN pip install psycopg
RUN pip install starlite

COPY docker/site/requirements.txt /opt/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /opt/requirements.txt

FROM builder

RUN apk info -vv | sort

COPY . /opt

COPY docker/site/requirements.txt /opt/requirements1.txt
RUN pip install --no-cache-dir --upgrade -r /opt/requirements1.txt


