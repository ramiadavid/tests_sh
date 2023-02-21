FROM ubuntu:22.04
LABEL maintainer="Enio Carboni"

ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=Europe/Madrid
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Install: dependencies, clean: apt cache, remove dir: cache, man, doc, change mod time of cache dir.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       software-properties-common \
       rsyslog systemd systemd-cron sudo git\
    && apt-get clean \
    && rm -Rf /usr/share/doc && rm -Rf /usr/share/man \
    && rm -rf /var/lib/apt/lists/* \
    && touch -d "2 hours ago" /var/lib/apt/lists
RUN sed -i 's/^\($ModLoad imklog\)/#\1/' /etc/rsyslog.conf

RUN rm -f /lib/systemd/system/systemd*udev* \
  && rm -f /lib/systemd/system/getty.target

EXPOSE 8888 5432 8069
ENV PGHOST=postgres
ENV PGUSER=odoo
ENV PGPASSWORD=odoo
ENV PGDATABASE=odoo
ENV ADDONS_DIR=.

VOLUME ["/sys/fs/cgroup", "/tmp", "/run"]
CMD ["/lib/systemd/systemd"]

