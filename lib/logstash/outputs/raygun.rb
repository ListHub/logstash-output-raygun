# encoding: utf-8

require "logstash/outputs/base"
require "logstash/namespace"

#
# Uses the raygun API to create an issue based off of a message
#

class LogStash::Outputs::Raygun < LogStash::Outputs::Base
  config_name "raygun"
  milestone 1

  #Raygun API key
  config :api_key, :validate => :string, :required => true
  config :custom_data, :validate => :hash


  public
  def register
    @logger.warn("Register ")
    require "raygun4ruby"
  end

  public
  def receive(event)
    @logger.warn("Recieve? ")
    return unless output?(event)

    if event == LogStash::SHUTDOWN
      finished
      return
    end

    @logger.warn("API "+@api_key)

    Raygun.setup do |config|
      config.api_key = @api_key
    end

    e = Exception.new(event['cronjob'])
    @custom_data.each do |key, value|
      custom_data[key] = eval('"'+value+'"')
    end

    result = Raygun.track_exception(e, custom_data: @custom_data)
  end
end