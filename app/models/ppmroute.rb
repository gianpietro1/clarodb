class Ppmroute

  require 'rest-client'
  require 'json'
  require 'ipaddress'
  require 'open-uri'
  require 'csv'


  def self.urlworks?
  # This method is not being used...
    # base_url = 'http://ppm16-demo.cisco.com:4440/ppm/rest/reports/IP+Protocols/Route+Summary/IP+Route+Summary?outputType=json'
    response = Net::HTTP.get_response(URI(base_url))
    if response.kind_of? Net::HTTPSuccess
      return 'YES'
    else
      return 'NO'
    end
  end

  def self.route_summary
    # base_url = 'http://ppm16-demo.cisco.com:4440/ppm/rest/reports/IP+Protocols/Route+Summary/IP+Route+Summary?outputType=json'
    base_url = 'https://aquiroga:Cl4r0peru51@172.19.212.8:4440/ppm/rest/reports/IP+Protocols/Route+Summary/IP+Route+Summary?outputType=json&durationSelect=lastHour'
    data = RestClient::Request.execute(:url => base_url , :method => :get, :verify_ssl => false)
    data_parsed = JSON.load(data)
    return data_parsed
  end

  def self.inventory
    # inventory_array = CSV.read(Rails.root + "public/inventory_local.csv")
    inventory_array = CSV.read(Rails.root + "public/inventory-claro.csv")
  end

  def self.scalability
    # scalability_array = CSV.read(Rails.root + "public/scalability_local.csv")
    scalability_array = CSV.read(Rails.root + "public/scalability-claro.csv")
  end  

  def self.routescale_table
    table = Array.new []
    inventory.map do |device|
      
      scalability.map do |device_scale|
        if device_scale[0] == device[1]
          @scale = device_scale[1].to_f
          break
        else
          @scale = '-'
        end
      end

      route_summary['report']['reportData']['reportDataItems'].map do |device_routes|
        if device_routes["reportDataItem"][0] == device[0]
          @routes = device_routes["reportDataItem"][2].to_f
          break
        else
          @routes = '-'
        end
      end

      if (Float(@scale) != nil rescue false ) && (Float(@routes) != nil rescue false)
        @status = ((@routes / @scale ) * 100.00 ).round(2)
      else
        @status = 0.00
      end

      hash = Hash[node: device[0], model: device[1], scale: @scale, routes: @routes, status: @status]

      table << hash
    end

    return table.sort! { |a,b| b[:status] <=> a[:status] }
  end

end