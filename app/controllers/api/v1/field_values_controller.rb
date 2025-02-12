class Api::V1::FieldValuesController < ApplicationController
  before_action :set_project
  before_action :set_field_value, only: [:show, :update, :destroy]

  # GET /api/v1/projects/:project_id/field_values
  def index
    render json: @project.field_values # Get values directly from project
  end

  # GET /api/v1/projects/:project_id/field_values/:id
  def show
    render json: @field_value
  end

  # POST /api/v1/projects/:project_id/field_values (for bulk create)
  def create
    if params[:values].present? && params[:values].is_a?(Array)
      create_multiple_field_values
    else
      render json: { error: "Missing or invalid parameters.  Provide an array of 'values'." }, status: :bad_request
    end
  end

  # PATCH/PUT /api/v1/projects/:project_id/field_values/:id
  def update
    if @field_value.update(field_value_params)
      render json: @field_value
    else
      render json: { errors: @field_value.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/projects/:project_id/field_values/:id
  def destroy
    @field_value.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotDestroyed => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def create_multiple_field_values
    values_params = params.require(:values).map do |v|
      v.permit(:field_definition_id, :value)
    end

    @field_values = []
    errors = []

    field_definition_ids = values_params.map { |v| v[:field_definition_id] }.uniq
    field_definitions = FieldDefinition.where(id: field_definition_ids).includes(:field_values)

    ActiveRecord::Base.transaction do
      values_params.each do |value_param|
        field_definition_id = value_param[:field_definition_id]
        field_definition = field_definitions.find { |fd| fd.id == field_definition_id }

        if field_definition.nil?
          errors << { field_definition_id: field_definition_id, error: "Project Field Definition not found" }
          next
        end

        field_value = @project.field_values.build(value_param)
        field_value.field_definition = field_definition

        if field_value.save
          @field_values << field_value
        else
          field_value.errors.full_messages.each do |msg|
            errors << { field_definition_id: field_definition_id, value: value_param[:value], error: msg }
          end
        end
      end
    end

    if errors.empty?
      render json: @field_values, status: :created
    else
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def set_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end

  def set_field_value
    @field_value = FieldValue.find(params[:id]) # Find directly
    if @field_value.nil? || @field_value.project_id != @project.id
      render json: { error: "Project Field Value not found" }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project Field Value not found" }, status: :not_found
  end

  def field_value_params
    params.require(:field_value).permit(:field_definition_id, :value) # Still needed for updates, etc.
  end
end