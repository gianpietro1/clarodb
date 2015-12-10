class Waesite < ActiveRecord::Base

  require 'rest-client'
  require 'json'

  @ip = "173.36.206.53"
  @port = "8080"
  body = {:stageId => {:id => 0}}
  @jsonbody = JSON.generate(body)

  def self.get_all_sites
    base_url = "http://#{@ip}:#{@port}/wae/network/modeled/entities/site/get-all-sites"
    r = RestClient::Request.execute(:url => base_url , :method => :get)
    data = JSON.load(r)
    return data
  end

end