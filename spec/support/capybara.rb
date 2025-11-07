Capybara.register_driver :remote_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--no-sandbox')
  options.add_argument('--headless')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1680,1050')

  Capybara::Selenium::Driver.new(app, browser: :remote, url: ENV["SELENIUM_DRIVER_URL"], capabilities: options)
end

# CI環境用のheadless Chromeドライバー
Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1680,1050')
  options.add_argument('--disable-infobars')
  options.add_argument('--disable-extensions')

  # selenium-webdriver 4.6以降では、ChromeDriverを自動的に管理する機能が組み込まれている
  # Service.chromeを使うと、自動的にChromeDriverをダウンロード・管理してくれる
  # CI環境でも自動的に適切なChromeDriverが使用される
  service = Selenium::WebDriver::Service.chrome
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, service: service)
end
