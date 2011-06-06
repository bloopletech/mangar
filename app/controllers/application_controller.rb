class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  before_filter :ensure_mangar_setup

  private
  def ensure_mangar_setup
    redirect_to collections_path if Mangar.dir.nil?
  end
  
  
  #HACK to fix params encoding https://rails.lighthouseapp.com/projects/8994/tickets/4336
  private
  before_filter :force_utf8_params

  def force_utf8_params
    traverse = lambda do |object, block|
      if object.kind_of?(Hash)
        object.each_value { |o| traverse.call(o, block) }
      elsif object.kind_of?(Array)
        object.each { |o| traverse.call(o, block) }
      else
        block.call(object)
      end
      object
    end
    force_encoding = lambda do |o|
      o.force_encoding(Encoding::UTF_8) if o.respond_to?(:force_encoding)
    end
    traverse.call(params, force_encoding)
  end

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
