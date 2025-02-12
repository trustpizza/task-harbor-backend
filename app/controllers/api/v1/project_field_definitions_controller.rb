class Api::V1::ProjectFieldDefinitionsController < ApplicationController
  before_action :set_project
  before_action :set_project_field_definition, only: [:show, :update, :destroy]

  # GET /api/v1/projects/:project_id/project_field_definitions
  def index
    @project_field_definitions = @project.project_field_definitions
    render json: @project_field_definitions
  end

  # GET /api/v1/projects/:project_id/project_field_definitions/:id
  def show
    render json: @project_field_definition
  end

  # POST /api/v1/projects/:project_id/project_field_definitions
  def create
    @project_field_definition = @project.project_field_definitions.build(project_field_definition_params)

    if @project_field_definition.save
      render json: @project_field_definition, status: :created, location: [@project, @project_field_definition] # Location header
    else
      render json: { errors: @project_field_definition.errors.full_messages }, status: :unprocessable_entity # Full messages
    end
  end

  # PATCH/PUT /api/v1/projects/:project_id/project_field_definitions/:id
  def update
    if @project_field_definition.update(project_field_definition_params)
      render json: @project_field_definition
    else
      render json: { errors: @project_field_definition.errors.full_messages }, status: :unprocessable_entity # Full messages
    end
  end

  # DELETE /api/v1/projects/:project_id/project_field_definitions/:id
  def destroy
    @project_field_definition.destroy! # Use destroy! for error handling
    head :no_content
  rescue ActiveRecord::RecordNotDestroyed => e
      render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def project_field_definition_params
    params.require(:project_field_definition).permit(:name, :field_type, :required, :min_length, :max_length, :format) # Require and permit
  end

  def set_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end

  def set_project_field_definition
    @project_field_definition = @project.project_field_definitions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project Field Definition not found" }, status: :not_found
  end
end