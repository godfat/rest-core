
require 'rest-core/test'

describe RestCore::Facebook do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'get the next/prev page' do
    rg = RestCore::Facebook.new(:site => '', :cache => false)
    %w[next previous].each{ |type|
      kind = "#{type}_page"
      rg.send(kind, {})              .should.eq nil
      rg.send(kind, {'paging' => []}).should.eq nil
      rg.send(kind, {'paging' => {}}).should.eq nil

      stub_request(:get, 'zzz').to_return(:body => '["ok"]')
      rg.send(kind, {'paging' => {type => 'zzz'}}).should.eq ['ok']
    }
  end

  should 'merge all pages into one' do
    rg = RestCore::Facebook.new(:site => '', :cache => false)
    %w[next previous].each{ |type|
      kind = "#{type}_page"
      data = {'paging' => {type => 'zzz'}, 'data' => ['z']}

      # invalid pages or just the page itself
      (-1..1).each{ |page|
        rg.for_pages(data, page, {}, kind).should == data
      }

      (2..4).each{ |pages|
        # merge data
        stub_request(:get, 'zzz').to_return(:body => '{"data":["y"]}')
        rg.for_pages(data, pages, {}, kind).should.eq({'data' => %w[z y]})

        # this data cannot be merged
        stub_request(:get, 'zzz').to_return(:body => '{"data":"y"}')
        rg.for_pages(data, pages, {}, kind).should.eq({'data' => %w[z]})
      }

      stub_request(:get, 'zzz').to_return(:body =>
        '{"paging":{"'+type+'":"yyy"},"data":["y"]}')
      stub_request(:get, 'yyy').to_return(:body => '{"data":["x"]}')

      rg.for_pages(data, 3, {}, kind).should.eq({'data' => %w[z y x]})
    }
  end

  should 'for_pages with callback' do
    rg = RestCore::Facebook.new(:site => '', :cache => false)
    %w[next previous].each{ |type|
      kind = "#{type}_page"
      data = {'paging' => {type => 'zzz'}, 'data' => ['z']}

      # invalid pages or just the page itself
      nils = 0
      ranges = -1..1
      ranges.each{ |page|
        rg.for_pages(data, page, {}, kind){ |r|
          if r
            r.should.eq data
          else
            nils += 1
          end
        }.should.eq data
      }
      nils.should.eq ranges.to_a.size

      (2..4).each{ |pages|
        # merge data
        stub_request(:get, 'zzz').to_return(:body => '{"data":["y"]}')
        expects = [{'data' => %w[y]}, nil]
        rg.for_pages(data, pages, {}, kind){ |r|
          r.should.eq expects.shift
        }.should.eq({'data' => %w[z y]})
        expects.empty?.should.eq true

        # this data cannot be merged
        stub_request(:get, 'zzz').to_return(:body => '{"data":"y"}')
        expects = [{'data' => 'y'}, nil]
        rg.for_pages(data, pages, {}, kind){ |r|
          r.should.eq expects.shift
        }.should.eq({'data' => %w[z]})
        expects.empty?.should.eq true
      }

      stub_request(:get, 'zzz').to_return(:body =>
        '{"paging":{"'+type+'":"yyy"},"data":["y"]}')
      stub_request(:get, 'yyy').to_return(:body => '{"data":["x"]}')

      expects = [{'data' => %w[y]}, {'data' => %w[x]}, nil]
      rg.for_pages(data, 3, {}, kind){ |rr|
        if rr
          r = rr.dup
          r.delete('paging')
        else
          r = rr
        end
        r.should.eq expects.shift
      }.should.eq({'data' => %w[z y x]})
    }
  end
end
