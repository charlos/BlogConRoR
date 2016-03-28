class User < ActiveRecord::Base
  #incluye los metodos del concern
  include PermissionsConcern  

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # un usuario tiene muchos articulos
  has_many :articles
  # un usuario tiene muchos comentarios
  has_many :comments

end
