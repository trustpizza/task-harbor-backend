FactoryBot.define do
  factory :project_filter do
    belongs_to { :user }
    criteria do
      {
        "logic" => "AND",
        "conditions" => [
          { "type" => "attribute", "attribute" => "is_complete", "operator" => "eq", "value" => false }
        ]
      }
    end
    
  end
end
