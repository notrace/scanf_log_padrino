require File.expand_path("../boot.rb", __FILE__)

require File.expand_path('../scanf_do_line.rb', __FILE__)

def start
  begin_time = Time.now
  logger.info ">>>>>>>>>>>>>>>>>>>begin:#{begin_time}"
  file_list = []
  Dir.foreach("#{PADRINO_ROOT}/log/scanf") do |filename|
    if not(filename[/^\./])
      file_list << filename
    end
  end

  logger.info "filelist:#{file_list.join(',')}"
  file_list.sort.each do |filename|
    f = File.read("#{PADRINO_ROOT}/log/scanf/#{filename}")
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
    time_tag = filename.sub('nginx_access_', '').sub('.log','')
    if time_tag.size == 8
      file_time = Time.strptime(time_tag, "%Y%m%d")

      SCANF_DATA["scanf_log_time"] = file_time.strftime("%Y-%m-%d")
    end
  end
  end_time = Time.now

  logger.info "<<<<<<<<<<<<<<<<<<<<begin:#{end_time}--#{end_time - begin_time}"
end

def init_all
    SCANF_DATA.flushdb
end

begin
  init_all
  start

end