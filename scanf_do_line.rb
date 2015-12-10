
FORMATS = {
    :combined => %r{^(\S+) - - \[(\S+ \+\d{4})\] "(\S+ \S+ [^"]+)" (\d{3}) (\d+|-) "(.*?)" "([^"]+)"$}
  }

def do_line(line)
  data = line.scan(FORMATS[:combined]).flatten
  if data.empty?
    raise "Line didn't match pattern: #{line}"
  end

  uri = URI.parse(data[2].split(' ')[1])
  uri_path_arr = uri.path.split("\/")

  if uri_path_arr[1] == 'serie' && uri_path_arr[3] == 'videos' && uri_path_arr[4] == 'show'
    STDERR.puts ">>>>>>>videos_show"
    STDERR.puts line
    begin
      add_video_share_in_video_show(data)
    rescue Exception => e
      STDERR.puts "*******error"
      STDERR.puts e
    ensure
    end
    STDERR.puts "<<<<<<<<videos_show"
  end
  if uri.path == "\/series\/show"
    STDERR.puts ">>>>>>>serie_show"
    STDERR.puts line
    begin
      add_video_share(data)
    rescue Exception => e
      STDERR.puts "*******error"
      STDERR.puts e
    ensure
    end
    STDERR.puts "<<<<<<<<serie_show"
  end

  if uri.path == "\/api\/v3\/account_videos\/create"
    STDERR.puts ">>>>>>>video_play_count"
    STDERR.puts line
    begin
      add_in_video_play(data)
    rescue Exception => e
      STDERR.puts "*******error"
      STDERR.puts e
    ensure
    end
    STDERR.puts "<<<<<<<<video_play_count"
  end

  if uri.path == "\/app_downloads\/show"
    STDERR.puts ">>>>>>>download_count"
    STDERR.puts line
    begin
      add_in_download_app(data)
    rescue Exception => e
      STDERR.puts "*******error"
      STDERR.puts e
    ensure
    end
    STDERR.puts "<<<<<<<<download_count"
  end
end

def add_video_share_in_video_show(data)
  uri = URI.parse(data[2].split(' ')[1])
  uri_path_arr = uri.path.split("\/")

  video_id = uri_path_arr[5]
  serie_id = uri_path_arr[2]
  add_video_share_count(data, video_id,serie_id)

end

def add_video_share(data)

  uri = URI.parse(data[2].split(' ')[1])

  if uri.query.blank?
    raise "query is empty #{uri}"
  end

  tmp_params = Hash[uri.query.split('&').collect{|v| v.split("=").size == 2 ? v.split("=") : [v.split("="), ""]}]

  video_id = tmp_params["video_id"]
  serie_id = tmp_params["id"]
  add_video_share_count(data, video_id,serie_id)
end

def add_video_share_count(data, video_id,serie_id)
  date_tag = Time.strptime(data[1], "%d/%b/%Y:%H:%M:%S %z").strftime("%Y-%m-%d")
  delete_date_tag = (Time.strptime(data[1], "%d/%b/%Y:%H:%M:%S %z") - 1.month).strftime("%Y-%m-%d")
# SCANF_DATA.delete @follow.second_level_cache_key
  if video_id 
    param_key = "video_share/#{video_id}"
    add_video_share_count_by_key(data, param_key)
    param_key_date_tag = "#{param_key}/#{date_tag}"
    add_video_share_count_by_key(data, param_key_date_tag)

    delete_param_key_date_tag = "#{param_key}/#{delete_date_tag}"
    delete_video_share_count_by_key(data, delete_param_key_date_tag)
  end

  if serie_id

    param_key = "serie_share/#{video_id}"
    add_video_share_count_by_key(data, param_key)
    param_key_date_tag = "#{param_key}/#{date_tag}"
    add_video_share_count_by_key(data, param_key_date_tag)

    delete_param_key_date_tag = "#{param_key}/#{delete_date_tag}"
    delete_video_share_count_by_key(data, delete_param_key_date_tag)

  end
end

def delete_video_share_count_by_key(data, param_key)
  SCANF_DATA.del "#{param_key}/weixin"
  SCANF_DATA.del "#{param_key}/weiweiboxin"
  SCANF_DATA.del "#{param_key}/all"
  SCANF_DATA.del "#{param_key}/qzone"
end

def add_video_share_count_by_key(data, param_key)

  if data[6].include?('MicroMessenger')
    SCANF_DATA["#{param_key}/weixin"] =  SCANF_DATA["#{param_key}/weixin"].to_i + 1
    SCANF_DATA["#{param_key}/all"] = SCANF_DATA["#{param_key}/all"].to_i + 1
  end
  if data[6].include?("\_\_weibo\_\_")
    SCANF_DATA["#{param_key}/weibo"] = SCANF_DATA["#{param_key}/weibo"].to_i + 1
    SCANF_DATA["#{param_key}/all"] = SCANF_DATA["#{param_key}/all"].to_i + 1
  end
  if data[5].include?("http\:\/\/user\.qzone\.qq\.com")
    SCANF_DATA["#{param_key}/qzone"] =  SCANF_DATA["#{param_key}/qzone"].to_i + 1
    SCANF_DATA["#{param_key}/all"] = SCANF_DATA["#{param_key}/all"].to_i + 1
  end
end

def add_in_video_play(data)

  uri = URI.parse(data[2].split(' ')[1])

  video_id = nil
  serie_id = nil

  referer_url = URI.parse(data[5])

  if data[5] != "-"
    uri = URI.parse(data[2].split(' ')[1])
    uri_path_arr = uri.path.split("\/")

    if uri_path_arr[1] == 'serie' && uri_path_arr[3] == 'videos' && uri_path_arr[4] == 'show'
      video_id = uri_path_arr[5]
      serie_id = uri_path_arr[2]
    end
  end
  if referer_url.path == "\/series\/show"
    tmp_params = Hash[referer_url.query.split('&').collect{|v| v.split("=").size == 2 ? v.split("=") : [v.split("="), ""]}]

    video_id = tmp_params["video_id"]
    serie_id = tmp_params["id"]
  end

 if video_id 
    SCANF_DATA["video_share/#{video_id}/play_count_weixin"] ||= 0
    SCANF_DATA["video_share/#{video_id}/play_count_weibo"] ||= 0
    SCANF_DATA["video_share/#{video_id}/play_count_all"] ||= 0

    if data[6].include?('MicroMessenger')
      SCANF_DATA["video_share/#{video_id}/play_count_weixin"] =  SCANF_DATA["video_share/#{video_id}/play_count_weixin"].to_i + 1
      SCANF_DATA["video_share/#{video_id}/play_count_all"] = SCANF_DATA["video_share/#{video_id}/play_count_all"].to_i + 1
    end
    if data[6].include?("\_\_weibo\_\_")
      SCANF_DATA["video_share/#{video_id}/play_count_weibo"] =  SCANF_DATA["video_share/#{video_id}/play_count_weibo"].to_i + 1
      SCANF_DATA["video_share/#{video_id}/play_count_all"] = SCANF_DATA["video_share/#{video_id}/play_count_all"].to_i + 1
    end

  end
  if serie_id
    SCANF_DATA["serie_share/#{serie_id}/play_count_weixin"] ||= 0
    SCANF_DATA["serie_share/#{serie_id}/play_count_weibo"] ||= 0
    SCANF_DATA["serie_share/#{serie_id}/play_count_all"] ||= 0

    if data[6].include?('MicroMessenger')
      SCANF_DATA["serie_share/#{serie_id}/play_count_weibo"] =  SCANF_DATA["serie_share/#{serie_id}/play_count_weibo"].to_i + 1
      SCANF_DATA["serie_share/#{serie_id}/play_count_all"] = SCANF_DATA["serie_share/#{serie_id}/play_count_all"].to_i + 1
    end
    if data[6].include?("\_\_weibo\_\_")
      SCANF_DATA["serie_share/#{serie_id}/play_count_weibo"] =  SCANF_DATA["serie_share/#{serie_id}/play_count_weibo"].to_i + 1
      SCANF_DATA["serie_share/#{serie_id}/play_count_all"] = SCANF_DATA["serie_share/#{serie_id}/play_count_all"].to_i + 1
    end
  end

end

# 视频分享页的app下载数
def add_in_download_app(data)
  uri = URI.parse(data[2].split(' ')[1])

  # 通过微信分享页
  # 请求来源的"-"
  # 请求地址 "/app_downloads/show?newest=true&video_id=4635&t=20150312233232&sign=xxxxx...xxx"
  # 这种地址只出现在微信客户端中访问下载页
  # 微信中不允许直接调转到app store, 需要使用“通过浏览器打开”,
  # 微信中下载app流程: 微信中serie/show -> 微信中app_download -> 浏览器打开app_download
  # agent中不包含有 MicroMessenger, 为了排除"微信中app_download"

  if !uri.query.blank?
    tmp_params = Hash[uri.query.split('&').collect{|v| v.split("=").size == 2 ? v.split("=") : [v.split("="), ""]}]
    if tmp_params["t"] && tmp_params["video_id"] && tmp_params["sign"] && data[5] == "-" && !data[6].include?('MicroMessenger')
      # 微信跳转下载校验
      t = tmp_params["t"]
      #暂时没用
      url_time = Time.strptime(t, "%Y%m%d%H%M%S")
      nginx_time = Time.strptime(data[1], "%d/%b/%Y:%H:%M:%S %z")

      video_id = tmp_params["video_id"]
      serie_id = tmp_params["id"]

      url_sign = tmp_params["sign"]

      share_token = Video::SHARE_SECRET
      param_array = [t, video_id, share_token]
      sign = Digest::MD5.hexdigest( param_array.join('_'))
      raise "sign is wrong" if url_sign != sign

      #正式开始

      SCANF_DATA["video_share/#{video_id}/wx_down_i_app"] ||= 0
      SCANF_DATA["video_share/#{video_id}/wx_down_a_app"] ||= 0
      SCANF_DATA["video_share/#{video_id}/wb_down_i_app"] ||= 0
      SCANF_DATA["video_share/#{video_id}/wb_down_a_app"] ||= 0
      SCANF_DATA["video_share/#{video_id}/all_down_i_app"] ||= 0
      SCANF_DATA["video_share/#{video_id}/all_down_a_app"] ||= 0

      if data[6].include?('iPhone')
        SCANF_DATA["video_share/#{video_id}/wx_down_i_app"] = SCANF_DATA["video_share/#{video_id}/wx_down_i_app"].to_i + 1
        SCANF_DATA["video_share/#{video_id}/all_down_i_app"] = SCANF_DATA["video_share/#{video_id}/all_down_i_app"].to_i + 1
      end

      if data[6].include?('android') || data[6].include?('Android')
        SCANF_DATA["video_share/#{video_id}/wx_down_a_app"] = SCANF_DATA["video_share/#{video_id}/wx_down_a_app"].to_i + 1
        SCANF_DATA["video_share/#{video_id}/all_down_a_app"] = SCANF_DATA["video_share/#{video_id}/all_down_a_app"].to_i + 1
      end

      # 系列统计
      SCANF_DATA["serie_share/#{serie_id}/wx_down_i_app"] ||= 0
      SCANF_DATA["serie_share/#{serie_id}/wx_down_a_app"] ||= 0

      if data[6].include?('iPhone')
        SCANF_DATA["serie_share/#{serie_id}/wx_down_i_app"] = SCANF_DATA["serie_share/#{serie_id}/wx_down_i_app"].to_i + 1
      end

      if data[6].include?('android')
        SCANF_DATA["serie_share/#{serie_id}/wx_down_a_app"] = SCANF_DATA["serie_share/#{serie_id}/wx_down_a_app"].to_i + 1
      end

    end
  end

#通过微博下载app
  referer_url = URI.parse(data[5])

  if referer_url.path == "\/series\/show" && !referer_url.query.blank?

    tmp_params = Hash[referer_url.query.split('&').collect{|v| v.split("=").size == 2 ? v.split("=") : [v.split("="), ""]}]

    video_id = tmp_params["video_id"]
    serie_id = tmp_params["id"]
  end

  uri_path_arr = referer_url.path.split("\/")

  if uri_path_arr[1] == 'serie' && uri_path_arr[3] == 'videos' && uri_path_arr[4] == 'show'
    video_id = uri_path_arr[5]
    serie_id = uri_path_arr[2]
  end

  if video_id
    if data[6].include?("\_\_weibo\_\_")
      if data[6].include?('iPhone')
        SCANF_DATA["video_share/#{video_id}/wb_down_i_app"] = SCANF_DATA["video_share/#{video_id}/wb_down_i_app"].to_i + 1
        SCANF_DATA["video_share/#{video_id}/all_down_i_app"] = SCANF_DATA["video_share/#{video_id}/all_down_i_app"].to_i + 1
      end

      if data[6].include?('android')
        SCANF_DATA["video_share/#{video_id}/wb_down_a_app"] = SCANF_DATA["video_share/#{video_id}/wb_down_a_app"].to_i + 1
        SCANF_DATA["video_share/#{video_id}/all_down_a_app"] = SCANF_DATA["video_share/#{video_id}/all_down_a_app"].to_i + 1
      end
    end
  end
  if serie_id 
    # 系列统计
    SCANF_DATA["serie_share/#{serie_id}/wb_down_i_app"] ||= 0
    SCANF_DATA["serie_share/#{serie_id}/wb_down_a_app"] ||= 0

    if data[6].include?('iPhone')
      SCANF_DATA["serie_share/#{serie_id}/wb_down_i_app"] = SCANF_DATA["serie_share/#{serie_id}/wb_down_i_app"].to_i + 1
    end

    if data[6].include?('android')
      SCANF_DATA["serie_share/#{serie_id}/wb_down_a_app"] = SCANF_DATA["serie_share/#{serie_id}/wb_down_a_app"].to_i + 1
    end
  end
end
