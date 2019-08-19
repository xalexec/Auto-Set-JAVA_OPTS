FROM adoptopenjdk:8-jdk-hotspot

LABEL author="alex <xalexec@gmail.com>"

RUN set -eux; \
  GITHUB_BASE_URL=https://raw.githubusercontent.com/xalexec/Auto-Set-JAVA_OPTS/master/;\
  curl -LfsSo entrypoint.sh ${GITHUB_BASE_URL}entrypoint.sh; \
  curl -LfsSo checksum ${GITHUB_BASE_URL}checksum; \
  echo "`cat checksum` entrypoint.sh" | sha256sum --strict --check -;\
  rm -rf checksum;

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
COPY app.jar app.jar

CMD ["sh", "entrypoint.sh"]

EXPOSE 8080
