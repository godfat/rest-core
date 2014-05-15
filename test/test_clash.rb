
require 'rest-core/test'

describe RC::Clash do
  should 'never give nil for non-existing values' do
    h = {0 => 1, 2 => {3 => 4, 5 => [6, {7 => 8}]}, 9 => false, 10 => nil}
    c = RC::Clash.new(h)
    c[0]            .should.eq(1)
    c[1]            .should.eq({})
    c[1][2]         .should.eq({})
    c[1][2][3]      .should.eq({})
    c[2]            .should.eq(3 => 4, 5 => [6, {7 => 8}])
    c[2][3]         .should.eq(4)
    c[2][4]         .should.eq({})
    c[2][4][5]      .should.eq({})
    c[2][5]         .should.eq([6, {7 => 8}])
    c[2][5][1]      .should.eq(7 => 8)
    c[2][5][1][7]   .should.eq(8)
    c[2][5][1][8]   .should.eq({})
    c[2][5][1][8][9].should.eq({})
    c[9]            .should.eq(false)
    c[10]           .should.eq(nil)
  end
end
