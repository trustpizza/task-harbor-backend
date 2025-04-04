class MigrateProjectWorkflowsData < ActiveRecord::Migration[7.1]
  def up
    # For each entry in the old join table
    if table_exists?(:projects_workflows)
      say_with_time "Migrating Project Workflows Data" do
        Project.find_each do |project|
          project.workflow_ids.each do |workflow_id|
            ProjectWorkflow.create!(project_id: project.id, workflow_id: workflow_id)
          end
        end
      end
    end
  end
  
end
