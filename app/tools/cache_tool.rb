class CacheTool
  class << self
    def load(key, expires_in = 30.minutes)
      value = Rails.cache.read(key)
      return value if value.present?
      yield.tap do |value|
        Rails.logger.info "set cache for key(#{key})"
        Rails.cache.write(key, value, expires_in: expires_in)
      end
    end
  end
end
