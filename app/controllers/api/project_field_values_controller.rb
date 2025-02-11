class Api::ProjectFieldValuesController < ApplicationController
  before_action :set_project
  before_action :set_field_definition
  before_action :set_project_field_value, only: [:show, :update, :destroy]

  # GET /api/projects/:project_id/project_field_definitions/:project_field_definition_id/project_field_values
  def index
    @project_field_values = @field_definition.project_field_values
    render json: @project_field_values
  end

  # GET /api/projects/:project_id/project_field_definitions/:project_field_definition_id/project_field_values/:id
  def show
    render json: @project_field_value
  end

  # POST /api/projects/:project_id/project_field_definitions/:project_field_definition_id/project_field_values
  def create
    @project_field_value = @field_definition.project_field_values.new(project_field_value_params)
    @project_field_value.project = @project # Ensure project association
    puts "ProjectFieldValue before save: #{@project_field_value.inspect}"
    puts "Errors before save: #{@project_field_value.errors.full_messages}"
    if @project_field_value.save
      render json: @project_field_value, status: :created
    else
      render json: { errors: @project_field_value.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/projects/:project_id/project_field_definitions/:project_field_definition_id/project_field_values/:id
  def update
    if @project_field_value.update(project_field_value_params)
      render json: @project_field_value
    else
      render json: { errors: @project_field_value.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/projects/:project_id/project_field_definitions/:project_field_definition_id/project_field_values/:id
  def destroy
    @project_field_value.destroy
    head :no_content
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end

  def set_field_definition
    @field_definition = ProjectFieldDefinition.find(params[:project_field_definition_id])
  rescue ActiveRecord::RecordNotFound
      render json: { error: "Project Field Definition not found" }, status: :not_found
  end

  def set_project_field_value
    @project_field_value = @field_definition.project_field_values.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project Field Value not found" }, status: :not_found
  end

  def project_field_value_params
    params.require(:project_field_value).permit(:value) # Permit only 'value' (or other attributes as needed)
  end
end
