# app/models/project_filter.rb
class ProjectFilter < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :criteria, presence: true

  # --- START: Added Filtering Logic ---

  # Public method to apply this filter's criteria to a given scope
  # @param scope [ActiveRecord::Relation] The initial scope (e.g., Project.all, organization.projects)
  # @return [ActiveRecord::Relation] The filtered scope
  def apply_filter(scope)
    # Use deep_symbolize_keys for consistent hash access
    criteria_hash = self.criteria.deep_symbolize_keys

    # Basic implementation: Assumes structure defined in comments
    return scope unless criteria_hash[:conditions].is_a?(Array) && criteria_hash[:conditions].any?

    # Note: OR logic currently not implemented here, defaults to AND
    # logic = criteria_hash[:logic]&.downcase == 'or' ? :or : :and

    criteria_hash[:conditions].each do |condition|
      type = condition[:type]
      operator = condition[:operator]
      value = condition[:value]

      case type
      when 'attribute'
        attribute = condition[:attribute]
        # Ensure attribute is valid for Project model
        next unless Project.attribute_names.include?(attribute.to_s)
        scope = apply_attribute_condition(scope, attribute.to_sym, operator, value)
      when 'field'
        field_def_id = condition[:field_definition_id]
        # Optional: Allow lookup by name, but ID is better
        # field_def_name = condition[:field_definition_name]
        # field_def_id ||= FieldDefinition.find_by(name: field_def_name)&.id
        next unless field_def_id.present?
        scope = apply_field_condition(scope, field_def_id, operator, value)
      end
    end
    scope
  end

  private

  # Helper for attribute conditions (moved from controller)
  def apply_attribute_condition(scope, attribute, operator, value)
    case operator
    when 'eq'
      scope.where(attribute => value)
    when 'neq'
      scope.where.not(attribute => value)
    when 'contains' # For string/text attributes
      # Ensure value is a string before using matches
      scope.where(Project.arel_table[attribute].matches("%#{value.to_s}%"))
    when 'gt'
      scope.where(Project.arel_table[attribute].gt(value))
    when 'lt'
      scope.where(Project.arel_table[attribute].lt(value))
    when 'blank'
      scope.where(attribute => [nil, ''])
    when 'present'
      scope.where.not(attribute => [nil, ''])
    else
      scope # Ignore unknown operators
    end
  end

  # Helper for field conditions (moved from controller)
  def apply_field_condition(scope, field_def_id, operator, value)
    safe_field_def_id = field_def_id.to_i

    # Use a unique alias for the join to handle multiple field conditions
    join_alias = "fields_fd_#{safe_field_def_id}"
  
    # Join the fields table with a unique alias
    scope = scope.joins("INNER JOIN fields AS #{join_alias} ON #{join_alias}.fieldable_id = projects.id AND #{join_alias}.fieldable_type = 'Project' AND #{join_alias}.field_definition_id = #{safe_field_def_id}")
  
    # Apply the condition on the joined table's value column
    field_table = Arel::Table.new(join_alias)

    case operator
    when 'eq'
      scope.where(field_table[:value].eq(value))
    when 'neq'
      scope.where(field_table[:value].not_eq(value))
    when 'contains'
      # Ensure value is a string before using matches
      scope.where(field_table[:value].matches("%#{value.to_s}%"))
    when 'gt'
       # Consider casting based on FieldDefinition type if needed
       scope.where(field_table[:value].gt(value)) # Basic string comparison
    when 'lt'
       scope.where(field_table[:value].lt(value)) # Basic string comparison
    when 'blank'
      scope.where(field_table[:value].eq(nil).or(field_table[:value].eq('')))
    when 'present'
      scope.where(field_table[:value].not_eq(nil).and(field_table[:value].not_eq('')))
    else
      scope # Ignore unknown operators
    end
  end

  # --- END: Added Filtering Logic ---

  # def validate_criteria_structure
  #   # Add logic to ensure criteria JSON has the expected keys/values/types
  # end
end
