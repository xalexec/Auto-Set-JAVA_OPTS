FROM eclipse-temurin:8-alpine

LABEL author="alex <xalexec@gmail.com>"

RUN set -eux; \
  GITHUB_BASE_URL=https://raw.githubusercontent.com/xalexec/Auto-Set-JAVA_OPTS/master/;\
  curl -LfsSo entrypoint.sh ${GITHUB_BASE_URL}entrypoint.sh; \
  curl -LfsSo checksum ${GITHUB_BASE_URL}checksum; \
  echo "`cat checksum` entrypoint.sh" | sha256sum --strict --check -;\
  rm -rf checksum;

VOLUME /data

RUN set -eux; \
  sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \ 
  # 设置时区
  apk add tzdata; \
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;

# 拷 war 包
COPY app.jar app.jar

COPY entrypoint.sh entrypoint.sh

CMD ["sh", "entrypoint.sh"]

EXPOSE 8080
