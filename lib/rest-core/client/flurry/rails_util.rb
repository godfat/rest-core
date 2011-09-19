
require 'rest-core/util/rails_util_util'

module RestCore::Flurry::DefaultAttributes
  def defalut_log_method ; Rails.logger.method(:debug); end
  def default_cache      ; Rails.cache                ; end
  def default_api_key    ; nil                        ; end
  def default_access_code; nil                        ; end
end

module RestCore::Flurry::RailsUtil
  def self.init app=Rails
    RestCore::Config.load_for_rails(RestCore::Flurry, 'flurry', app)
  end

  module Helper
    def rc_flurry
      controller.send(:rc_flurry)
    end
  end

  def self.included controller
    # skip if included already, any better way to detect this?
    return if controller.respond_to?(:rc_flurry, true)

    controller.helper(RestCore::Flurry::RailsUtil::Helper)
    controller.instance_methods.select{ |method|
      method.to_s =~ /^rc_flurry/
    }.each{ |method| controller.send(:protected, method) }
  end

  def rc_flurry_setup options={}
    rc_flurry_options_ctl.merge!(
      RestCore::RailsUtilUtil.extract_options(
        RestCore::Flurry.members, options, :reject))
    rc_flurry_options_new.merge!(
      RestCore::RailsUtilUtil.extract_options(
        RestCore::Flurry.members, options, :select))

    # we'll need to reinitialize rc_flurry with the new options,
    # otherwise if you're calling rc_flurry before rc_flurry_setup,
    # you'll end up with default options without the ones you've passed
    # into rc_flurry_setup.
    rc_flurry.send(:initialize, rc_flurry_options_new)

    true # keep going
  end

  def rc_flurry
    @rc_flurry ||= RestCore::Flurry.new(rc_flurry_options_new)
  end

  module_function

  # ==================== begin options utility =======================
  def rc_flurry_oget key
    if rc_flurry_options_ctl.has_key?(key)
      rc_flurry_options_ctl[key]
    else
      RestCore::Flurry.send("default_#{key}")
    end
  end

  def rc_flurry_options_ctl
    @rc_flurry_options_ctl ||= {}
  end

  def rc_flurry_options_new
    @rc_flurry_options_new ||= {}
  end
  # ==================== end options utility =======================
end

RestCore::Flurry::RailsUtil.init(Rails)
