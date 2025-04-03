# db/seeds.rb

require 'faker'

# Destroy existing records to ensure idempotency
puts "Destroying existing data..."
Workflow.destroy_all
Task.destroy_all
Project.destroy_all
FieldDefinition.destroy_all
Field.destroy_all
FieldValue.destroy_all

# User.destroy_all
# Organization.destroy_all

puts "Data destroyed."

# --- Helper Methods ---

def generate_value(val_type, options = nil)
  case val_type
  when "integer"
    min = options.is_a?(Hash) && options["min"] ? options["min"] : 0
    max = options.is_a?(Hash) && options["max"] ? options["max"] : 1000
    rand(min..max)
  when "date"
    two_years_ago = 2.years.ago.to_date
    Faker::Date.between(from: two_years_ago, to: Date.today)
  when "boolean"
    [true, false].sample.to_s
  when "string"
    Faker::Lorem.word
  else
    nil
  end
end

puts "Creating Organization..."
# Create a single Organization

organization = Organization.first_or_create(
  name: Faker::Company.name
)

puts "Creating User..."
user = organization.users.first_or_create!(
  first_name: "Axel",
  last_name: "Olsson",
  email: "test@email.com",
  password: "123456",
  password_confirmation: "123456"
)


puts "Creating Field Definitions..."
# Create Field Definitions
field_definitions = []
[
  # { name: "Priority", field_type: "dropdown", options: ["High", "Medium", "Low"].to_json, required: true },
  # { name: "Status", field_type: "dropdown", options: ["To Do", "In Progress", "Completed"].to_json, required: true },
  { name: "Estimated Time (hours)", field_type: "integer", options: { min: 1, max: 100 }.to_json, required: false },
  { name: "Start Date", field_type: "date", required: true },
  { name: "Is Blocked", field_type: "boolean", required: false },
  { name: "Notes", field_type: "string", required: false },
].each do |field_data|
  field_definitions << FieldDefinition.create!(field_data)
end

puts "Creating Projects..."
# Create Projects
5.times do
  project = Project.create!(
    name: Faker::App.name,
    description: Faker::Lorem.paragraph,
    due_date: Faker::Date.forward(days: 30),
    organization: organization,
    project_manager: user
  )

  puts "Creating Workflows for Project: #{project.name}"
  # Create Workflows
  workflows = []
  2.times do
    workflow = Workflow.create!(
      organization: organization,
      name: Faker::Job.title,
      description: Faker::Lorem.sentence
    )
    workflows << workflow

    3.times do
      task = Task.create!(
        name: Faker::Job.field,
        description: Faker::Lorem.paragraph,
        due_date: Faker::Date.forward(days: 15),
        taskable:  workflow # Associate the task with the project
      )
  
      # Create Fields and FieldValues for each Task
      field_definitions.each do |field_definition|
        field = Field.create!(
          field_definition: field_definition,
          fieldable: task
        )
  
        # Create FieldValues through the association
        value = generate_value(field_definition.field_type, field_definition.options)
        field.create_field_value!(value: value) # Use create_field_value!
      end
    end
  
    # Create Fields and FieldValues for each Project
    field_definitions.each do |field_definition|
      field = Field.create!(
        field_definition: field_definition,
        fieldable: workflow
      )
  
      # Create FieldValues through the association
      value = generate_value(field_definition.field_type, field_definition.options)
      field.create_field_value!(value: value) # Use create_field_value!
    end
  end

  

  puts "Creating Tasks for Project: #{project.name}"
  # Create Tasks
  5.times do
    task = Task.create!(
      name: Faker::Job.field,
      description: Faker::Lorem.paragraph,
      due_date: Faker::Date.forward(days: 15),
      taskable: project # Associate the task with the project
    )

    # Create Fields and FieldValues for each Task
    field_definitions.each do |field_definition|
      field = Field.create!(
        field_definition: field_definition,
        fieldable: task
      )

      # Create FieldValues through the association
      value = generate_value(field_definition.field_type, field_definition.options)
      field.create_field_value!(value: value) # Use create_field_value!
    end
  end

  # Create Fields and FieldValues for each Project
  field_definitions.each do |field_definition|
    field = Field.create!(
      field_definition: field_definition,
      fieldable: project
    )

    # Create FieldValues through the association
    value = generate_value(field_definition.field_type, field_definition.options)
    field.create_field_value!(value: value) # Use create_field_value!
  end

end

puts "Seed data created successfully!"