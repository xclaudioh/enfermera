class VotesController < ApplicationController
  before_filter :authenticate_user! 
  before_action :set_vote, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @votes = Vote.all
    respond_with(@votes)
  end

  def votar
    @votes = Vote.where(estado:'Abierta')
    respond_with(@votes)
  end

  def show

    @votacion_votos = @vote.vows.group(:candidate).count
    @votacion_votos = @votacion_votos.map {|k, v| [ k.candidato, v] }
    respond_with(@vote)
  end

  def new
    @vote = Vote.new
    respond_with(@vote)
  end

  def edit
  end

  def create
    @vote = Vote.new(vote_params)
    @vote.save
    respond_with(@vote)
  end

  def update
    @vote.update(vote_params)
    respond_with(@vote)
  end

  def destroy
    @vote.destroy
    respond_with(@vote)
  end



  private
    def set_vote
      @vote = Vote.find(params[:id])
    end

    def vote_params
      params.require(:vote).permit(:fecha, :votacion, :descripcion, :inicio, :termino, :estado)
    end
end
