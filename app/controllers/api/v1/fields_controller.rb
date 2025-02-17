class Api::V1::FieldsController < ApplicationController
  before_action :set_project
  before_action :set_field, only: [:show, :update, :destroy]

  # GET /projects/:project_id/fields
  def index
    @fields = @project.fields
    render json: @fields
  end

  # GET /projects/:project_id/fields/:id
  def show
    render json: @field
  end

  # POST /projects/:project_id/fields
  def create
    @field = @project.fields.build(field_params)

    if @field.save
      render json: @field, status: :created, location: [:api, :v1, @project, @field]
    else
      render json: @field.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/:project_id/fields/:id
  def update
    if @field.update(field_params)
      render json: @field
    else
      render json: @field.errors, status: :unprocessable_entity
    end
  end

  # DELETE /projects/:project_id/fields/:id
  def destroy
    @field.destroy
    head :no_content
  rescue ActiveRecord::RecordNotDestroyed => e # Catch specific destroy errors
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_field
      @field = @project.fields.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def field_params
      params.require(:field).permit(:field_definition_id) # adjust as needed
    end
end
