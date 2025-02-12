class Api::V1::FieldValuesController < ApplicationController
  before_action :set_project
  before_action :set_field_definition, only: [:index, :create, :update] # Only these actions need it
  before_action :set_field_value, only: [:show, :update, :destroy]

  # GET /api/v1/projects/:project_id/field_definitions/:field_definition_id/field_values
  def index
    render json: @field_definition.field_values
  end

  # GET /api/v1/projects/:project_id/field_definitions/:field_definition_id/field_values/:id
  def show
    render json: @field_value
  end

  # POST /api/v1/projects/:project_id/field_definitions/:field_definition_id/field_values (for bulk create)
  def create
    values_params = params.require(:values).map do |v|
      v.permit(:field_definition_id, :value)
    end
  
    @field_values = []
    errors = [] # Array to collect all errors
  
    values_params.each do |value_param|
      field_definition_id = value_param[:field_definition_id]
      field_definition = FieldDefinition.find_by_id(field_definition_id)
  
      if field_definition.nil?
        errors << { field_definition_id: field_definition_id, error: "Project Field Definition not found" }
        next # Skip to the next iteration
      end
  
      field_value = field_definition.field_values.build(value_param) # Use field_definition here!
      field_value.project = @project # Ensure project association
      if field_value.save
        @field_values << field_value
      else
        errors << { field_definition_id: field_definition_id, errors: field_value.errors.full_messages }
      end
    end
  
    if errors.empty?
      render json: @field_values, status: :created
    else
      render json: { errors: errors }, status: :unprocessable_entity # Return all errors
    end
  end

  # PATCH/PUT /api/v1/projects/:project_id/field_definitions/:field_definition_id/field_values/:id
  def update
    if @field_value.update(field_value_params)
      render json: @field_value
    else
      render json: { errors: @field_value.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/projects/:project_id/field_definitions/:field_definition_id/field_values/:id
  def destroy
    @field_value.destroy! # Use destroy! for error handling
    head :no_content
  rescue ActiveRecord::RecordNotDestroyed => e
      render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end

  def set_field_definition
    @field_definition = FieldDefinition.find(params[:field_definition_id])
  rescue ActiveRecord::RecordNotFound
      render json: { error: "Project Field Definition not found" }, status: :not_found
  end

  def set_field_value
    @field_value = @field_definition.field_values.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project Field Value not found" }, status: :not_found
  end

  def field_value_params
    params.require(:field_value).permit(:value) # Permit only 'value'
  end
end