class Api::V1::ProjectFieldValuesController < ApplicationController
  before_action :set_project
  before_action :set_field_definition, only: [:index, :create, :update] # Only these actions need it
  before_action :set_project_field_value, only: [:show, :update, :destroy]

  # GET /api/v1/projects/:project_id/project_field_definitions/:project_field_definition_id/project_field_values
  def index
    render json: @field_definition.project_field_values
  end

  # GET /api/v1/projects/:project_id/project_field_definitions/:project_field_definition_id/project_field_values/:id
  def show
    render json: @project_field_value
  end

  # POST /api/v1/projects/:project_id/project_field_definitions/:project_field_definition_id/project_field_values (for bulk create)
  def create
    # Expect JSON like: { "values": [{ "project_field_definition_id": 1, "value": "123" }, { ... }] }
    values_params = params.require(:values).map { |v| v.permit(:project_field_definition_id, :value) }

    @project_field_values = []
    success = true

    values_params.each do |value_param|
      pfd_id = value_param[:project_field_definition_id]
      value = value_param[:value]
      pfd = ProjectFieldDefinition.find_by_id(pfd_id) # Ensure the definition exists
      if pfd
        @project_field_value = @field_definition.project_field_values.build(value_param)
        @project_field_value.project = @project # Ensure project association
        if @project_field_value.save
          @project_field_values << @project_field_value
        else
          success = false
          @error_message = @project_field_value.errors.full_messages.join(", ") # Combine errors
          break # Stop on the first error for now.  Could accumulate all.
        end
      else
        success = false
        @error_message = "Project Field Definition not found"
        break
      end
    end

    if success
      render json: @project_field_values, status: :created
    else
      render json: { errors: @error_message }, status: :unprocessable_entity # Return errors or a general message
    end
  end

  # PATCH/PUT /api/v1/projects/:project_id/project_field_definitions/:project_field_definition_id/project_field_values/:id
  def update
    if @project_field_value.update(project_field_value_params)
      render json: @project_field_value
    else
      render json: { errors: @project_field_value.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/projects/:project_id/project_field_definitions/:project_field_definition_id/project_field_values/:id
  def destroy
    @project_field_value.destroy! # Use destroy! for error handling
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
    params.require(:project_field_value).permit(:value) # Permit only 'value'
  end
end