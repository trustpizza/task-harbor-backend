class ProjectFieldDefinition < ApplicationRecord
  belongs_to :project
  has_many :project_field_values, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :field_type, presence: true, inclusion: { in: %w[string integer date boolean dropdown text] }
  validate :options_format # Custom validation for options

  def options_format
    if options.present?
      begin
        parsed_options = JSON.parse(options)  # Attempt to parse as JSON
        # Further validation based on field_type if needed. Example for dropdown:
        if field_type == "dropdown"
          unless parsed_options.is_a?(Array) && parsed_options.all? { |option| option.is_a?(String) }
            errors.add(:options, "must be a JSON array of strings for dropdowns")
          end
        elsif field_type == "integer" #Example for integer field type
          unless parsed_options.is_a?(Hash) && parsed_options["min"].is_a?(Integer) && parsed_options["max"].is_a?(Integer)
            errors.add(:options, "must be a JSON Hash of min and max for integer type")
          end
        # Add more field_type specific validations here as needed.
        end
      rescue JSON::ParserError
        errors.add(:options, "must be valid JSON")
      end
    end
  end
end