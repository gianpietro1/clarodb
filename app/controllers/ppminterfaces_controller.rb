class PpminterfacesController < ApplicationController
  
  def index
    @ppmroutes = Ppminterface.all
    unless Ppminterface.last == nil
      @table_interfaces = Ppminterface.last[:ppminterfaces_array]
    end
    rescue => e
     flash[:error] = "Error de conexión con Prime Performance Manager"
     redirect_to ppmreports_path
  end

  def show
    @ppminterface = Ppminterface.find(params[:ppminterface][:id])
    rescue => e
     flash[:error] = "Escoja un reporte válido."
     redirect_to ppmreports_ppminterfaces_path
  end

  def create
    @ppminterfaces = Ppminterface.all
    @ppminterface = Ppminterface.create(:ppminterfaces_array => Ppminterface.interface_table_internet("internet"))
    if @ppminterface.save
      @ppminterface.created_at.in_time_zone('Eastern Time (US & Canada)')
      flash[:notice] = "Reporte actualizado y almacenado."
      redirect_to '/ppmreports/ppminterfaces'
      if @ppminterfaces.count > 10
        @ppminterfaces.first.delete
      end
    else
      flash[:error] = "Error al actualizar el reporte."
      render :new
    end    
    #rescue => e
    # flash[:error] = "Error de conexión con Prime Performance Manager"
    # redirect_to ppmreports_path
  end

end
