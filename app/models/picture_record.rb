# 图片类型的记录
class PictureRecord < Record
  validates_presence_of :file_id

  def ai_recognition
    QwenService.pictrue_recognition(file_url)
  end
end
