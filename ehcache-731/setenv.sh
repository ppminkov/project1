#!/bin/sh

# Edit this file to set custom options
# Tomcat accepts two parameters JAVA_OPTS and CATALINA_OPTS
# JAVA_OPTS are used during START/STOP/RUN
# CATALINA_OPTS are used during START/RUN

. /usr/local/horizon/scripts/utils.inc

if test "x${JAVA_HOME}" = "x"; then
  export JAVA_HOME=/usr/java/jre-vmware
fi
AGENT_PATHS=""
JAVA_AGENTS=""
JAVA_LIBRARY_PATH=""
JAVA_LOGGING_PARAM=""
#This will make sure that the logs for stderr and stdout which never should be used but in case
#it used somewhere will get redirected to workspace.log
CATALINA_OUT="/opt/vmware/horizon/workspace/logs/workspace.log"
export LANG="en_US.UTF-8"
unset LC_ALL

#No need to specify heap size with Xmx.  These settings will automatically adapt to the memory size of the VM.
#Do not use the -Xms or -Xmx options in conjunction with -XX:+AggressiveHeap
#Changed from 'vcac-vami memory-tune' on every boot, see /etc/vr/memory-*
JVM_OPTS="-server -Djdk.tls.ephemeralDHKeySize=1024 -XX:+AggressiveOpts \
          -Djava.rmi.server.hostname=$(myip) \
          -XX:MaxMetaspaceSize=768m -XX:MetaspaceSize=768m \
          -Xss1m -Xmx3672m -Xms2754m \
          -XX:+UseParallelGC -XX:+UseParallelOldGC \
          -XX:NewRatio=3 -XX:SurvivorRatio=12 \
          -XX:+DisableExplicitGC \
          -XX:+UseBiasedLocking -XX:-LoopUnswitching"

echo Tomcat memory params are $JVM_OPTS

#Uncomment to produce garbage collector output suitable for viewing in GCViewer
#GC_LOG="-Xloggc:/opt/vmware/horizon/workspace/logs/gc.log -XX:+PrintHeapAtGC -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:-HeapDumpOnOutOfMemoryError"

JAVA_OPTS="$JVM_OPTS ${GC_LOG} $JAVA_LOGGING_PARAM $AGENT_PATHS $JAVA_AGENTS $JAVA_LIBRARY_PATH"

JAVA_ENDORSED_DIRS="/opt/vmware/horizon/workspace/endorsed"
JAVA_LIBRARY_PATH="/opt/vmware/horizon/lib"

ulimit -n 5000

# If a proxy is configured (PROXY_ENABLED="yes"), we expect a link like the following
# in the /etc/sysconfig/proxy file
# HTTP_PROXY=http://proxy.example.com:3128
PROXY=( `grep -vE "^#" /etc/sysconfig/proxy | tr -d " \""` )
PROXY_ENABLED=
HTTP_PROXY=
HTTPS_PROXY=
NO_PROXY=
HTTP_NOPROXY=
HTTPS_NOPROXY=
for s in ${PROXY[@]}; do
    #echo ${s%=*} = ${s##*=}
    case ${s%=*} in
        PROXY_ENABLED)
          PROXY_ENABLED=${s##*=}
          ;;
        HTTP_PROXY)
          if [ -n "${s##*=}" ] ; then
              HTTP_PROXY=${s##*://}
              HTTP_PROXY=${HTTP_PROXY%/*}
              HTTP_PROXY_USERNAME_PASSWORD=${HTTP_PROXY%@*}
              if [ "${HTTP_PROXY_USERNAME_PASSWORD}" != "${HTTP_PROXY}" ] ; then
                  HTTP_PROXY_USERNAME=${HTTP_PROXY_USERNAME_PASSWORD%:*}
                  export HTTP_PROXY_PASSWORD=${HTTP_PROXY_USERNAME_PASSWORD##*:}
                  HTTP_PROXY=${HTTP_PROXY##*@}
              fi
          fi
          ;;
        HTTPS_PROXY)
          if [ -n "${s##*=}" ] ; then
              HTTPS_PROXY=${s##*://}
              HTTPS_PROXY=${HTTPS_PROXY%/*}
              HTTPS_PROXY_USERNAME_PASSWORD=${HTTPS_PROXY%@*}
              if [ "${HTTPS_PROXY_USERNAME_PASSWORD}" != "${HTTPS_PROXY}" ] ; then
                  HTTPS_PROXY_USERNAME=${HTTPS_PROXY_USERNAME_PASSWORD%:*}
                  export HTTPS_PROXY_PASSWORD=${HTTPS_PROXY_USERNAME_PASSWORD##*:}
                  HTTPS_PROXY=${HTTPS_PROXY##*@}
              fi
           fi
          ;;
        NO_PROXY)
          NO_PROXY=${s##*=}
          ;;
    esac
done

if test "${PROXY_ENABLED}" = "yes" ; then
    if [ -n "${NO_PROXY}" ] ; then
          NO_PROXY=${NO_PROXY//",."/"|*."}
          NO_PROXY=${NO_PROXY//","/"|"}
          HTTP_NOPROXY="-Dhttp.nonProxyHosts='${NO_PROXY}'"
          HTTPS_NOPROXY="-Dhttps.nonProxyHosts='${NO_PROXY}'"
    fi
    if [ -n "${HTTP_PROXY}" ] ; then
        PROXY_HOST="${HTTP_PROXY%:*}"
        PROXY_PORT="${HTTP_PROXY##*:}"
        JAVA_OPTS="${HTTP_NOPROXY} ${JAVA_OPTS}"
        if test "${PROXY_HOST}" != "${PROXY_PORT}"; then
            JAVA_OPTS="-Dhttp.proxyPort=${PROXY_PORT} ${JAVA_OPTS}"
        fi
        if [ -n "${HTTP_PROXY_USERNAME}" ] ; then
            JAVA_OPTS="-Dhttp.proxyUser=${HTTP_PROXY_USERNAME} ${JAVA_OPTS}"
        fi
        JAVA_OPTS="-Dhttp.proxyHost='${PROXY_HOST}' ${JAVA_OPTS}"
    fi
    if [ -n "${HTTPS_PROXY}" ] ; then
        PROXY_HOST="${HTTPS_PROXY%:*}"
        PROXY_PORT="${HTTPS_PROXY##*:}"
        JAVA_OPTS="${HTTPS_NOPROXY} ${JAVA_OPTS}"
        if test "${PROXY_HOST}" != "${PROXY_PORT}"; then
            JAVA_OPTS="-Dhttps.proxyPort=${PROXY_PORT} ${JAVA_OPTS}"
        fi
        if [ -n "${HTTPS_PROXY_USERNAME}" ] ; then
            JAVA_OPTS="-Dhttps.proxyUser=${HTTPS_PROXY_USERNAME} ${JAVA_OPTS}"
        fi
        JAVA_OPTS="-Dhttps.proxyHost='${PROXY_HOST}' ${JAVA_OPTS}"
    fi
fi
