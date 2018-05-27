# https://resin.io/blog/building-arm-containers-on-any-x86-machine-even-dockerhub/
# https://docs.docker.com/engine/reference/builder/

FROM alpine:latest
WORKDIR /

# copy test app
ARG APP
ADD --chown=nobody ${APP} .

# CMD does not expand ARG
USER nobody:nobody
ENV  APP=${APP}
CMD  exec ./${APP}
