# RspecでFactoryBotのメソッドを使用する際に、モジュール名を省略するための設定
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods 
end 