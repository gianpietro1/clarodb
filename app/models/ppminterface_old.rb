class Ppminterface < ActiveRecord::Base

  serialize :ppminterfaces_array

  require 'rest-client'
  require 'json'
  require 'csv'

  def self.transport_stats
    #base_url = 'http://ppm16-demo.cisco.com:4440/ppm/rest/reports/Transport+Statistics/Interface/Interface+Bit+Rates?outputType=jsonv2&durationSelect=last3Days'
    base_url = "https://#{ENV['PPM_CREDENTIALS']}@172.19.212.8:4440/ppm/rest/reports/Transport+Statistics/Interface/Interface+Bit+Rates?outputType=jsonv2&durationSelect=last3Days&intervalTypeKey=QUARTER_HOUR"
    data = RestClient::Request.execute(:url => base_url , :method => :get, :verify_ssl => false)
    data_parsed = JSON.load(data)
    return data_parsed["report"]["data"]
  end

  def self.devint(interfaces_file)
    CSV.read(Rails.root + "public/#{interfaces_file}.csv")[1..-1]
  end

  def self.interface_table_internet(interfaces_file)
    @table = Hash.new { |hash, key| hash[key] = [] }
    table_total = Array.new []
    not_found = Array.new []
    data = transport_stats
    
    devices = Array.new []
    extra_data = Hash.new { |hash,key| hash[key] = [] }
    interfaces = Hash.new { |hash,key| hash[key] = [] }

    devint(interfaces_file).each { 
      |a,b,c,d,e,f,g,h,i,j,k| interfaces[a] << [b,c.to_f]
      unless devices.include? a
        devices << a      
      end
      extra_data[a] = Hash[iru: d.to_s,tier1: e.to_s,remote_site: f.to_s,
        link: g.to_s, route: h.to_s,local_site: i.to_s,activation_date: j.to_s,comments: k.to_s]
    }
    
    data.map do |item|
      if (devices.include? item[0])
        interfaces[item[0]].map do |interface|
          if interface[0].include? item[1]
            hash1 = Hash[bps_tx: item[6].gsub(/,/, '').to_f, bps_rx: item[7].gsub(/,/, '').to_f]
            keystring = (item[0].to_s + item[1].to_s).to_s
            @table[keystring] << hash1
          end
        end
      end
    end

    devices.each do |device|
      interfaces[device].each do |interface|
        keystring = (device.to_s + interface[0].to_s).to_s
        if @table[keystring] != []
          maxtx = ((@table[keystring].sort { |a,b| a[:bps_tx] <=> b[:bps_tx] }.last[:bps_tx])/1000000000).round(2)
          maxrx = ((@table[keystring].sort { |a,b| a[:bps_rx] <=> b[:bps_rx] }.last[:bps_rx])/1000000000).round(2)
          hash2 = Hash[node: device,
            iru: extra_data[device][:iru], 
            tier1: extra_data[device][:tier1],
            link: extra_data[device][:link],
            remote_site: extra_data[device][:remote_site],
            route: extra_data[device][:route],
            local_site: extra_data[device][:local_site],
            activation_date: extra_data[device][:activation_date],
            comments: extra_data[device][:comments],
            interface: interface[0][interface[0].rindex('-')+1..-1], 
            bps_tx: maxtx, bps_rx: maxrx,
            utilization_tx: ((maxtx/interface[1])*100.00).round(2),
            utilization_rx: ((maxrx/interface[1])*100.00).round(2) ]
          table_total << hash2
        else
          not_found << [device,interface]
        end
      end
    end

    puts "Devices not found: " + not_found.to_s
    return table_total

 end




end
