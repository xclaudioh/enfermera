class DeudaIndirectaController < ApplicationController
  before_action :set_deuda_indirectum, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @deuda_indirecta = DeudaIndirectum.all
    respond_with(@deuda_indirecta)
  end

  def show
    respond_with(@deuda_indirectum)
  end

  def new
    @deuda_indirectum = DeudaIndirectum.new
    respond_with(@deuda_indirectum)
  end

  def edit
  end

  def create
    @deuda_indirectum = DeudaIndirectum.new(deuda_indirectum_params)
    @deuda_indirectum.save
    respond_with(@deuda_indirectum)
  end

  def update
    @deuda_indirectum.update(deuda_indirectum_params)
    respond_with(@deuda_indirectum)
  end

  def destroy
    @deuda_indirectum.destroy
    respond_with(@deuda_indirectum)
  end

  private
    def set_deuda_indirectum
      @deuda_indirectum = DeudaIndirectum.find(params[:id])
    end

    def deuda_indirectum_params
      params.require(:deuda_indirectum).permit(:tipo, :institucion, :deuda_vigente, :razon_social, :rut, :person_id)
    end
end
