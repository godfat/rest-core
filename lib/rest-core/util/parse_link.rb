
module RestCore
  module ParseLink
    module_function
    # http://tools.ietf.org/html/rfc5988
    parname = '"?([^"]+)"?'
    LINKPARAM = /#{parname}=#{parname}/
    def parse_link link
      link.split(',').inject({}) do |r, value|
        uri, *pairs = value.split(';')
        params = Hash[pairs.map{ |p| p.strip.match(LINKPARAM)[1..2] }]
        r[params['rel']] = params.merge('uri' => uri[/<([^>]+)>/, 1])
        r
      end
    end
  end
end
