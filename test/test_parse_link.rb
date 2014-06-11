
require 'rest-core/test'

describe RC::ParseLink do
  describe 'http://tools.ietf.org/html/rfc5988' do
    should '5.5 a' do
      link = '<http://example.com/TheBook/chapter2>; rel="previous"; title="previous chapter"'
      RC::ParseLink.parse_link(link).should.eq(
        'previous' => {'uri' => 'http://example.com/TheBook/chapter2',
                       'rel' => 'previous',
                       'title' => 'previous chapter'})
    end

    should '5.5 b' do
      link = '</>; rel="http://example.net/foo"'
      RC::ParseLink.parse_link(link).should.eq(
        'http://example.net/foo' => {'uri' => '/',
                                     'rel' => 'http://example.net/foo'})
    end

    should '5.5 c (we did not implement * and unescape for now)' do
      link = <<-LINK
</TheBook/chapter2>; rel="previous"; title*=UTF-8'de'letztes%20Kapitel, </TheBook/chapter4>; rel="next"; title*=UTF-8'de'n%c3%a4chstes%20Kapitel
      LINK
      RC::ParseLink.parse_link(link).should.eq(
        'previous' => {'uri' => '/TheBook/chapter2',
                       'rel' => 'previous',
                       'title*' => "UTF-8'de'letztes%20Kapitel"},
        'next'     => {'uri' => '/TheBook/chapter4',
                       'rel' => 'next',
                       'title*' => "UTF-8'de'n%c3%a4chstes%20Kapitel"})
    end

    should '5.5 d' do
      link = '<http://example.org/>; rel="start http://example.net/relation/other"'

      RC::ParseLink.parse_link(link).should.eq(
        'start http://example.net/relation/other' =>
          {'uri' => 'http://example.org/',
           'rel' => 'start http://example.net/relation/other'})
    end
  end
end
