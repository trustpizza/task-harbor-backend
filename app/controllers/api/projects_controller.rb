class Api::ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :update, :destroy]
  
  # GET /api/projects
  def index
    @projects = Project.all
    render json: @projects
  end

  # GET /api/projects/:id
  def show
    render json: @project
  end

  # POST /api/projects
  def create
    @project = Project.new(project_params)
    if @project.save
      render json: @project, status: :created
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/projects/:id
  def update
    if @project.update(project_params)
      render json: @project
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api/projects/:id
  def destroy
    @project.destroy
    head :no_content
  end

  private

  def set_project
    @project = Project.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end

  def project_params
    params.require(:project).permit(:name, :description, :due_date, :priority)
  end
end  
