# 文本类型的记录
class TextRecord < Record
  validates_presence_of :description

  def ai_recognition
    MaxkbService.send_chat_message(description)
  end
end
