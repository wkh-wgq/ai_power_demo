class Record < ApplicationRecord
  after_create_commit :sync_generate_ai_answer
  # 当记录更新后，直接通过turbo_stream+action_cable更新页面，不需要重新加载页面
  after_update_commit -> { broadcast_replace_to self, partial: "records/#{self.type}/detail", locals: { record: self } }

  def sync_generate_ai_answer
    GenerateAiAnswerJob.perform_later(id)
  end

  # 调用ai服务生成回答
  def generate_ai_answer
    begin
      content = self.ai_recognition
      ai_answer = {
        success: true,
        content: content
      }
    rescue Exception => e
      ai_answer = {
        success: false,
        error_message: e.message
      }
    ensure
      self.ai_answer = ai_answer
      self.save!
    end
  end

  # 访问文件的url
  def file_url
    "#{FILE_CENTER_SERVICE_HOST}/file_records/#{file_id}"
  end

  class << self
    def find_sti_class(type)
      type = type.to_s.classify + "Record"
      super
    end

    def sti_name
      name = self.name.gsub("Record", "")
      name.underscore
    end
  end
end
