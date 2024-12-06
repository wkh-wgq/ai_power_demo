#
# == 调用MaxKB服务的service
# 调用api提问的流程： 获取application_id -> 获取chat_id -> 聊天
#
class MaxkbService < ApplicationService
  # 发送提问消息
  def send_chat_message(message)
    url = "#{MAXKB_API_HOST}/api/application/chat_message/#{chat_id}"
    payload = {
      message: message,
      re_chat: false,
      stream: false
    }
    res = JSON.parse(RestClient::Request.execute(options.merge(method: :post, url: url, payload: payload)))
    raise res["message"] if res["code"] != 200
    # 根据id重新查询详情(因为需要展示知识来源)
    chat_record = query_chat_record(res["data"]["id"])
    # answer_text 回答的内容
    # dataset_list 所用的知识库
    # paragraph_list 引用的分段信息(包含分段内容，相似度等)
    chat_record.slice("answer_text", "dataset_list", "paragraph_list")
  end

  # 查询聊天记录详情
  def query_chat_record(chat_record_id)
    url = "#{MAXKB_API_HOST}/api/application/#{application_id}/chat/#{chat_id}/chat_record/#{chat_record_id}"
    res = JSON.parse(RestClient::Request.execute(options.merge(method: :get, url: url)))
    raise res["message"] if res["code"] != 200
    res["data"]
  end

  # 获取chat_id
  def chat_id
    @chat_id ||= begin
      url = "#{MAXKB_API_HOST}/api/application/#{application_id}/chat/open"
      res = JSON.parse(RestClient::Request.execute(options.merge(method: :get, url: url)))
      raise res["message"] if res["code"] != 200
      res["data"]
    end
  end

  # 获取application_id
  def application_id
    @application_id ||= begin
      # application_id没必要每次都获取，缓存起来
      CacheTool.load("maxkb.application_id") do
        url = "#{MAXKB_API_HOST}/api/application/profile"
        res = JSON.parse(RestClient::Request.execute(options.merge(method: :get, url: url)))
        raise res["message"] if res["code"] != 200
        res["data"]["id"]
      end
    end
  end

  def options
    @options ||= { verify_ssl: false, headers: headers }
  end

  def headers
    {
      "AUTHORIZATION" => MAXKB_API_KEY,
      "accept" => "application/json",
      "Content-Type" => "application/json"
    }
  end

  class << self
    def send_chat_message(message)
      self.new.send_chat_message(message)
    end
  end
end
