class Category < ActiveRecord::Base
	# tiene muchos ArticlexCategory
	has_many :articlex_category
	# tiene muchos articles, debe obtenerlos a travez de articlex_category
	has_many :articles, through: :articlex_category
	validates :name, presence: true
end
