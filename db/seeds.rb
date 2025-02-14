# db/seeds.rb

require 'faker'

# Destroy existing records to ensure idempotency
Project.destroy_all
FieldDefinition.destroy_all
Field.destroy_all
FieldValue.destroy_all

VALUE_COUNT_CHOICES = (7..12).to_a


def generate_value(val_type)
  case val_type
  when "integer"
    [0..1000].sample
  when "date"
    two_years_ago = 2.years.ago.to_date
    Faker::Date.between(from: two_years_ago, to: Date.today)
  when "boolean"
    [true, false].sample
  when "string"
    Faker::Name.name
  end
end

["string", "integer", "date", "boolean"].each do |field_type|
  FieldDefinition.create(name: Faker::Name.name, field_type: field_type, required: [true, false].sample)
end

(3..5).to_a.sample.times do
# 5.times do
  project = Project.create(name: Faker::Name.name, description: Faker::Lorem.paragraph, due_date: Faker::Date.forward(days:20))

  FieldDefinition.all.each do |field_def|
    field = project.fields.create(field_definition: field_def)

    VALUE_COUNT_CHOICES.sample.times do 
      value = generate_value(field_def.field_type)
      field.field_values.create(value: value)
    end
  end

end
