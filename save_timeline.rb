# -*- coding: utf-8 -*-
require 'json'

class Message
  def __get_raw_value
    @value
  end
end

Plugin.create(:save_timeline) do
  
  logdir = "#{ENV['HOME']}/timeline"
  FileUtils.mkdir_p(logdir) unless FileTest.exist?(logdir)
  user = service.user || "default" rescue user = "default"
  
  on_update do | service, messages |
    if BOOT_TIME.yday != Time.now.yday
      filename = Time.now.strftime("%y%m%d")
    else
      filename = BOOT_TIME.strftime("%y%m%d%H%M")
    end
    File.open("#{logdir}/#{filename}.#{user}", "a") do |f| 
      f.flock(File::LOCK_EX)
      messages.each do |msg|
#	p Time.now
        p msg.to_s
        f.puts JSON.dump msg.__get_raw_value rescue puts $!
      end
    end
  end
  

#  on_direct_messages do |service, dms|
#  end

end
