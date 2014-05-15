
require 'rest-core/test'

describe RC::Clash do
  should 'never give nil for non-existing values' do
    h = {0 => 1, 2 => {3 => 4, 5 => [6]}, 7 => false, 8 => nil}
    c = RC::Clash.new(h)
    c[0]      .should.eq(1)
    c[1]      .should.eq({})
    c[1][2]   .should.eq({})
    c[1][2][3].should.eq({})
    c[2]      .should.eq(3 => 4, 5 => [6])
    c[2][3]   .should.eq(4)
    c[2][4]   .should.eq({})
    c[2][4][5].should.eq({})
    c[2][5]   .should.eq([6])
    c[7]      .should.eq(false)
    c[8]      .should.eq(nil)
  end
end
