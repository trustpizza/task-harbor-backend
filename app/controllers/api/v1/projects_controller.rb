class Api::V1::ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :update, :destroy]

  # GET /api/v1/projects
  def index
    @projects = Project.all
    render json: @projects # No need to explicitly call to_json; Rails does it automatically
  end

  # GET /api/v1/projects/:id
  def show
    render json: @project, include: [:field_definitions, :field_values] # Include definitions if needed
  end

  # POST /api/v1/projects
  def create
    @project = Project.new(project_params)
    # debugger
    if @project.save
      render json: @project, status: :created, location: [:api, :v1, @project]#api_v1_project_url(@project)
    else
      render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/projects/:id
  def update
    if @project.update(project_params)
      render json: @project # Successful update; render the updated object
    else
      render json: { errors: @project.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/projects/:id
  def destroy
    @project.destroy! # Use destroy! to raise an exception if deletion fails
    head :no_content # 204 No Content is the correct response for successful delete
  rescue ActiveRecord::RecordNotDestroyed => e # Catch specific destroy errors
      render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end

  def project_params
    params.require(:project).permit(:name, :description, :due_date) # Whitelist parameters
  end
end