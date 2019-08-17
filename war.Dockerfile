FROM tomcat:8.5-jdk8-adoptopenjdk-hotspot

LABEL author="alex <xalexec@gmail.com>"

ENV SPRING_BOOT="false"

VOLUME /data

RUN set -eux; \
  echo 'deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse\
deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse\
deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse\
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse\
deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse\
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse\
deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse\
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse\
deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse\
deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse' > /etc/apt/sources.list; \
  apt-get update; \
  # 设置时区
  date;\
  apt-get install -y --no-install-recommends tzdata; \
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
  date;\
  rm -rf /var/lib/apt/lists/*; \
  rm -rf webapps/*;

# 拷 war 包
COPY app.war webapps/ROOT.war

COPY entrypoint.sh entrypoint.sh

CMD ["sh", "entrypoint.sh"]

EXPOSE 8080
