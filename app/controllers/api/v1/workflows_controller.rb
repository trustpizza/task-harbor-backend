class Api::V1::WorkflowsController < Api::V1::BaseController
  before_action :set_project
  before_action :set_workflow, only: [:show, :update, :destroy]

  # GET /api/v1/projects/:project_id/workflows
  def index
    @workflows = @project.workflows
    render json: WorkflowSerializer.new(@workflows).serializable_hash
  end

  # GET /api/v1/projects/:project_id/workflows/:id
  def show
    render json: WorkflowSerializer.new(@workflow, include: [:tasks]).serializable_hash
  end

  # POST /api/v1/projects/:project_id/workflows
  def create
    @workflow = @project.workflows.new(workflow_params)
    if @workflow.save
      render json: WorkflowSerializer.new(@workflow).serializable_hash, status: :created
    else
      render json: { errors: @workflow.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/projects/:project_id/workflows/:id
  def update
    if @workflow.update(workflow_params)
      render json: WorkflowSerializer.new(@workflow).serializable_hash
    else
      render json: { errors: @workflow.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/projects/:project_id/workflows/:id
  def destroy
    @workflow.destroy!
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

  def set_workflow
    @workflow = @project.workflows.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Workflow not found" }, status: :not_found
  end

  def workflow_params
    params.require(:workflow).permit(:name, :description)
  end
end
