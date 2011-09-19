
require 'rest-core/test'

require 'time'

describe RestCore::Flurry do
  after do
    WebMock.reset!
    RR.verify
  end

  before do
    startDate = '2011-08-23'
    endDate   = '2011-09-19'
    @flurry = RestCore::Flurry.new
    stub(Time).now{ Time.parse(endDate, nil) }
    stub_request(:get,
      "http://api.flurry.com/appMetrics/ActiveUsers?" \
      "startDate=#{startDate}&endDate=#{endDate}").
      to_return(:body =>
        '{"@startDate":"2011-08-23",
          "@metric":"ActiveUsersByDay",
          "@endDate":"2011-09-19",
          "@version":"1.0",
          "@generatedDate":"9/19/11 5:54 AM",
          "day":
            [{"@value":"34722","@date":"2011-08-23"},
             {"@value":"33560","@date":"2011-08-24"},
             {"@value":"34392","@date":"2011-08-25"},
             {"@value":"37737","@date":"2011-08-26"},
             {"@value":"41332","@date":"2011-08-27"},
             {"@value":"40456","@date":"2011-08-28"},
             {"@value":"34950","@date":"2011-08-29"},
             {"@value":"34076","@date":"2011-08-30"},
             {"@value":"32096","@date":"2011-08-31"},
             {"@value":"31558","@date":"2011-09-01"},
             {"@value":"33467","@date":"2011-09-02"},
             {"@value":"39306","@date":"2011-09-03"},
             {"@value":"40233","@date":"2011-09-04"},
             {"@value":"37777","@date":"2011-09-05"},
             {"@value":"35829","@date":"2011-09-06"},
             {"@value":"35960","@date":"2011-09-07"},
             {"@value":"34871","@date":"2011-09-08"},
             {"@value":"36683","@date":"2011-09-09"},
             {"@value":"44077","@date":"2011-09-10"},
             {"@value":"45057","@date":"2011-09-11"},
             {"@value":"37750","@date":"2011-09-12"},
             {"@value":"35223","@date":"2011-09-13"},
             {"@value":"34918","@date":"2011-09-14"},
             {"@value":"37587","@date":"2011-09-15"},
             {"@value":"40972","@date":"2011-09-16"},
             {"@value":"45412","@date":"2011-09-17"},
             {"@value":"43920","@date":"2011-09-18"},
             {"@value":"6516","@date":"2011-09-19"}]}')

    @active_users =
      [["2011-09-19",  6516], ["2011-09-18", 43920], ["2011-09-17", 45412],
       ["2011-09-16", 40972], ["2011-09-15", 37587], ["2011-09-14", 34918],
       ["2011-09-13", 35223], ["2011-09-12", 37750], ["2011-09-11", 45057],
       ["2011-09-10", 44077], ["2011-09-09", 36683], ["2011-09-08", 34871],
       ["2011-09-07", 35960], ["2011-09-06", 35829], ["2011-09-05", 37777],
       ["2011-09-04", 40233], ["2011-09-03", 39306], ["2011-09-02", 33467],
       ["2011-09-01", 31558], ["2011-08-31", 32096], ["2011-08-30", 34076],
       ["2011-08-29", 34950], ["2011-08-28", 40456], ["2011-08-27", 41332],
       ["2011-08-26", 37737], ["2011-08-25", 34392], ["2011-08-24", 33560],
       ["2011-08-23", 34722]]

    @weekly = [244548, 270227, 248513, 257149]
  end

  should 'metrics("ActiveUsers")' do
    @flurry.metrics('ActiveUsers', {}, :weeks => 4).should.eq @active_users

  end

  should 'weekly(metrics("ActiveUsers"))' do
    @flurry.weekly(@active_users).should.eq @weekly
  end

  should 'sum(weekly(metrics("ActiveUsers")))' do
    @flurry.sum(@weekly).should.eq [1020437, 775889, 505662, 257149]
  end
end
