# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

# Create some projects
Project.destroy_all

5.times do
  Project.create!(
    name: Faker::Name.name,
    description: Faker::Lorem.paragraph,
    due_date: Faker::Date.forward(days: rand(30..365)) # Generate a random number in the range
  )
end

projects = Project.all # Get all created projects

projects.each do |project|
  VALID_COLORS = ["base", "white", "lightGray", "darkGray", "pink", "rose", "green", "emerald", "teal", "blue", "sky", "indigo", "purple", "violet", "red", "orange", "yellow", "amber"]

  # Create some field definitions for each project
  3.times do
    field_type = %w[string integer date boolean].sample
    options = case field_type
              when "dropdown"
                Faker::Lorem.words(number: 3..5).to_json
              when "integer"
                { min: Faker::Number.between(from: 0, to: 10), max: Faker::Number.between(from: 11, to: 100) }.to_json
              else
                '[]'
              end

    field_definition = project.field_definitions.create!(
      name: Faker::Lorem.word,
      field_type: field_type,
      required: [true, false].sample,
      bgColor: VALID_COLORS.sample,
      options: options # Store options as JSON string
    )

    # Create some field values for each field definition
    rand(2..5).times do # Create between 2 and 5 values
      value = case field_definition.field_type
              when "integer"
                Faker::Number.between(from: 1, to: 100)
              when "date"
                Faker::Date.between(from: Time.zone.today, to: 1.year.from_now)
              when "boolean"
                [true, false].sample
              when "dropdown"
                 # Parse JSON to get array, then sample. Handles empty array.
                (JSON.parse(field_definition.options) rescue []).sample # Sample from options
              else # string or text
                Faker::Lorem.sentence
              end
      # debugger

      field_definition.field_values.create!(
        project: project, # Associate with the project
        value: value
      )
    end
  end
end
