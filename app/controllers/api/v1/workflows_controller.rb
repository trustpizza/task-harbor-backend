class Api::V1::WorkflowsController < Api::V1::BaseController
  before_action :set_organization
  before_action :set_workflow, only: [:show, :update, :destroy]

  # GET /api/v1/workflows
  def index
    @workflows = @organization.workflows
    render json: WorkflowSerializer.new(@workflows).serializable_hash
  end

  # GET /api/v1/workflows/:id
  def show
    render json: WorkflowSerializer.new(@workflow, include: [:tasks]).serializable_hash
  end

  # POST /api/v1/workflows
  def create
    @workflow = @organization.workflows.new(workflow_params)
    if @workflow.save
      render json: WorkflowSerializer.new(@workflow).serializable_hash, status: :created
    else
      render json: { errors: @workflow.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/workflows/:id
  def update
    if @workflow.update(workflow_params)
      render json: WorkflowSerializer.new(@workflow).serializable_hash
    else
      render json: { errors: @workflow.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/workflows/:id
  def destroy
    @workflow.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotDestroyed => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_workflow
    @workflow = @organization.workflows.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Workflow not found" }, status: :not_found
  end

  def set_organization
    @organization = current_user.organization
  end

  def workflow_params
    params.require(:workflow).permit(:name, :description)
  end
end
