FROM python:3.9.5-slim-buster
WORKDIR /app
ENV PIP_NO_CACHE_DIR 1
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV TZ Asia/Kolkata
RUN sed -i.bak 's/us-west-2\.ec2\.//' /etc/apt/sources.list
RUN apt -qq update
RUN apt -qq install -y --no-install-recommends \
    curl \
    git \
    gnupg2 \
    unzip \
    wget \
    # install gcc [ PEP 517 ]
    build-essential gcc \
    software-properties-common && \
    rm -rf /var/lib/apt/lists/* && \
    apt-add-repository non-free
RUN wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | apt-key add - && \
    wget -qO - https://ftp-master.debian.org/keys/archive-key-10.asc | apt-key add -
RUN sh -c 'echo "deb https://mkvtoolnix.download/debian/ buster main" >> /etc/apt/sources.list.d/bunkus.org.list' && \
    sh -c 'echo deb http://deb.debian.org/debian buster main contrib non-free | tee -a /etc/apt/sources.list'
RUN apt -qq update
RUN apt -qq install -y --no-install-recommends \
    # this package is required to fetch "contents" via "TLS"
    apt-transport-https \
    # install coreutils
    coreutils aria2 jq pv \
    # install encoding tools
    ffmpeg \
    # install extraction tools
    mkvtoolnix \
    p7zip rar unrar zip \
    # miscellaneous helpers
    megatools mediainfo rclone && \
    # clean up previously installed SPC
    apt purge -y software-properties-common && \
    # clean up the container "layer", after we are done
    rm -rf /var/lib/apt/lists /var/cache/apt/archives /tmp

# each instruction creates one layer
# Only the instructions RUN, COPY, ADD create layers.
# copies 'requirements', to inside the container
# ..., there are multiple '' dependancies,
# requiring the use of the entire repo, hence
# adds files from your Docker client’s current directory.
COPY . .

# install requirements, inside the container
RUN pip3 install --upgrade pip && \
    pip3 install --no-cache-dir -r requirements.txt

# specifies what command to run within the container.
CMD ["python3", "-m", "publicleechgroup"]
