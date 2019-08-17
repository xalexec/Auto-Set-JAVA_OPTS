#!/usr/bin/env bash
set -eu
# author:alex
# email:xalexec@gmail.com
# 此文件主要用来设置 JVM 参数

# hotspot="-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap";
# openj9="-XX:+IgnoreUnrecognizedVMOptions -XX:+UseContainerSupport -XX:+IdleTuningCompactOnIdle -XX:+IdleTuningGcOnIdle"

# 应用名
APP_NAME=${APP_NAME:-"app.jar"}
# 是否开启 Dump
OOM_DUMP=${OOM_DUMP:-"true"}
# 是否开记打印
DEBUG_PRINT=${DEBUG_PRINT:-"false"}
# 远程调试
REMOTE_DEBUG=${REMOTE_DEBUG:-"true"}
# 远程调试端口
REMOTE_DEBUG_PORT=${REMOTE_DEBUG_PORT:-5005}
# 是SPRING_BOOT jar 应用还是 war 应用
SPRING_BOOT=${SPRING_BOOT:-"true"}
# 默认内存
DEFAULT_MEMORY=${DEFAULT_MEMORY:-2048}
# 默认 CPU cfs_quota_us = -1
DEFAULT_CPU=${DEFAULT_CPU:-1}
# 默认输出目录
UNIFIED_OUTPUT_PATH=${UNIFIED_OUTPUT_PATH:-"/data"}
if [ ! -d "$UNIFIED_OUTPUT_PATH" ]; then
  mkdir -p "$UNIFIED_OUTPUT_PATH"
fi
JAVA_OPTS="-Duser.timezone=GMT+08 -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -XX:-UseContainerSupport -XX:MaxRAM=`cat /sys/fs/cgroup/memory/memory.limit_in_bytes` -XX:ErrorFile=$UNIFIED_OUTPUT_PATH/hs_err_$HOSTNAME.log"

# 计算 cgroups 设置内存限制 单位 M
calc_limit_memory () {
    limit_memory=$DEFAULT_MEMORY # default
    limit_in_bytes=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
    
    if [ "$limit_in_bytes" != "9223372036854771712" ]; then
        limit_memory=$(expr $limit_in_bytes \/ 1048576)
    fi
    echo $limit_memory
}

# 计算 cgroups 设置内存限制 单位 M
calc_limit_cpu () {
    limit_cpu=$DEFAULT_CPU # default
    period=$(cat /sys/fs/cgroup/cpu/cpu.cfs_period_us)
    quota=$(cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us)
    if [ ! $quota -eq -1 ]; then
        cpu=$(expr $quota \/ $period)
        if [ $cpu -gt 1 ]; then
            limit_cpu=$cpu
        fi
    fi
    echo $limit_cpu
}

# 计算 MetaspaceSize
calc_metaspace_size () {
    # limit_memory <= 1024 = 128
    # 1024 < limit_memory < 4096 = 256 default
    # 4096 <= limit_memory = 512
    metaspace_size=256
    limit_memory=`calc_limit_memory`
    if [ $limit_memory -le 1024 ]; then
        metaspace_size=128
    fi
    if [ $limit_memory -ge 4096 ]; then
        metaspace_size=512
    fi
    echo $metaspace_size
}

# gc 设置
get_gc () {
    # memory < 1C3G
    # -XX:+UseSerialGC
    # memory > 2C8G
    # -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:+ParallelRefProcEnabled
    # 2C8G > memory > 2C2G
    # -XX:+UseConcMarkSweepGC -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 -XX:+ExplicitGCInvokesConcurrentAndUnloadsClasses -XX:+CMSClassUnloadingEnabled -XX:+ParallelRefProcEnabled -XX:+CMSScavengeBeforeRemark
    # 2C1G > memory > 2C2G
    # -XX:+UseParallelGC -XX:+UseAdaptiveSizePolicy -XX:MaxGCPauseMillis=100
    limit_cpu=`calc_limit_cpu`
    limit_memory=`calc_limit_memory`
    gc=""
    if [ $limit_cpu -gt 1 ] && [ $limit_memory -ge 8192 ]; then
        gc="-XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:+ParallelRefProcEnabled"
    elif [ $limit_cpu -gt 1 ] && [ $limit_memory -ge 2048 ]; then
        gc="-XX:+UseConcMarkSweepGC -XX:+UseCMSInitiatingOccupancyOnly -XX:CMSInitiatingOccupancyFraction=70 -XX:+ExplicitGCInvokesConcurrentAndUnloadsClasses -XX:+CMSClassUnloadingEnabled -XX:+ParallelRefProcEnabled -XX:+CMSScavengeBeforeRemark"
    elif [ $limit_cpu -gt 1 ] && [ $limit_memory -ge 1024 ]; then
        gc="-XX:+UseParallelGC -XX:+UseAdaptiveSizePolicy -XX:MaxGCPauseMillis=100
"
    else
        gc="-XX:+UseSerialGC"
    fi
    echo $gc
}

# MetaspaceSize 设置
get_metaspace_size () {
    metaspace_size=`calc_metaspace_size`
    echo "-XX:MaxMetaspaceSize=${metaspace_size}M -XX:MetaspaceSize=${metaspace_size}M"
}

# heap-size 设置
get_heap_size () {
    # 默认大小
    heap_size=1024
    limit_memory=`calc_limit_memory`
    metaspace_size=`calc_metaspace_size`
    size=$(expr $limit_memory - $metaspace_size)
    if [ $size -ge 0 ]; then
        heap_size=$size
    fi
    echo -Xms${heap_size}m -Xmx${heap_size}m
}

# print 设置
get_print () {
    print=""
    if [ $DEBUG_PRINT = "true" ]; then
        # 打印YGC各个年龄段的对象分布
        TenuringDistribution="-XX:+PrintTenuringDistribution"
        # FullGC前后跟踪类视图
        FullGC="-XX:+PrintClassHistogramBeforeFullGC -XX:+PrintClassHistogramAfterFullGC"
        # 在GC前后打印GC日志
        HeapAtGC="-XX:+PrintHeapAtGC"
        # 打印应用暂停的时间
        StoppedTime="-XX:+PrintGCApplicationStoppedTime"
        # 打印进程并发执行时间
        ConcurrentTime="-XX:+PrintGCApplicationConcurrentTime"
        # 打印命令行参数
        CommandLineFlags="-XX:+PrintCommandLineFlags"
        # GC 日志输出
        GC="-Xloggc:$UNIFIED_OUTPUT_PATH/gc_$HOSTNAME.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps"
        # 跟踪类加载
        CLASS="-verbose:class"
        print="$TenuringDistribution $FullGC $HeapAtGC $StoppedTime $ConcurrentTime $CommandLineFlags $GC $CLASS"
    fi
    echo $print
}

get_oom_dump () {
    # oom heap dump 设置
    dump=""
    if [ $OOM_DUMP = "true" ]; then
        dump="-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$UNIFIED_OUTPUT_PATH/$HOSTNAME.dump"
    fi
    echo $dump
}

get_remote_debug () {
    # oom heap dump 设置
    remote=""
    if [ $REMOTE_DEBUG = "true" ]; then
        remote="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$REMOTE_DEBUG_PORT"
    fi
    echo $remote
}

get_java_opts () {
    heap_size=`get_heap_size`
    metaspace_size=`get_metaspace_size`
    gc=`get_gc`
    oom_dump=`get_oom_dump`
    print=`get_print`
    remote_debug=`get_remote_debug`
    echo "$heap_size $metaspace_size $gc $oom_dump $print $remote_debug $JAVA_OPTS"
}

JAVA_OPTS=`get_java_opts`

export JAVA_OPTS="$JAVA_OPTS"

echo $JAVA_OPTS

if [ $SPRING_BOOT = "true" ]; then
    java $JAVA_OPTS -jar $APP_NAME
else
    exec catalina.sh run
fi
