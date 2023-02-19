ARG codename=focal

FROM ubuntu:$codename
ENV LANG C.UTF-8
ARG odoo_version

# Basic dependencies
RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq --no-install-recommends \
        ca-certificates \
        curl \
        gettext \
        git \
        gnupg \
        lsb-release \
        software-properties-common \
        expect-dev \
		sudo \
		ssh


RUN add-apt-repository -y ppa:deadsnakes/ppa

# Install build dependencies for python libs commonly used by Odoo and OCA
RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq --no-install-recommends \
       build-essential \
       python3 \
       python3-venv \
	   python3-dev \
	   python3-pip \
       libpq-dev \
       libxml2-dev \
       libxslt1-dev \
       libz-dev \
       libxmlsec1-dev \
       libldap2-dev \
       libsasl2-dev \
       libjpeg-dev \
       libcups2-dev \
       default-libmysqlclient-dev \
       swig \
       libffi-dev \
       pkg-config \
	   wget \
	   curl \
    && apt-cache --generate pkgnames \
       | grep --line-regexp --fixed-strings \
          -e python$python_version-distutils \
       | xargs apt install -y


RUN wget -O odoo.deb $(echo $(curl -s "https://www.odoo.com/es_ES/thanks/download?code=M1902069696927&platform_version=deb_${odoo_version}e") | grep -oP "https://download.odoocdn.com/download[^']+" | head -1) --no-verbose --show-progress --progress=bar:force:noscroll \
    && apt-get update \
    && apt-get -y install --no-install-recommends ./odoo.deb \
    && rm -rf /var/lib/apt/lists/* odoo.deb
USER root
RUN python3 -m venv /odoo-sh/jupyterlab
RUN . /odoo-sh/jupyterlab/bin/activate
RUN pip install jupyterlab
run pip install markupsafe==2.0.1

EXPOSE 4040
ENV PGHOST=postgres
ENV PGUSER=odoo
ENV PGPASSWORD=odoo
ENV PGDATABASE=odoo
ENV ADDONS_DIR=.
ENV JUPYTER_DATA_DIR=/odoo-sh/jupyterlab/share/jupyter
RUN passwd odoo -d
RUN usermod -aG sudo odoo
RUN chsh -s /bin/bash odoo

ENV PATH="$PATH:/odoo-sh/jupyterlab/bin"
COPY src /odoo-sh/jupyterlab

CMD ["jupyter-lab", "--allow-root", "--port=4040", "--ip=0.0.0.0", "--ServerApp.base_url=/odoo-sh/jupyterlab"]