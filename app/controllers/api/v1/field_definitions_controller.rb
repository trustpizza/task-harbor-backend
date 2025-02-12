require 'debug'

class Api::V1::FieldDefinitionsController < ApplicationController
  before_action :set_project
  before_action :set_field_definition, only: [:show, :update, :destroy]

  # GET /api/v1/projects/:project_id/field_definitions
  def index
    @field_definitions = @project.field_definitions
    render json: @field_definitions
  end

  # GET /api/v1/projects/:project_id/field_definitions/:id
  def show
    render json: @field_definition
  end

  # POST /api/v1/projects/:project_id/field_definitions
  def create
    @field_definition = @project.field_definitions.build(field_definition_params)
    # puts @field_definition.valid?
    if @field_definition.save
      render json: @field_definition, status: :created,  location: [:api, :v1, @project, @field_definition]
    else
      render json: { errors: @field_definition.errors.full_messages }, status: :unprocessable_entity # Full messages
    end
  end

  # PATCH/PUT /api/v1/projects/:project_id/field_definitions/:id
  def update
    if @field_definition.update(field_definition_params)
      render json: @field_definition
    else
      render json: { errors: @field_definition.errors.full_messages }, status: :unprocessable_entity # Full messages
    end
  end

  # DELETE /api/v1/projects/:project_id/field_definitions/:id
  def destroy
    @field_definition.destroy! # Use destroy! for error handling
    head :no_content
  rescue ActiveRecord::RecordNotDestroyed => e
      render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def field_definition_params
    params.require(:field_definition).permit(:name, :field_type, :required)
  end

  def set_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end

  def set_field_definition
    @field_definition = @project.field_definitions.find(params[:id]) # Corrected!
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project Field Definition not found" }, status: :not_found
  end
end