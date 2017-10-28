#! /usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'json'
# Rubygemsを使用することを明示
require 'rubygems'
# ActiveSupportを使用することを明示
require 'active_support'
require 'active_support/core_ext'

#module ObjFormatModule
def format(obj)
  begin
    if obj.instance_of?(Array)
      obj.each_with_index do |v,i|
        if v.instance_of?(Array) || v.instance_of?(Hash)
          obj[i] = format(v)
        end
      end
      obj.compact!
      return nil if obj.size == 0
      return obj if obj.size != 0
    elsif obj.instance_of?(Hash)
      obj.each do |k,v|
        if v.instance_of?(Array) || v.instance_of?(Hash)
          obj[k] = format(v)
        end
      end
      obj.reject! {|key, value| value == nil}
      obj.except!(:id_str, :created_at, :lang, :timestamp_ms, :sizes, :place)
      obj.except!(:geo, :coordinates, :modified, :source, :truncated , :is_quote_status, :exact, :indices, :filter_level)
#      obj.extract!(:retweet_count, :favorite_count, :favorited, :created, :retweeted)
      return nil if obj.size == 0
      return obj if obj.size != 0
      puts "format:error! no data?"
    end
=begin
  rescue => e
    p "error format"
    p obj
    p e
=end
  end
end
#end

#JSON整形
=begin
#    p obj
    puts jj(obj)
    format(obj)
#    p obj[:retweeted_status] 
#    puts jj(obj)
    if obj.include?(:retweeted_status)
      #obj.slice!(:user, :retweeted_status)
      obj[:retweeted_status][:retweet_user] = obj[:user]
      obj = obj[:retweeted_status]
      obj[:user].slice!(:id, :name, :screen_name, :profile_image_url, :profile_banner_url, :profile_background_image_url) rescue p $!
    end
    if obj.include?(:entities)
      obj[:entities].delete(:hashtags)
      if obj[:entities].include?(:media)
        if obj[:entities][:media] == obj[:extended_entities][:media]
          puts "same"
          obj[:extended_entities].except!(:media)
          obj[:entities][:media][0].except!(:id, :type)
        elsif obj[:entities][:media][0] == obj[:extended_entities][:media][0]
          obj[:extended_entities][:media].each { |m|
            obj[:entities][:media][0].each { |key, value|
              m.delete(key) if m[key] == value
              m.delete(:media_url_https)
            }
          }
        else puts "warning"
        end
      end
    end
#    if obj[:entities].include?(:urls)
    puts jj(obj)
#    puts "<tr><td>#{obj["created"]}</td><td>#{obj["user"]}</td><td>#{obj["message"]} </td></tr>"
  rescue => e
    puts "error"
    p e
=end

def url(url)
  %Q(<a href="#{url}" TARGET="_blank" >#{url}</a>) end
def img(url)
  puts "<img src=\"#{url}\">" end
def simg(url)
  puts %Q(<img src="#{url}" width="5%" height="5%">) end

def header
  puts <<END
<html><head>
  <title>Tweets #{ARGF.filename}</title>
  <style>
    table {
      border: #39f 4px solid;
    }
    td {
      border: #69f 1px solid;
      word-wrap: break-word;
    }
    table {
      color : #333;
    }
    table {
      width:100%;
      table-layout: fixed;　　/*追加する*/
    }
  </style>
</head>
<body>
<table>
<thead>
<tr><th width="80">At</th><th width="100">User</th><th>Message</th></tr>
</thead>
<tbody>
END
end

def futter
  puts "</tbody>", "</table>", "</body></html>"
end

def message(obj)
  #  puts jj(obj)
  return if obj[:system]
  #puts "<tr><td>#{obj["created"]}</td><td>#{obj["user"]}</td><td>#{obj["message"]}"
  puts "<tr><td><div style=\"font-size:80%\">"

  if not obj.include?(:retweeted_status)
    tweet = obj
    # user_name
    screen_name = obj[:user]
  else
    tweet = obj[:retweeted_status]
    user_name = tweet[:user][:name]
    screen_name = tweet[:user][:screen_name]
  end

  jst_time = Time.parse(tweet[:created_at]).in_time_zone("Asia/Tokyo").strftime("'%y %m/%d %H:%M:%S")
  puts %Q(<a href="https://twitter.com/#{screen_name}/status/#{tweet[:id]}  " TARGET="_blank" >#{jst_time}</a><br>)
  #puts %Q(<a href="https://twitter.com/intent/like?tweet_id=#{tweet[:id]}" TARGET="_blank" >Favo</a>)
  # retweet_count":0,"favorite_count":0

  puts "</td><td style=\"font-size:80%\">"
  puts screen_name, "<br>"
  puts user_name, "<br>" if user_name
  img("https://twitter.com/#{screen_name}/profile_image")
  #img(tweet[:user][:profile_image_url])
  if obj.include?(:retweeted_status)
    puts "<br>#{obj[:user]}<br>"
    img("https://twitter.com/#{obj[:user]}/profile_image?size=mini")
  end

  puts "</td><td>"
  msg = tweet[:full_text] || tweet[:text]
  puts msg.gsub(/\n/, "<br>\n"), "<br><br>"
  puts obj[:message].gsub(/\n/, "<br>\n"), "<br>"    

  tweet[:entities][:urls].each do |u|
    puts "urls", %Q(<a href="#{u[:expanded_url]}" TARGET="_blank" >#{u[:display_url]}</a>), "<br>"
  end
  if tweet.include?(:extended_entities)
    tweet[:extended_entities][:media].each do |m|
      if m.include?(:media_url)
        if m[:type] == "photo"
          puts m[:type], m[:display_url], url(m[:media_url]), "<br>"
        else
          puts "!",m[:type], url("http://#{m[:display_url]}"), m[:media_url], "<br>"
        end
        simg(m[:media_url]); puts "<br>"
  end end end
#  4.times do |i| puts "<img src=\"img/#{tweet[:id_str]}_#{i}.png\">" end
  imgstyle = MOBILE ? "height:auto;max-width:500px;" : "width:auto;max-width:100%;max-height:800px;"
  4.times do |i| puts %Q(<img src="img/#{tweet[:id]}_#{i}.png" style="#{imgstyle}">) end
#  4.times do |i| puts %Q(<img src="img/#{tweet[:id]}_#{i}.png" style="width:auto;max-height:800px;" >) end
#  4.times do |i| puts %Q(<img src="img/#{tweet[:id]}_#{i}.png" style="height:auto;max-width:500px;" >) end
  puts "</div></td></tr>"
#=end
end

MOBILE=FALSE
MAX_TWEET = MOBILE ? 100 : 500

ARGF.each_with_index do |line, idx|
  if idx % MAX_TWEET == 0
    filename = File.basename($FILENAME, ".*")
    filename = "#{filename}_#{(idx/MAX_TWEET)+1}"
    filename += MOBILE ? "_m.html" : ".html"
    puts filename
    $stdout = File.open(filename, 'w')
    $stdout.flock(File::LOCK_EX)
    header
  end

  obj = JSON.parse(line, symbolize_names: true)
  message(obj)

  if (idx%MAX_TWEET) == (MAX_TWEET-1)
    puts "<tr><td></td><td></td><td>"
    filename = File.basename($FILENAME, ".*")
    filename = "#{filename}_#{(idx/MAX_TWEET)+2}"
    filename += MOBILE ? "_m.html" : ".html"
    puts %Q(<a href="#{filename}">#{filename}</a> </td></tr>)
    futter
    $stdout = STDOUT   # 元に戻す    
  end
end

puts "<tr><td></td><td></td><td>"
filename = File.basename($FILENAME, ".*")
filename = (filename.to_i + 1).to_s
filename = "#{filename}_1"
filename += MOBILE ? "_m.html" : ".html"
puts %Q(<a href="#{filename}">#{filename}</a>)
futter
$stdout = STDOUT   # 元に戻す    

