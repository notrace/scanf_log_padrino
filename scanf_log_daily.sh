#!/usr/bin/env bash
source /home/ubuntu/.rvm/environments/ruby-2.0.0-p353
cd /home/ubuntu/xiuke3/
sleep 2
ruby -v >> ./log/task.log 2>&1
ruby app/workers/ruby_script/scanf_log_daily.rb -e production >> ./log/cron.log 2>&1
