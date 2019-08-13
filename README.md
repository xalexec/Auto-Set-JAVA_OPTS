## auto set JAVA_OPTS in docker and kubernetes

### user

```
docker build . -f jar.ubuntu.Dockerfile -t jvm:ubuntu
docker run -id -p 8080:8080 jvm:ubuntu

docker build . -f jar.alpine.Dockerfile -t jvm:alpine
docker run -id -p 8080:8080 jvm:ubuntu

docker build . -f war.Dockerfile -t jvm:tomcat
docker run -id -p 8080:8080 jvm:tomcat
```
访问

http://localhost:8080/jvm

### document

应用名

APP_NAME=${APP_NAME:-"app.jar"}

是否开启 Dump

OOM_DUMP=${OOM_DUMP:-"true"}

是否开记打印

DEBUG_PRINT=${DEBUG_PRINT:-"false"}

是 Srping Boot jar 应用还是 tomcat war 应用

SPRING_BOOT=${SPRING_BOOT:-"true"}

不限制内存时默认内存

DEFAULT_MEMORY=${DEFAULT_MEMORY:-"2048"}

不限制 CPU 时默认 CPU

DEFAULT_CPU=${DEFAULT_CPU:-"1"}

默认输出目录

UNIFIED_OUTPUT_PATH=${UNIFIED_OUTPUT_PATH:-"/data"}

