require 'debug'

class Api::V1::FieldValuesController < Api::V1::BaseController
  before_action :set_project
  before_action :set_field_value, only: [:show, :update, :destroy]

  # GET /api/v1/projects/:project_id/field_values
  def index
    render json: @project.field_values
  end

  # GET /api/v1/projects/:project_id/field_values/:id
  def show
    render json: @field_value
  end

  # POST /api/v1/projects/:project_id/field_values
  def create
    field = @project.fields.find_by(id: params[:field_id])
    if field.nil?
      render json: {error: "field not found"}, status: :not_found
      return
    end

    field_value = field.field_values.build(field_value_params)

    if field_value.save
      render json: field_value, status: :created
    else
      render json: { errors: field_value.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/projects/:project_id/field_values/:id
  def update
    field = @project.fields.find_by(id: params[:field_id])

    if field.nil?
      render json: {error: "field not found"}, status: :not_found
      return
    end

    if @field_value.field_id != field.id
      render json: {error: "field value does not belong to field"}, status: :unprocessable_entity
      return
    end

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

  def set_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end

  def set_field_value
    @field_value = @project.field_values.find(params[:id])
    if @field_value.nil?
      render json: { error: "Project Field Value not found" }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project Field Value not found" }, status: :not_found
  end

  def field_value_params
    params.permit(:value, :field_id)
  end
end