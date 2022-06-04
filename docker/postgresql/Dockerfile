ARG BASEIMG
ARG MAINTAINER

FROM ${BASEIMG} as builder

LABEL maintainer="${MAINTAINER}"

RUN apk update
RUN apk add bash nano mc

FROM builder

RUN apk update
