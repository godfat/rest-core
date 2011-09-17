
require 'rest-core'

require 'time' # for Time.parse

RestCore::Flurry = RestCore::Builder.client(:api_key, :access_code) do
  s = self.class # this is only for ruby 1.8!

  use s::DefaultSite   , 'http://api.flurry.com/'
  use s::DefaultHeaders, {'Accept' => 'application/json'}
  use s::DefaultQuery  , {}

  use s::CommonLogger  , nil
  use s::Cache         , {}, 3600 do
    use s::ErrorHandler, lambda{|env| raise env[s::RESPONSE_BODY]['message']}
    use s::ErrorDetectorHttp
    use s::JsonDecode  , true
  end

  run s::RestClient
end

module RestCore::Flurry::Client
  # see: http://wiki.flurry.com/index.php?title=AppInfo
  # >> f.app_info
  # => {"@platform"=>"iPhone", "@name"=>"PicCollage",
  #     "@createdDate"=>"2011-07-24", "@category"=>"Photography",
  #     "@version"=>"1.0", "@generatedDate"=>"9/15/11 7:08 AM",
  #     "version"=>[{"@name"=>"2.1", ...
  def app_info query={}
    get('appInfo/getApplication', query)
  end

  # see: http://wiki.flurry.com/index.php?title=EventMetrics
  # >> f.event_matrics(:startDate => '2011-09-14', :endDate => '2011-09-15')
  # => {"@type"=>"Summary", "@startDate"=>"2011-09-14",
  #     "@endDate"=>"2011-09-15", "@version"=>"1.0",
  #     "@generatedDate"=>"9/15/117:08 AM",
  #     "event"=>[{"@usersLastWeek"=>"164", "@usersLastMonth"=>"642", ...
  def event_metrics query={}
    get('eventMetrics/Summary', query)
  end

  # see: http://wiki.flurry.com/index.php?title=AppMetrics
  # >> f.metrics('ActiveUsers', {}, :weeks => 4)
  # => [["2011-09-16", 7929], ["2011-09-15", 36453], ["2011-09-14", 34026],
  #     ["2011-09-13", 34245], ["2011-09-12", 36879], ["2011-09-11", 44101],
  #     ["2011-09-10", 43362], ["2011-09-09", 36442], ...
  def metrics path, query={}, opts={}
    if weeks = opts.delete(:weeks)
      query[:startDate] =
        (Time.now + 86400 - 86400*7*weeks).strftime('%Y-%m-%d')
    end

    query[:endDate] ||= Time.now.strftime('%Y-%m-%d')

    get("appMetrics/#{path}", query, opts)['day'].
      map{ |i| [i['@date'], i['@value'].to_i] }.reverse
  end

  # >> f.weekly(f.metrics('ActiveUsers', {}, :weeks => 4))
  # => [258213, 247935, 260418, 236995]
  def weekly array
    start = Time.parse(array.last.first).to_i
    array.group_by{ |(date, value)|
      current = Time.parse(date).to_i
      (current - start) / (86400*7)
    # calling .last to discard week numbers created by group_by
    }.sort.map(&:last).map{ |week|
      week.map{ |(date, num)| num }.inject(&:+) }
  end

  # >> f.sum(f.weekly(f.metrics('ActiveUsers', {}, :weeks => 4)))
  # => [258213, 495870, 768771, 982343]
  def sum array
    array.map.with_index{ |num, index|
      num + array[1, index].inject(0, &:+)
    }
  end

  def query
    {'apiKey'        => api_key    ,
     'apiAccessCode' => access_code}
  end
end

RestCore::Flurry.send(:include, RestCore::Flurry::Client)
require 'rest-core/client/flurry/rails_util' if
  Object.const_defined?(:Rails)
