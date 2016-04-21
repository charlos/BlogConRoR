class ArticlesController < ApplicationController
  # Antes de ver un articulo se verifica si se inició sesión
  before_action :authenticate_user!, except: [:show, :index]
  # Antes de ver, editar, destruir, actualizar un articulo, se debe obtener dicho articulo
  before_action :find_article, only: [:show, :edit, :destroy, :update, :publish]
  # Valida que tenga permisos para realizar dichas acciones
  before_action :authenticate_editor!, only: [:new, :create, :update]
  # Valida que tenga permisos para realizar dichas acciones
  before_action :authenticate_admin!, only: [:destroy, :publish]

  def index
    @header_subtitle = "Todos los Articulos"
  	# obtiene todos los articulos
    #@articles = Article.all
    @articles = getPermittedArticles(current_user)

  end

  def show
  	#@article = Article.find(params[:id])
  	@article.update_visits_count
  	@comment = Comment.new
  end

  def new
    @header_subtitle = "Crear Articulo"
  	@article = Article.new
    @categories = Category.all
  end

  def edit
  	#@article = Article.find(params[:id])
    if !(user_signed_in? and current_user.id == @article.user.id and @article.may_publish?)
    # Se puede Editar si es el usuario que escribió el articulo y si aún no fue publicado
      redirect_to articles_path
    end
  end

  def create
  	#se utiliza strong params para crear un articulo
  	#se crea un nuevo articulo asociado al usuario actualmente logeado en el sistema
  	@article = current_user.articles.new(article_params)
    @article.categories = params[:categories]
    
  	if @article.save
  		#si el articulo se guardo correctamente, se muestra el articulo
  		redirect_to @article
  	else
  		#si no se guardo el articulo, se dibuja la vista articles/new
  		render :new
  	end
  end

  def destroy
  	#@article = Article.find(params[:id])
    if @article.may_publish?
    # Si el articulo pude ser publicado, significa que todavia no fue publicado, por lo tanto puedo eliminarlo
      @article.destroy #elimina el objeto de la DB
      redirect_to articles_path
    end
  end

  def update
  	#@article = Article.find(params[:id])

  	if @article.update(article_params)
  		redirect_to @article
  	else
  		render :edit
  	end
  end

  def publish
    @article.publish!
    redirect_to @article
  end

  private

  def article_params
  	#solo se van a tener en cuenta los parametros title y body, sin importar todos los parametros que se reciban del cliente
  	params.require(:article).permit(:title, :body, :cover, :categories)
  end

  def find_article
  	@article = Article.find(params[:id])
  end

  def getPermittedArticles current_user

    if not current_user.nil? and current_user.is_admin?
      # obtiene todos los articulos
      @articles = Article.all.paginate(page: params[:page], per_page: 200)
    elsif not current_user.nil? and (current_user.is_editor? or current_user.is_normal_user?)
      # obtiene los articulos publicados y los articulos borrador del usuario de la session
      @articles = Article.paginate(page: params[:page], per_page: 200).published.concat(current_user.articles.in_draft)
    elsif current_user.nil?
      # obtiene los articulos publicados
      @articles = Article.paginate(page: params[:page], per_page: 200).published  
    end

    @articles
  end
end
