class Ppmroute

  require 'rest-client'
  require 'json'
  require 'ipaddress'
  require 'open-uri'
  require 'csv'

  def self.route_summary
    base_url = 'http://ppm16-demo.cisco.com:4440/ppm/rest/reports/IP+Protocols/Route+Summary/IP+Route+Summary?outputType=json'
    data = JSON.load(open(base_url))
    return data
  end

  def self.inventory
    inventory_array = CSV.read(Rails.root + "public/inventory.csv")
  end

  def self.scalability
    scalability_array = CSV.read(Rails.root + "public/scalability.csv")
  end  

  def self.routescale_table
    table = Set.new []
    inventory.map do |device|
      
      scalability.map do |device_scale|
        if device_scale[0] == device[1]
          @scale = device_scale[1]
          break
        else
          @scale = 'N/A'
        end
      end

      route_summary['report']['reportData']['reportDataItems'].map do |device_routes|
        if device_routes["reportDataItem"][0] == device[0]
          @routes = device_routes["reportDataItem"][2]
          break
        else
          @routes = 0
        end
      end

      @status = (@routes.to_f / @scale.to_f) * 100.00

      hash = Hash[node: device[0], model: device[1], scale: @scale, routes: @routes, status: @status]

      table.add(hash) 
    end

    return table
  end

end