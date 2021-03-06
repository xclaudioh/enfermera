class JobsController < ApplicationController
  before_action :set_job, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @jobs = Job.visible().scheduled().order('created_at DESC')
    if current_user.present?
      if current_user.role?(:web)
        @jobs = Job.all.order('created_at DESC')
      end
    end    
    respond_with(@jobs)
  end

  def show
    respond_with(@job)
  end

  def new
    @job = Job.new
    respond_with(@job)
  end

  def edit
  end

  def create
    jp = job_params


    jp[:fecha_desde] = job_params[:fecha_desde].present? ? Date.strptime(job_params[:fecha_desde], '%d-%m-%Y') : DateTime.now.to_date  
    jp[:fecha_hasta] = job_params[:fecha_hasta].present? ? Date.strptime(job_params[:fecha_hasta], '%d-%m-%Y') : Date.strptime('31-12-2099', '%d-%m-%Y') 
    @job = Job.new(jp)
    @job.save
    respond_with(@job)
  end

  def update
    jp = job_params
    jp[:fecha_desde] = job_params[:fecha_desde].present? ? Date.strptime(job_params[:fecha_desde], '%Y-%m-%d') : DateTime.now.to_date  
    jp[:fecha_hasta] = job_params[:fecha_hasta].present? ? Date.strptime(job_params[:fecha_hasta], '%Y-%m-%d') : Date.strptime('31-12-2099', '%d-%m-%Y') 
    @job.update(jp)
    respond_with(@job)
  end

  def destroy
    @job.destroy
    respond_with(@job)
  end

  private
    def set_job
      @job = Job.find(params[:id])
    end

    def job_params
      params.require(:job).permit(:titulo, :descripcion, :contacto, :estado, :fecha_desde, :fecha_hasta)
    end
end
