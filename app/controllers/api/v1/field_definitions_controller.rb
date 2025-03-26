class Api::V1::FieldDefinitionsController < Api::V1::BaseController
  before_action :set_field_definition, only: [:show, :update, :destroy]

  # GET /api/v1/field_definitions
  def index
    @field_definitions = FieldDefinition.all
    render json: FieldDefinitionSerializer.new(@field_definitions).serializable_hash
  end

  # GET /api/v1/field_definitions/:id
  def show
    render json: FieldDefinitionSerializer.new(@field_definition).serializable_hash
  end

  # POST /api/v1/field_definitions
  def create
    @field_definition = FieldDefinition.new(field_definition_params)
    if @field_definition.save
      render json: FieldDefinitionSerializer.new(@field_definition).serializable_hash, status: :created, location: [:api, :v1, @field_definition]
    else
      render json: { errors: @field_definition.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api/v1/field_definitions/:id
  def update
    if @field_definition.update(field_definition_params)
      render json: FieldDefinitionSerializer.new(@field_definition).serializable_hash
    else
      render json: { errors: @field_definition.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/field_definitions/:id
  def destroy
    @field_definition.destroy!
    head :no_content
  rescue ActiveRecord::RecordNotDestroyed => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def field_definition_params
    params.require(:field_definition).permit(:name, :field_type, :options, :required)
  end

  def set_field_definition
    @field_definition = FieldDefinition.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Field definition not found" }, status: :not_found
  end
end