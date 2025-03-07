class Api::V1::TasksController < ApplicationController
  before_action :set_project
  before_action :set_task, only: [:show, :update, :destroy]

  # GET /api/v1/projects/:project_id/tasks
  def index
    @tasks = @project.tasks
    render json: @tasks
  end

  # GET /api/v1/projects/:project_id/tasks/:id
  def show
    render json: @task, include: [:fields, :field_values]
  end

  # POST /api/v1/projects/:project_id/tasks
  def create
    @task = @project.tasks.new(task_params)
    if @task.save
      render json: @task, status: :created, location: [:api, :v1, @project, @task]
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/projects/:project_id/tasks/:id
  def update
    if @task.update(task_params)
      render json: @task
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/projects/:project_id/tasks/:id
  def destroy
    @task.destroy!
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

  def set_task
    @task = @project.tasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end

  def task_params
    params.require(:task).permit(:name, :description, :status, :due_date)
  end
end
