class PpmroutesController < ApplicationController

  def index
    @table = Ppmroute.routescale_table
  end

end