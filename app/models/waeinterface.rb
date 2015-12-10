class Waeinterface < ActiveRecord::Base

  require 'rest-client'
  require 'json'

  @ip = "173.36.206.53"
  @port = "8080"
  body = {:stageId => {:id => 0}}
  @jsonbody = JSON.generate(body)

  def self.get_all
    base_url = "http://#{@ip}:#{@port}/wae/network/modeled/entities/interface/get-all-interfaces"
    r = RestClient.post base_url, @jsonbody, {:content_type => :json}
    data = JSON.load(r)
    return data
  end

end