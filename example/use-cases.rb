
require 'rest-core'
RC.eagerload

RC::Universal.pool_size = 0 # default to no thread pool

RC::Universal.module_eval do
  def default_query
    {:access_token => ENV['FACEBOOK_ACCESS_TOKEN']}
  end
end

def def_use_case name, &block
  singleton_class.send(:define_method, "#{name}_") do
    begin
      yield
    rescue => e
      q "Encountering: #{e}"
    end
  end
  singleton_class.send(:define_method, name) do
    @count ||= 0
    printf "Use case #%02d: %s\n", @count+=1, name
    puts '-' * 70
    start = Time.now
    send("#{name}_")
    puts "Spent #{Time.now - start} seconds for this use case."
    puts
  end
end

@mutex = Mutex.new

def q str
  @mutex.synchronize{ puts "\e[33m=> #{str.inspect}\e[0m" }
end

# ----------------------------------------------------------------------

def_use_case 'pure_ruby_single_request' do
  q RC::Universal.new(:json_response => true).
    get('https://graph.facebook.com/4')['name']
end

def_use_case 'pure_ruby_concurrent_requests' do
  client = RC::Universal.new(:json_response => true,
                             :site => 'https://graph.facebook.com/')
  q [client.get('4'), client.get('5')].map{ |u| u['name'] }
end

def_use_case 'pure_ruby_cache_requests' do
  client = RC::Universal.new(:json_response => true, :cache => {})
  3.times{ q client.get('https://graph.facebook.com/4')['name'] }
end

def_use_case 'pure_ruby_callback_requests' do
  RC::Universal.new(:json_response => true                                  ,
                    :site          => 'https://graph.facebook.com/'         ,
                    :log_method    => lambda{|str|
                      @mutex.synchronize{puts(str)}}).
    get('4'){ |res|
      if res.kind_of?(Exception)
        q "Encountering: #{res}"
        next
      end
      q res['name']
    }.
    get('5'){ |res|
      if res.kind_of?(Exception)
        q "Encountering: #{res}"
        next
      end
      q res['name']
    }.wait
end

def_use_case 'pure_ruby_nested_concurrent_requests' do
  c = RC::Universal.new(:json_response => true                              ,
                        :site          => 'https://graph.facebook.com/'     ,
                        :log_method => lambda{ |str|
                          @mutex.synchronize{puts(str)}})

  %w[4 5].each{ |user|
    c.get(user, :fields => 'cover'){ |data|
      if data.kind_of?(Exception)
        q "Encountering: #{data}"
        next
      end

      cover    = data['cover']
      comments = c.get("#{cover['id']}/comments")
      likes    = c.get("#{cover['id']}/likes")
      most_liked_comment = comments['data'].max_by{|d|d['like_count']}

      q "Author of most liked comment from #{user}'s cover photo:"
      q most_liked_comment['from']['name']

      y = !!likes['data'].find{|d|d['id'] == most_liked_comment['from']['id']}
      q "Did the user also like the cover?: #{y}"
    }
  }

  c.wait
end

# ----------------------------------------------------------------------

def_use_case 'pure_ruby' do
  pure_ruby_single_request
  pure_ruby_concurrent_requests
  pure_ruby_cache_requests
  pure_ruby_callback_requests
  pure_ruby_nested_concurrent_requests
end

# ----------------------------------------------------------------------

pure_ruby
