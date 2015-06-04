class PpmroutesController < ApplicationController

  def index
    @ppmroutes = Ppmroute.all
    unless Ppmroute.last == nil
      @table = Ppmroute.last[:ppmroutes_array]
    end
    rescue => e
     flash[:error] = "Error de conexión con Prime Performance Manager"
     redirect_to ppmreports_path
  end

  def show
    @ppmroute = Ppmroute.find(params[:ppmroute][:id])
    rescue => e
     flash[:error] = "Escoja un reporte válido."
     redirect_to ppmreports_ppmroutes_path
  end

  def create
    @ppmroutes = Ppmroute.all
    @ppmroute = Ppmroute.create(:ppmroutes_array => Ppmroute.routescale_table)
    if @ppmroute.save
      @ppmroute.created_at.in_time_zone('Eastern Time (US & Canada)')
      flash[:notice] = "Reporte actualizado y almacenado."
      redirect_to '/ppmreports/ppmroutes'
      if @ppmroutes.count > 10
        @ppmroutes.first.delete
      end
    else
      flash[:error] = "Error al actualizar el reporte."
      render :new
    end    
    rescue => e
     flash[:error] = "Error de conexión con Prime Performance Manager"
     redirect_to ppmreports_path
  end

end