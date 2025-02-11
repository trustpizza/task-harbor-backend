class Api::ProjectFieldDefinitionsController < ApplicationController
  before_action :set_project
  before_action :set_project_field_definition, only: [:show, :update, :destroy]

  # GET /api/projects/:project_id/project_field_definitions
  def index
    @project_field_definitions = @project.project_field_definitions
    render json: @project_field_definitions
  end

  # GET /api/projects/:project_id/project_field_definitions/:id
  def show
    render json: @project_field_definition
  end

  # POST /api/projects/:project_id/project_field_definitions
  def create
    @project_field_definition = @project.project_field_definitions.build(project_field_definition_params)

    if @project_field_definition.save
      render json: @project_field_definition, status: :created # 201 Created
    else
      render json: { errors: @project_field_definition.errors }, status: :unprocessable_entity # 422
    end
  end

  # PATCH/PUT /api/projects/:project_id/project_field_definitions/:id
  def update
    if @project_field_definition.update(project_field_definition_params)
      render json: @project_field_definition
    else
      render json: { errors: @project_field_definition.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /api/projects/:project_id/project_field_definitions/:id
  def destroy
    @project_field_definition.destroy
    head :no_content # 204 No Content (best practice for DELETE)
  end

  private

  def project_field_definition_params
    params.permit(:name, :field_type, :options) # Whitelist allowed attributes
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_project_field_definition
    @project_field_definition = @project.project_field_definitions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project Field Definition not found" }, status: :not_found
  end
end