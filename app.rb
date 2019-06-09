require 'httparty'
require 'discordrb'
require 'dotenv'

class MinecraftUpdater
  def initialize
	@current_version = current_version
	@latest_version = latest_version
  end

  def restart_if_new_version
	if new_version?
	  restart_minecraft_server!
	  send_message_to_discord!
	elsif
	  puts "No new version!"
	end
  end

  private

  def current_version
	response = `ls /root/minecraft | grep minecraft_server`  
	list = response.split("\n")
	list.map { |item| item.delete_prefix("minecraft_server.").delete_suffix(".jar") }.sort.last 
  end

  def latest_version
	response = HTTParty.get("https://launchermeta.mojang.com/mc/game/version_manifest.json")
	response.first[1]["release"] 
  end

  def new_version?
	@current_version != @latest_version
  end
	
  def restart_minecraft_server!
	system('docker restart minecraft')
  end
	
  def send_message_to_discord!
    bot = Discordrb::Bot.new token: ENV["DISCORD_BOT_TOKEN"]
	bot.run(true)
	bot.send_message(ENV["CHANNEL_ID"], "Updated Minecraft to version #{@latest_version}")
	bot.join
  end
end

Dotenv.load
updater = MinecraftUpdater.new
updater.restart_if_new_version
