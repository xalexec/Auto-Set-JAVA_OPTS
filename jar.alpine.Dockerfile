FROM adoptopenjdk/openjdk8:alpine

LABEL author="alex <xalexec@gmail.com>"

VOLUME /data

RUN set -eux; \
  sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories; \ 
  # 设置时区
  date;\
  apk add tzdata; \
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;\
  date;

# 拷 war 包
COPY app.jar app.jar

COPY entrypoint.sh entrypoint.sh

CMD ["sh", "entrypoint.sh"]

EXPOSE 8080
