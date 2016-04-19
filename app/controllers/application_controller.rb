class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Se aplica antes de que carge cualquier controlador de la aplicacion
  before_action :set_categories
  before_action :set_header
  before_action :set_locale
 
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
  
  protected

	def authenticate_editor!
		redirect_to root_path unless user_signed_in? && current_user.is_editor?
	end

	def authenticate_admin!
		redirect_to root_path unless user_signed_in? && current_user.is_admin?
	end
 
  private

  def set_categories
  	@categories = Category.all
  end

  def set_header
      @header_imgName = "home-bg.jpg"
      @header_title = "Mi Blog"
      @header_subtitle = "Por Carlos Flores"
  end
end
