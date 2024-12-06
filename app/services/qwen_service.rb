class QwenService < ApplicationService
  class << self
    def pictrue_recognition(file_url)
      url = "#{PICTURE_RECOGNITION_SERVICE_HOST}/image_recognition"
      payload = {
        image_url: file_url,
        prompt: "描述一下这幅图"
      }
      res = JSON.parse(RestClient::Request.execute(
        method: :post,
        url: url,
        payload: payload.to_json,
        verify_ssl: false,
        headers: { "Content-Type" => "application/json" }
      ))
      { answer_text: res["message"][0] }
    end
  end
end
