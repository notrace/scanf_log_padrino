require File.expand_path("../boot.rb", __FILE__)

require File.expand_path('../scanf_do_line.rb', __FILE__)

def start
  begin_time = Time.now
  date_tag = (Time.now - 1.day).localtime.strftime("%Y%m%d")
  logger.info ">>>>>>>>>>>>>>>>>>>daily-begin:#{begin_time}"
  f = File.read("#{PADRINO_ROOT}/log/scanf/nginx_access_#{date_tag}.log")
  f.each_line do |line|
    begin

      do_line(line)
    rescue Exception => e
      STDERR.puts "=============error========="
      STDERR.puts line
      STDERR.puts e
      STDERR.puts e.backtrace.join("\n")
    ensure
    end
  end
  end_time = Time.now
  logger.info "<<<<<<<<<<<<<<<<<<<<daily-begin:#{end_time}--#{end_time - begin_time}"
end

begin
  start
  SCANF_DATA["scanf_log_time"] = (Time.now - 1.day).localtime.strftime("%Y%m%d")
rescue Exception => e
  ExceptionNotifier.notify_exception(e, :data => {"项目" => "分析前一天日志"}) if WebServer == 'yes'
end