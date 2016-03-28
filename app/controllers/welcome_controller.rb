class WelcomeController < ApplicationController
	# Antes de mostrar dashboard, verificar que el usuario sea admin
	before_action :authenticate_admin!, only: [:dashboard]

  def index
  end

  def dashboard
  	@articles = Article.all.porEstado.porFecha
  end
end
