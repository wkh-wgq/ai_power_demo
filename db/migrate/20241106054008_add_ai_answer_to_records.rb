class AddAiAnswerToRecords < ActiveRecord::Migration[7.2]
  def change
    add_column :records, :ai_answer, :json
  end
end
