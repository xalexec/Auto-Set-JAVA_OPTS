FROM amazoncorretto:8

LABEL author="alex <xalexec@gmail.com>"

RUN set -eux; \
  GITHUB_BASE_URL=https://raw.githubusercontent.com/xalexec/Auto-Set-JAVA_OPTS/master/;\
  curl -LfsSo entrypoint.sh ${GITHUB_BASE_URL}entrypoint.sh; \
  curl -LfsSo checksum ${GITHUB_BASE_URL}checksum; \
  echo "`cat checksum` entrypoint.sh" | sha256sum --strict --check -;\
  rm -rf checksum;

VOLUME /data

RUN set -eux; \
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;

# 拷 jar 包
COPY app.jar app.jar

COPY entrypoint.sh entrypoint.sh

CMD ["sh", "entrypoint.sh"]

EXPOSE 8080
