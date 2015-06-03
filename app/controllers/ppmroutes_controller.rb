class PpmroutesController < ApplicationController

  def index
    @table = Ppmroute.routescale_table
    #rescue => e
    #  flash[:error] = "Error de conexión con Prime Performance Manager"
    #  redirect_to '/ppmreports'
  end

end