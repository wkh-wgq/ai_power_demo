class GenerateAiAnswerJob < ApplicationJob
  queue_as :default

  def perform(record_id)
    record = Record.find record_id
    record.generate_ai_answer
  end
end
