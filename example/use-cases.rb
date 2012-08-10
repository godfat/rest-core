
require 'rest-core'
RC.eagerload

def def_use_case name, &block
  singleton_class.send(:define_method, "#{name}_", &block)
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

def q str, m=nil
  p = lambda{ puts "\e[33m=> #{str.inspect}\e[0m" }
  if m
    m.synchronize(&p)
  else
    p.call
  end
end

# ----------------------------------------------------------------------

def_use_case 'pure_ruby_single_request' do
  q RC::Universal.new(:json_response => true).
    get('https://api.github.com/users/godfat')['name']
end

def_use_case 'pure_ruby_concurrent_requests' do
  client = RC::Universal.new(:json_response => true,
                             :site => 'https://api.github.com/users/')
  q [client.get('godfat'), client.get('cardinalblue')].map{ |u| u['name'] }
end

def_use_case 'pure_ruby_cache_requests' do
  client = RC::Universal.new(:json_response => true, :cache => {})
  3.times{ q client.get('https://api.github.com/users/godfat')['name'] }
end

def_use_case 'pure_ruby_callback_requests' do
  m = Mutex.new
  RC::Universal.new(:json_response => true                                  ,
                    :site          => 'https://api.github.com/users/'       ,
                    :log_method    => lambda{|str| m.synchronize{puts(str)}}).
    get('godfat'){ |res|
      q res['name'], m
    }.
    get('cardinalblue'){ |res|
      q res['name'], m
    }.wait
end

def_use_case 'pure_ruby_nested_concurrent_requests' do
  m = Mutex.new
  c = RC::Universal.new(:json_response => true                              ,
                        :site          => 'https://api.github.com'          ,
                        :log_method => lambda{|str| m.synchronize{puts(str)}})

  %w[rubytaiwan godfat].each{ |user|
    c.get("/users/#{user}/repos", :per_page => 100){ |repos|
      rs = repos.reject{ |r| r['fork'] }
      most_watched = rs.max_by{ |r| r['watchers'] }['name']
      most_size    = rs.max_by{ |r| r['size']     }['name']

      watch_contri = c.get("/repos/#{user}/#{most_watched}/contributors")
       size_contri = c.get("/repos/#{user}/#{most_size}/contributors")

      most_watched_most_contri = watch_contri.max_by{ |c| c['contributions'] }
      most_size_most_contri    =  size_contri.max_by{ |c| c['contributions'] }

      q "Most contributed user for most watched: #{user}/#{most_watched}:", m
      q most_watched_most_contri['login'], m

      q "Most contributed user for most size   : #{user}/#{most_size}:", m
      q most_size_most_contri['login'], m
    }
  }

  c.wait
end

# ----------------------------------------------------------------------

def_use_case 'eventmachine_fiber_single_request'             do
  EM.run{ Fiber.new{ pure_ruby_single_request_            ; EM.stop }.resume }
end

def_use_case 'eventmachine_fiber_concurrent_requests'        do
  EM.run{ Fiber.new{ pure_ruby_concurrent_requests_       ; EM.stop }.resume }
end

def_use_case 'eventmachine_fiber_cache_requests'             do
  EM.run{ Fiber.new{ pure_ruby_cache_requests_            ; EM.stop }.resume }
end

def_use_case 'eventmachine_fiber_callback_requests'          do
  EM.run{ Fiber.new{ pure_ruby_callback_requests_         ; EM.stop }.resume }
end

def_use_case 'eventmachine_fiber_nested_concurrent_requests' do
  EM.run{ Fiber.new{ pure_ruby_nested_concurrent_requests_; EM.stop }.resume }
end

# ----------------------------------------------------------------------

def_use_case 'eventmachine_thread_single_request'             do
  EM.run{ Thread.new{ pure_ruby_single_request_            ; EM.stop } }
end

def_use_case 'eventmachine_thread_concurrent_requests'        do
  EM.run{ Thread.new{ pure_ruby_concurrent_requests_       ; EM.stop } }
end

def_use_case 'eventmachine_thread_cache_requests'             do
  EM.run{ Thread.new{ pure_ruby_cache_requests_            ; EM.stop } }
end

def_use_case 'eventmachine_thread_callback_requests'          do
  EM.run{ Thread.new{ pure_ruby_callback_requests_         ; EM.stop } }
end

def_use_case 'eventmachine_thread_nested_concurrent_requests' do
  EM.run{ Thread.new{ pure_ruby_nested_concurrent_requests_; EM.stop } }
end

# ----------------------------------------------------------------------

pure_ruby_single_request
pure_ruby_concurrent_requests
pure_ruby_cache_requests
pure_ruby_callback_requests
pure_ruby_nested_concurrent_requests

eventmachine_fiber_single_request
eventmachine_fiber_concurrent_requests
eventmachine_fiber_cache_requests
eventmachine_fiber_callback_requests
# eventmachine_fiber_nested_concurrent_requests

eventmachine_thread_single_request
eventmachine_thread_concurrent_requests
eventmachine_thread_cache_requests
eventmachine_thread_callback_requests
# eventmachine_thread_nested_concurrent_requests
