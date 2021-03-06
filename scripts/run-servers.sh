#!/bin/bash
mkdir -p logs

start_server() {
    cd servers/$1
    echo "Starting server in $(pwd)..."
    (nohup lein with-profile 1.5 trampoline run 1>>../../logs/run-servers 2>&1 &)
    cd ../../
}

start_servlet() {
    cd servers/$1
    echo "Starting servlet in $(pwd)..."
    (nohup lein with-profile 1.5 trampoline servlet run 1>>../../logs/run-servers 2>&1 &)
    cd ../../
}

start_nginx_xxx() {
    cd servers/$1
    mkdir -p temp logs
    echo "Starting $1 in $(pwd)..."
    ./nginx
    cd ../..
}

start_immutant() {
    cd servers/immutant
    export LEIN_IMMUTANT_BASE_DIR=.install
    echo "Checking for Immutant install..."
    lein immutant install
    lein with-profile benchmark immutant deploy
    # To measure servlet perf, comment the previous line, uncomment the next
    # lein with-profile benchmark,servlet immutant deploy
    echo "Starting Immutant in $(pwd)..."
    (nohup lein immutant run -Dhttp.port=8095 1>>../../logs/run-servers 2>&1 &)
    cd ../..
}

start_server  "embedded"
start_servlet "tomcat7"
start_servlet "jetty7"
start_servlet "jetty8"
start_servlet "jetty9"

start_nginx_xxx "nginx-php"
start_nginx_xxx "nginx-clojure"
echo "If you cannot start nginx-clojure, please check jvm configuration in the file ../servers/nginx-clojure/conf/nginx.conf"

start_immutant

tail -fn 0 logs/run-servers

# killall java
# killall nginx
# ps aux | grep java
