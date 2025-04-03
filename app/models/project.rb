class Project < ApplicationRecord
  # Associations
  belongs_to :organization
  belongs_to :project_manager, class_name: 'User', foreign_key: 'project_manager_id'
  #Ex:- :null => false
  has_many :fields, as: :fieldable, dependent: :destroy
  has_many :field_definitions, through: :fields
  has_many :field_values, through: :fields
  has_many :tasks, dependent: :destroy
  has_many :workflows, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 5000 }, allow_blank: true # Allow blank descriptions
  validates :due_date, comparison: { greater_than_or_equal_to: -> { Time.zone.today } }, presence: true
  
  # Scopes
  scope :upcoming, -> { where("due_date >= ?", Time.zone.today) }
  scope :overdue, -> { where("due_date < ?", Time.zone.today) }

  # Methods
  def trigger_workflow(workflow)
    ActiveRecord::Base.transaction do
      workflow.tasks.each do |task|
        self.tasks.create!(
          name: task.name,
          description: task.description,
          due_date: task.due_date
        )
      end
    end
  end
end
