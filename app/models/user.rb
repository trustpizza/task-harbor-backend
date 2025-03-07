class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :organization

  validates :first_name, presence: true, length: {minimum:1, maximum:255}
  validates :last_name, presence: true, length: {minimum:1, maximum:255}

  def full_name
    "#{first_name} #{last_name}"
  end
end
