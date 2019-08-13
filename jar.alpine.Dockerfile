FROM adoptopenjdk/openjdk8:alpine

LABEL author="alex <xalexec@gmail.com>"

ENV SPRING_BOOT="true" \
    DEBUG_PRINT="ture" \
    APP_NAME="app.jar" 

VOLUME /data

# 清理
# 修改时区
RUN set -eux; \
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 拷 war 包
COPY app.jar app.jar

COPY entrypoint.sh entrypoint.sh

CMD ["sh", "entrypoint.sh"]

EXPOSE 8080
