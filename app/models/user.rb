class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  include Devise::JWT::RevocationStrategies::JTIMatcher
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self
  has_secure_password
  # Associations
  has_many :managed_projects, as: :project_manager, class_name: 'Project'
  belongs_to :organization

  validates :first_name, presence: true, length: {minimum:1, maximum:255}
  validates :last_name, presence: true, length: {minimum:1, maximum:255}

  def full_name
    "#{first_name} #{last_name}"
  end
end
