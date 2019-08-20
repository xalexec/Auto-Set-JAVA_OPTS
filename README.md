## auto set JAVA_OPTS in docker and kubernetes

### use

```
docker build . -f jar.ubuntu.Dockerfile -t jvm:ubuntu
docker run -it -p 8080:8080 jvm:ubuntu
docker run --cpus=2 --memory=4096m -it -p 8080:8080 -p 5005:5005 jvm:ubuntu

docker build . -f jar.alpine.Dockerfile -t jvm:alpine
docker run -it -p 8080:8080 jvm:alpine

docker build . -f war.Dockerfile -t jvm:tomcat
docker run -it -p 8080:8080 jvm:tomcat
```
访问

http://localhost:8080/jvm

### document

in Dockerfile add

```
ENV SPRING_BOOT="true" \
	    DEBUG_PRINT="ture" \
	    APP_NAME="app.jar" 
```

应用名

APP_NAME=${APP_NAME:-"app.jar"}

是否开启 Dump

OOM_DUMP=${OOM_DUMP:-"true"}

是否开记打印

DEBUG_PRINT=${DEBUG_PRINT:-"false"}

是 Srping Boot jar 应用还是 tomcat war 应用

SPRING_BOOT=${SPRING_BOOT:-"true"}

不限制内存时默认内存

DEFAULT_MEMORY=${DEFAULT_MEMORY:-2048}

不限制 CPU 时默认 CPU

DEFAULT_CPU=${DEFAULT_CPU:-1}

默认输出目录

UNIFIED_OUTPUT_PATH=${UNIFIED_OUTPUT_PATH:-"/data"}

远程调试

REMOTE_DEBUG=${REMOTE_DEBUG:-"true"}

远程调试端口

REMOTE_DEBUG_PORT=${REMOTE_DEBUG_PORT:-5005}

默认时区

DEFAULT_TIMEZONE=${DEFAULT_CPU:-"GMT+08"}