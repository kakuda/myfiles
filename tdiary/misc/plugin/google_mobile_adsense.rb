require 'net/http'
Net::HTTP.version_1_2

def google_mobile_adsense

  env_http_host = (ENV["HTTP_HOST"]!=nil) ? ENV["HTTP_HOST"] : ""
  env_remote_addr = (ENV["REMOTE_ADDR"]!=nil) ? ENV["REMOTE_ADDR"] : ""
  env_http_referer = (ENV["HTTP_REFERER"]!=nil) ? ENV["HTTP_REFERER"] : ""
  env_request_uri = (ENV["REQUEST_URI"]!=nil) ? ENV["REQUEST_URI"] : ""
  env_user_agent = (ENV["HTTP_USER_AGENT"]!=nil) ? ENV["HTTP_USER_AGENT"] : ""

  google_dt = sprintf "%.0f", 1000.0 * Time.now.to_f
  google_scheme = ENV["HTTPS"] == "on" ? "https://" : "http://"
  google_host = URI.escape( google_scheme + env_http_host )

  #google_ad_url = "http://pagead2.googlesyndication.com/pagead/ads?" +
  google_ad_url = "/pagead/ads?" +
    "ad_type=text" +
    "&channel=" +
    "&client=pub-3118769276911237" +
    "&dt=" + google_dt +
    "&format=mobile_single" +
    "&host=" + google_host +
    "&ip=" + URI.escape(env_remote_addr) +
    "&markup=xhtml" +
    "&oe=sjis" +
    "&output=xhtml" +
    "&ref=" + URI.escape( env_http_referer ) +
    "&url=" + google_host + URI.escape( env_request_uri ) +
    "&useragent=" + URI.escape(env_user_agent)

  adsense = ""
  Net::HTTP.start('pagead2.googlesyndication.com', 80) do |http|
    response = http.get(google_ad_url)
    adsense = response.body
  end

  adsense
end
