#!/bin/bash
log_path="/home/ubuntu/xiuke3/log/"
mv ${log_path}nginx_access.log ${log_path}scanf/nginx_access_$(date -d "yesterday" +%Y%m%d).log
nginx_pid=`ps aux |grep -E 'nginx: master process'|grep -v 'grep'|awk '{print $2}'`
kill -USR1 $nginx_pid