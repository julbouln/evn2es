require 'nova/record/req_contrib'
module Nova
  module Record
    class Cron
      include Req
      include Contrib

      has_few :news_govt, type: :govt, key: :news_govt, map: :govt_news_string, map_name: :news_str_id

      test_expressions :enable_on
      set_expressions :on_start, :on_end
    end
  end
end
