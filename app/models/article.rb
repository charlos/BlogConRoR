class Article < ActiveRecord::Base
	include AASM

	# un articulo pertenece a un usuario
	belongs_to :user
	# obtiene los comentarios de un articulo
	has_many :comments
	
	# tiene muchos ArticlexCategory
	has_many :articlex_category
	# tiene muchos categories, debe obtenerlos a travez de articlex_category
	has_many :categories, through: :articlex_category

	validates :title, presence: true
	validates :body, presence: true, length: { minimum: 20 }
	# antes de hacer el INSERT se llama a "set_visits_count"
	before_create :set_visits_count
	# despues de hacer el insert llama a "save_categories"
	after_create :save_categories

	has_attached_file :cover, styles: { medium: "1280x720", thumb:"800x600" }
	validates_attachment_content_type :cover, content_type: /\Aimage\/.*\Z/

	# scopes
	scope :ultimos, ->{ order("created_at DESC").limit(10) }
	scope :porFecha, ->{ order("created_at DESC") }
	scope :porEstado, ->{ order("state ASC") }
	scope :publicados, ->{ where(state: "published") }
	#es el equivalente a un metodo de clase:
	#def self.publicados
	#	Article.where(state: "published")
	#end

	# Custom setter
	def categories=(value)
		@categories = value
	end

	def update_visits_count
		#self.save if self.visists_count.nil?
		# incrementa en "1", cada vez que se lo llama (se utiliza en articles/show)
		self.update( visists_count: self.visists_count + 1 )
	end

	aasm column: "state" do
		state :in_draft, initial: true
		state :published

		event :publish do
			transitions from: :in_draft, to: :published
		end

		event :unpublish do
			transitions from: :published, to: :in_draft
		end
	end

	private

	def save_categories
		# si se seleccionó al menos una categoria, entonces la guardo.
		unless @categories.nil?
			@categories.each do |category_id|
				ArticlexCategory.create(category_id: category_id, article_id: self.id)
			end
		end
	end

	def set_visits_count
		self.visists_count = 0
	end

end
