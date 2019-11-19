FROM centos:7

RUN \
  yum update -yqq && \
  yum install -yqq \
  net-tools telnet curl wget ncat iputils \
  vim tree which htop \
  make gcc

COPY files/docker /docker

ENV KEEP_RUNNING=0
ENV LOG_STDOUT=1
ENV LOGO_FILE=/docker/logo.txt

ENTRYPOINT [ "/docker/entrypoint.sh" ]
