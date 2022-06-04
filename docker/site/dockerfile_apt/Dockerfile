ARG BASEIMG
FROM ${BASEIMG} as builder

LABEL maintainer="Tim Pozza"

RUN apt-get update -y
RUN apt-get install -y \
                  mc \
                  rclone
RUN pip install --upgrade \
                  setuptools \
                  wheel
RUN pip install   cython \
                  psycopg \
                  starlite

WORKDIR /opt

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Later Additions_1:
FROM builder

COPY . 

COPY requirements_1.txt requirements_1.txt
RUN pip install --no-cache-dir -r requirements_1.txt


#build-essentials python3-dev
