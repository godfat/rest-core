
require 'rest-core/test'

describe RestCore::Facebook do
  after do
    WebMock.reset!
    RR.verify
  end

  describe 'log method' do
    should 'log whenever doing network request' do
      stub_request(:get, 'https://graph.facebook.com/me').
        to_return(:body => '{}')

      logger = []
      rg = RestCore::Facebook.new(:log_method => lambda{ |s| logger << [s] })
      rg.get('me')

      logger.size.should == 1
    end
  end

  describe 'with Graph API' do
    before do
      @id    = lambda{ |env| env }
      @error = '{"error":{"type":"Exception","message":"(#2500)"}}'
      @error_hash = RestCore::JsonDecode.json_decode(@error)

      stub_request(:get, 'https://graph.facebook.com/me').
        to_return(:body => @error)
    end

    should 'call error_handler if error occurred' do
      RestCore::Facebook.new(:error_handler => @id).get('me').
        should.eq @error_hash
    end

    should 'raise ::RestCore::Facebook::Error in default error_handler' do
      begin
        RestCore::Facebook.new.get('me')
      rescue ::RestCore::Facebook::Error => e
        e.error  .should == @error_hash
        e.message.should ==
          "#{@error_hash.inspect} from https://graph.facebook.com/me"
      end
    end
  end

  describe 'with FQL API' do
    # Example of an actual response (without newline)
    # {"error_code":603,"error_msg":"Unknown table: bad_table",
    #  "request_args":[{"key":"method","value":"fql.query"},
    #                  {"key":"format","value":"json"},
    #                  {"key":"query","value":
    #                     "SELECT name FROM bad_table WHERE uid=12345"}]}
    before do
      @id             = lambda{ |env| env }
      @fql_error      = '{"error_code":603,"error_msg":"Unknown table: bad"}'
      @fql_error_hash = RestCore::JsonDecode.json_decode(@fql_error)

      @bad_fql_query  = 'SELECT name FROM bad_table WHERE uid="12345"'
      bad_fql_request = "https://api.facebook.com/method/fql.query?" \
                        "format=json&query=#{CGI.escape(@bad_fql_query)}"

      stub_request(:get, bad_fql_request).to_return(:body => @fql_error)
    end

    should 'call error_handler if error occurred' do
      RestCore::Facebook.new(:error_handler => @id).fql(@bad_fql_query).
        should == @fql_error_hash
    end

    should 'raise ::RestCore::Facebook::Error in default error_handler' do
      begin
        RestCore::Facebook.new.fql(@bad_fql_query)
      rescue ::RestCore::Facebook::Error => e
        e.error  .should == @fql_error_hash
        e.message.should.start_with?(
          "#{@fql_error_hash.inspect} from "          \
          "https://api.facebook.com/method/fql.query?")
      end
    end
  end
end
