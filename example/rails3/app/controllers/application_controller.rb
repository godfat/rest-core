
class ApplicationController < ActionController::Base
  protect_from_forgery

  include RestCore::Facebook::RailsUtil
  include RestCore::Flurry::RailsUtil

  before_filter :filter_common       , :only => [:index]
  before_filter :filter_canvas       , :only => [:canvas]
  before_filter :filter_options      , :only => [:options]
  before_filter :filter_no_auto      , :only => [:no_auto]
  before_filter :filter_diff_app_id  , :only => [:diff_app_id]
  before_filter :filter_diff_canvas  , :only => [:diff_canvas]
  before_filter :filter_iframe_canvas, :only => [:iframe_canvas]
  before_filter :filter_cache        , :only => [:cache]
  before_filter :filter_hanlder      , :only => [:handler_]
  before_filter :filter_session      , :only => [:session_]
  before_filter :filter_cookies      , :only => [:cookies_]

  def index
    render :text => rc_facebook.get('me').to_json
  end
  alias_method :canvas       , :index
  alias_method :options      , :index
  alias_method :diff_canvas  , :index
  alias_method :iframe_canvas, :index
  alias_method :handler_     , :index
  alias_method :session_     , :index
  alias_method :cookies_     , :index

  def no_auto
    rc_facebook.get('me')
  rescue RestCore::Facebook::Error
    render :text => 'XD'
  end

  def diff_app_id
    render :text => rc_facebook.app_id
  end

  def cache
    url = rc_facebook.url('cache')
    rc_facebook.get('cache')
    rc_facebook.get('cache')
    render :text => Rails.cache.read(Digest::MD5.hexdigest(url))
  end

  def error
    raise RestCore::Facebook::Error.new("don't rescue me")
  end

  def reinitialize
    cache_nil = rc_facebook.cache
    rc_facebook_setup(:cache => {'a' => 'b'})
    cache     = rc_facebook.cache
    render :text => YAML.dump([cache_nil, cache])
  end

  def helper; end

  private
  def filter_common
    rc_facebook_setup(:auto_authorize => true, :canvas => '')
  end

  def filter_canvas
    rc_facebook_setup(:canvas               => RestCore::Facebook.
                                                 default_canvas,
                      :auto_authorize_scope => 'publish_stream')
  end

  def filter_diff_canvas
    rc_facebook_setup(:canvas               => 'ToT',
                      :auto_authorize_scope => 'email')
  end

  def filter_iframe_canvas
    rc_facebook_setup(:canvas               => 'zzz',
                      :auto_authorize       => true)
  end

  def filter_no_auto
    rc_facebook_setup(:auto_authorize => false)
  end

  def filter_diff_app_id
    rc_facebook_setup(:app_id => 'zzz',
                      :auto_authorize => true)
  end

  def filter_options
    rc_facebook_setup(:auto_authorize_options => {:scope => 'bogus'},
                      :canvas => nil)
  end

  def filter_cache
    rc_facebook_setup(:cache => Rails.cache)
  end

  def filter_hanlder
    rc_facebook_setup(:write_handler => method(:write_handler),
                      :check_handler => method(:check_handler))
  end

  def write_handler fbs
    Rails.cache[:fbs] = fbs
  end

  def check_handler
    Rails.cache[:fbs]
  end

  def filter_session
    rc_facebook_setup(:write_session => true)
  end

  def filter_cookies
    rc_facebook_setup(:write_cookies => true)
  end
end
