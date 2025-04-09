# app/controllers/api/v1/project_filters_controller.rb
class Api::V1::ProjectFiltersController < Api::V1::BaseController
  before_action :set_project_filter, only: [:show, :update, :destroy]

  # GET /api/v1/project_filters
  def index
    @project_filters = current_user.project_filters.order(:name)
    render json: ProjectFilterSerializer.new(@project_filters).serializable_hash
  end

  # GET /api/v1/project_filters/:id
  def show
    # @project_filter # Requires Pundit setup
    render json: ProjectFilterSerializer.new(@project_filter).serializable_hash
  end

  # POST /api/v1/project_filters
  def create
    @project_filter = current_user.project_filters.build(project_filter_params)
    # authorize @project_filter # Requires Pundit setup

    if @project_filter.save
      render json: ProjectFilterSerializer.new(@project_filter).serializable_hash, status: :created
    else
      render json: { errors: @project_filter.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/project_filters/:id
  def update
    # authorize @project_filter # Requires Pundit setup
    if @project_filter.update(project_filter_params)
      render json: ProjectFilterSerializer.new(@project_filter).serializable_hash
    else
      render json: { errors: @project_filter.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/project_filters/:id
  def destroy
    # authorize @project_filter # Requires Pundit setup
    @project_filter.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotDestroyed => e
     render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_project_filter
    @project_filter = ProjectFilter.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project Filter not found" }, status: :not_found
  end

  def project_filter_params
    # Be careful with permitting JSON. Ensure the structure is what you expect.
    # Using permit! is generally unsafe. Define the expected structure.
    params.require(:project_filter).permit(
      :name,
      criteria: [
        :logic,
        conditions: [:type, :attribute, :field_definition_id, :field_definition_name, :operator, :value]
      ]
    )
  end

  # Optional: Pundit Policy (Highly Recommended)
  # def authorize(record, query = nil)
  #   super([:api, :v1, record], query)
  # end
end
