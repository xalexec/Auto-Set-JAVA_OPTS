FROM tomcat:8.5-jdk8-adoptopenjdk-hotspot

LABEL author="alex <xalexec@gmail.com>"

ENV SPRING_BOOT="false"

VOLUME /data

# 清理
# 修改时区
RUN set -eux; \
  rm -rf webapps/*; \
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 拷 war 包
COPY app.war webapps/ROOT.war

COPY entrypoint.sh entrypoint.sh

CMD ["sh", "entrypoint.sh"]

EXPOSE 8080
