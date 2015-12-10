class WaesitesController < ApplicationController

  def index
    @sites = Waesite.get_all_sites
  end

end