class Api::V1::TasksController < Api::V1::BaseController
  before_action :set_taskable
  before_action :set_task, only: [:show, :update, :destroy]

  # GET /api/v1/:taskable_type/:taskable_id/tasks
  def index
    @tasks = @taskable.tasks
    render json: TaskSerializer.new(@tasks).serializable_hash
  end

  # GET /api/v1/:taskable_type/:taskable_id/tasks/:id
  def show
    render json: TaskSerializer.new(@task, include: [:fields, :field_values]).serializable_hash
  end

  # POST /api/v1/:taskable_type/:taskable_id/tasks
  def create
    @task = @taskable.tasks.new(task_params)
    if @task.save
      render json: TaskSerializer.new(@task).serializable_hash, status: :created, location: [:api, :v1, @taskable, @task]
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/:taskable_type/:taskable_id/tasks/:id
  def update
    if @task.update(task_params)
      render json: TaskSerializer.new(@task).serializable_hash
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/:taskable_type/:taskable_id/tasks/:id
  def destroy
    @task.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotDestroyed => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_taskable
    if params[:project_id]
      @taskable = Project.find(params[:project_id])
    elsif params[:workflow_id]
      @taskable = Workflow.find(params[:workflow_id])
    else
      render json: { error: "Invalid taskable type" }, status: :unprocessable_entity
    end
  end

  def set_task
    @task = @taskable.tasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Task not found" }, status: :not_found
  end

  def task_params
    params.require(:task).permit(:name, :description, :due_date, :status)
  end
end