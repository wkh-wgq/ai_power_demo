# 音频类型的记录
class AudioRecord < Record
  validates_presence_of :file_id, :description

  def ai_recognition
    MaxkbService.send_chat_message(description)
  end
end
