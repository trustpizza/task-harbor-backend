class Api::V1::ProjectsController < Api::V1::BaseController
  before_action :set_project, only: [:show, :update, :destroy, :trigger_workflow]
  before_action :set_organization

  # GET /api/v1/projects
  def index
    base_scope = @organization.projects
    filtered_scope = apply_filters(base_scope, params)
    @projects = filtered_scope.includes(included_relationships_dependencies)


    render json: ProjectSerializer.new(@projects, include: included_relationships, params: { include: included_relationships }).serializable_hash
  end

  # GET /api/v1/projects/:id
  def show
    render json: ProjectSerializer.new(@project, include: included_relationships, params: { include: included_relationships }).serializable_hash
  end

  # POST /api/v1/projects
  def create
    @project = @organization.projects.new(project_params)
    if @project.save
      render json: ProjectSerializer.new(@project).serializable_hash, status: :created, location: [:api, :v1, @project]
    else
      render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/projects/:id
  def update
    if @project.update(project_params)
      render json: ProjectSerializer.new(@project).serializable_hash
    else
      render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/projects/:id
  def destroy
    @project.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotDestroyed => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # POST /api/v1/projects/:id/trigger_workflow
  def trigger_workflow
    workflow = Workflow.find(params[:workflow_id])
    if workflow.should_trigger?(params[:conditions])
      @project.trigger_workflow(workflow)
      render json: { message: "Workflow triggered successfully" }, status: :ok
    else
      render json: { error: "Workflow conditions not met" }, status: :unprocessable_entity
    end
  end

  private

  def apply_filters(scope, params)
    if params[:project_filter_id].present?
      # Apply a saved filter
      project_filter = current_user.project_filters.find_by(id: params[:project_filter_id])
      if project_filter
        scope = apply_criteria(scope, project_filter.criteria.deep_symbolize_keys) # Use criteria from saved filter
      else
        # Optionally handle error: Saved filter not found or doesn't belong to user
        # For now, just ignore it or return the original scope
      end
    elsif params[:filter].present?
      # Apply ad-hoc filters from query parameters
      # Example: ?filter[logic]=AND&filter[conditions][0][type]=attribute&filter[conditions][0][attribute]=is_complete&filter[conditions][0][operator]=eq&filter[conditions][0][value]=false
      criteria = params[:filter].permit!.to_h.deep_symbolize_keys # Be cautious with permit! in production
      scope = apply_criteria(scope, criteria)
    end
    scope
  end

  def apply_criteria(scope, criteria)
    # Basic implementation: Assumes structure defined in ProjectFilter model comments
    return scope unless criteria[:conditions].is_a?(Array) && criteria[:conditions].any?

    logic = criteria[:logic]&.downcase == 'or' ? :or : :and # Default to AND

    # Use Arel for OR conditions if needed, or build separate queries and combine
    # For simplicity here, we'll focus on AND logic first. Handling complex OR/AND needs careful Arel construction.

    criteria[:conditions].each do |condition|
      type = condition[:type]
      operator = condition[:operator] # e.g., 'eq', 'neq', 'contains', 'gt', 'lt', 'blank', 'present'
      value = condition[:value]

      case type
      when 'attribute'
        attribute = condition[:attribute]
        # Ensure attribute is valid for Project model to prevent arbitrary code execution
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

  def apply_attribute_condition(scope, attribute, operator, value)
    # Sanitize operator and value
    # Example operators:
    case operator
    when 'eq'
      scope.where(attribute => value)
    when 'neq'
      scope.where.not(attribute => value)
    when 'contains' # For string/text attributes
      scope.where(Project.arel_table[attribute].matches("%#{value}%"))
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

  # Helper for field conditions
  def apply_field_condition(scope, field_def_id, operator, value)
    # Join with fields table for the specific field definition
    # Use a unique alias for the join to handle multiple field conditions
    join_alias = "fields_fd_#{field_def_id}"
    scope = scope.joins("INNER JOIN fields AS #{join_alias} ON #{join_alias}.fieldable_id = projects.id AND #{join_alias}.fieldable_type = 'Project' AND #{join_alias}.field_definition_id = #{field_def_id}")

    # Apply condition on the joined table's value column
    field_table = Field.arel_table.alias(join_alias)

    case operator
    when 'eq'
      scope.where(field_table[:value].eq(value))
    when 'neq'
      scope.where(field_table[:value].not_eq(value))
    when 'contains'
      scope.where(field_table[:value].matches("%#{value}%"))
    # Add other operators (gt, lt) - consider casting value based on FieldDefinition type if needed
    when 'gt'
       # May need casting depending on field type: scope.where("CAST(#{join_alias}.value AS INTEGER) > ?", value)
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

  # Helper to determine needed includes based on requested relationships
  # This prevents N+1 queries if filters don't require joins but includes do
  def included_relationships_dependencies
    deps = []
    # Add other potential dependencies based on included_relationships
    deps << { fields: :field_definition } if included_relationships.include?('fields') || included_relationships.include?('field_definitions')
    deps
  end

  def set_organization
    @organization = current_user.organization
  end

  def set_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end

  def project_params
    params.require(:project).permit(
      :name,
      :description,
      :due_date,
      :organization_id,
      :project_manager_id,
      fields: [:id, :type],
      field_definitions: [:id, :type],
      field_values: [:id, :type],
      tasks: [:id, :type]
    )
  end

  def field_params
    params.require(:field).permit(:field_definition_id, :value, :name)
  end

  # DRY method for determining included relationships
  def included_relationships
    valid_includes = %w[workflows tasks field_definitions fields]
    requested_includes = params[:include].to_s.split(",")

    if requested_includes.include?("all")
      valid_includes
    else
      requested_includes.select { |rel| valid_includes.include?(rel) }
    end
  end
end