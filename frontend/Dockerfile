# https://hub.docker.com/r/nginxinc/nginx-unprivileged/tags?page=1&ordering=last_updated
FROM nginxinc/nginx-unprivileged:1.21

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV APT="apt-get --no-install-recommends --yes"
RUN $APT update && $APT upgrade && $APT install bash curl wget


COPY build /usr/share/nginx/html/rescue
COPY wait-for-it.sh /

RUN chown -R nginx:nginx /usr/share/nginx
