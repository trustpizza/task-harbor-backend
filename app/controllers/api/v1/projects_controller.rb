class Api::V1::ProjectsController < Api::V1::BaseController
  before_action :set_project, only: [:show, :update, :destroy, :trigger_workflow]
  before_action :set_organization

  # GET /api/v1/projects
  def index
    base_scope = @organization.projects
    filtered_scope = apply_filters(base_scope, params) # Call the simplified apply_filters
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
        # Delegate filtering to the ProjectFilter instance method
        scope = project_filter.apply_filter(scope)
      else
        # Optionally handle error: Saved filter not found or doesn't belong to user
        # For now, just ignore it or return the original scope
        Rails.logger.warn "ProjectFilter with ID #{params[:project_filter_id]} not found for user #{current_user.id}"
      end
    elsif params[:filter].present?
      # Apply ad-hoc filters from query parameters
      begin
        # Be cautious with permit! in production - consider stricter validation/parsing
        criteria = params.require(:filter).permit(
          :logic,
          conditions: [:type, :attribute, :field_definition_id, :field_definition_name, :operator, :value]
        ).to_h.deep_symbolize_keys

        # Create a temporary, unsaved ProjectFilter instance to use its logic
        temp_filter = ProjectFilter.new(criteria: criteria)
        # Delegate filtering to the temporary instance method
        scope = temp_filter.apply_filter(scope)
      rescue ActionController::ParameterMissing => e
        Rails.logger.error "Error parsing ad-hoc filter params: #{e.message}"
        # Decide how to handle invalid ad-hoc filter structure - ignore or raise/render error
      end
    end
    scope
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