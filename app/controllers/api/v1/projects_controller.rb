class Api::V1::ProjectsController < Api::V1::BaseController
  before_action :set_project, only: [:show, :update, :destroy]
  before_action :set_organization

  # GET /api/v1/projects
  def index
    @projects = @organization.projects
    render json: ProjectSerializer.new(@projects).serializable_hash
  end

  # GET /api/v1/projects/:id
  def show
    render json: ProjectSerializer.new(@project, include: [:field_definitions, :field_values, :fields]).serializable_hash
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

  private

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
end