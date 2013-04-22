class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  public
  #Hacked in from https://github.com/brendanlim/mobile-fu
  MOBILE_USER_AGENTS ='palm|blackberry|nokia|phone|midp|mobi|symbian|chtml|ericsson|minimo|' +
                      'audiovox|motorola|samsung|telit|upg1|windows ce|ucweb|astel|plucker|' +
                      'x320|x240|j2me|sgh|portable|sprint|docomo|kddi|softbank|android|mmp|' +
                      'pdxgw|netfront|xiino|vodafone|portalmmm|sagem|mot-|sie-|ipod|up\\.b|' +
                      'webos|amoi|novarra|cdm|alcatel|pocket|ipad|iphone|mobileexplorer|' +
                      'mobile'

  helper_method :is_mobile_device?

  def is_mobile_device?
    request.user_agent.to_s.downcase =~ Regexp.new(MOBILE_USER_AGENTS)
  end
end
