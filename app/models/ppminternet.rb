class Ppminternet < ActiveRecord::Base

  require 'rest-client'
  require 'json'
  require 'csv'

  def self.transport_stats
    base_url = 'http://ppm16-demo.cisco.com:4440/ppm/rest/reports/Transport+Statistics/Interface/Interface+Bit+Rates?outputType=jsonv2&durationSelect=last3Days&intervalTypeKey=QUARTER_HOUR'
    data = RestClient::Request.execute(:url => base_url , :method => :get, :verify_ssl => false)
    data_parsed = JSON.load(data)
    return data_parsed["report"]["data"]
  end

  def self.devint
    return CSV.read(Rails.root + "public/devint.csv")
  end

  def self.interface_table
    @table = Hash.new { |hash, key| hash[key] = [] }
    table_total = Array.new []
    data = transport_stats

    devices = Array.new
    devint.each do |devint|
      devices << devint[0]
    end

    interfaces = Hash.new { |hash,key| hash[key] = [] }
    devint.each { |x,y| interfaces[x] << y }
    
    data.map do |item|
      if devices.include? item[0]
        if interfaces[item[0]].include? item[1]
          hash1 = Hash[bps_tx: item[6].gsub(/,/, '').to_f, bps_rx: item[7].gsub(/,/, '').to_f]
          keystring = (item[0].to_s + item[1].to_s).to_s
          @table[keystring] << hash1
        end
      end
    end

    devices.each do |device|
      interfaces[device].each do |interface|
        keystring = (device.to_s + interface.to_s).to_s
        maxtx = @table[keystring].sort { |a,b| a[:bps_tx] <=> b[:bps_tx] }.last[:bps_tx]
        maxrx = @table[keystring].sort { |a,b| a[:bps_rx] <=> b[:bps_rx] }.last[:bps_rx]
        hash2 = Hash[node: device, interface: interface, bps_tx: maxtx, bps_rx: maxrx]
        table_total << hash2
      end
    end

    return table_total

 end




end
