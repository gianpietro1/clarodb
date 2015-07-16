class Ppminterface < ActiveRecord::Base

  serialize :ppminterfaces_array

  require 'rest-client'
  require 'json'
  require 'csv'

  def self.transport_stats(ip_address)
    fqdn = '&FQDN=Node%3D' + ip_address
    #base_url = 'http://ppm16-demo.cisco.com:4440/ppm/rest/reports/Transport+Statistics/Interface/Interface+Bit+Rates?outputType=jsonv2&durationSelect=last3Days' + fqdn
    base_url = "https://#{ENV['PPM_CREDENTIALS']}@172.19.212.8:4440/ppm/rest/reports/Transport+Statistics/Interface/Interface+Bit+Rates?outputType=jsonv2&durationSelect=last3Days&intervalTypeKey=QUARTER_HOUR" + fqdn
    data = RestClient::Request.execute(:url => base_url , :method => :get, :verify_ssl => false)
    data_parsed = JSON.load(data)
    return data_parsed["report"]["data"]
  end

  def self.devint(interfaces_file)
    CSV.read(Rails.root + "public/#{interfaces_file}.csv")[1..-1]
  end

  def self.interface_table_internet(interfaces_file)
    interfaces_file = 'internet'
    @table = Hash.new { |hash, key| hash[key] = [] }
    @table_total = Array.new []
    not_found = Array.new []

    devices = Array.new []
    extra_data = Hash.new { |hash,key| hash[key] = [] }
    interfaces = Hash.new { |hash,key| hash[key] = [] }

    Ppminterface.devint(interfaces_file).each { 
      |a,b,c,d,e,f,g,h,i,j,k,l| interfaces[a] << [c,d.to_f]
      unless devices.include? [a,b]
        devices << [a,b]      
      end
      keystring = a + c
      extra_data[keystring] = Hash[bw: d.to_f, iru: e.to_s,tier1: f.to_s,remote_site: g.to_s,
        link: h.to_s, route: i.to_s,local_site: j.to_s,activation_date: k.to_s,comments: l.to_s]
    }
    
   data = Hash.new { |hash, key| hash[key] = [] }

    devices.map do |device|
      data[device[0]] = Ppminterface.transport_stats(device[1])
      data[device[0]].map do |item|
        interfaces[device[0]].map do |interface|
         if interface[0].include? item[0]
            hash1 = Hash[bps_tx: item[5].gsub(/,/, '').to_f, bps_rx: item[6].gsub(/,/, '').to_f]
            keystring = (device[0].to_s + item[0].to_s).to_s
            @table[keystring] << hash1
         end
        end
      end
    end

    devices.each do |device|
      interfaces[device[0]].each do |interface|
        keystring = (device[0].to_s + interface[0].to_s).to_s
        if @table[keystring] != []
          maxtx = ((@table[keystring].sort { |a,b| a[:bps_tx] <=> b[:bps_tx] }.last[:bps_tx])/1000000000).round(2)
          maxrx = ((@table[keystring].sort { |a,b| a[:bps_rx] <=> b[:bps_rx] }.last[:bps_rx])/1000000000).round(2)
          hash2 = Hash[node: device[0],
            iru: extra_data[keystring][:iru], 
            tier1: extra_data[keystring][:tier1],
            link: extra_data[keystring][:link],
            remote_site: extra_data[keystring][:remote_site],
            route: extra_data[keystring][:route],
            local_site: extra_data[keystring][:local_site],
            activation_date: extra_data[keystring][:activation_date],
            comments: extra_data[keystring][:comments],
            interface: interface[0][interface[0].rindex('-')+1..-1], 
            #interface: interface[0], 
            bps_tx: maxtx, bps_rx: maxrx,
            utilization_tx: ((maxtx/interface[1])*100.00).round(2),
            utilization_rx: ((maxrx/interface[1])*100.00).round(2) ]
          @table_total << hash2
        else
          @not_found << [device,interface]
        end
      end
    end

    puts "Devices not found: " + @not_found.to_s
    return @table_total

 end




end
