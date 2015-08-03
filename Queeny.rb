require 'primo'
require './tablero'

class Queeny
  attr_accessor :tb, :fs, :ct

  def initialize(n)
    @tb = Tablero.new(n)
    @fs = fucktorize
    @ct = CliqueTree.new(*fs)
  end

  def fucktorize
    fis = []
    @tb.board.each do |x|
      @tb.queen_cells(x.name).each do |y|
        if x!=y
          fis << Factor.new(vars: [y, x], vals: [0.0, 1.0, 1.0, 1.0])
        end
      end
    end
    fis
  end

  def resolve
    ct.calibrate
    # @tb.board.each { |e| puts "#{e}: #{ct.query(e, 'X')}" }
    # puts "_"*40

    probs = {}
    tb.board.each { |e| probs[e] = ct.query(e, 'X') }
    anti_probs = probs.invert
    anti_probs.delete(1.0)
    pick = anti_probs.keys.max

    if pick != 0.0
      cell = anti_probs[pick]
      f = ct.nodes.find { |n| n.vars.include?(cell) }
      f.bag[:phi] * Factor.new(vars: [cell], vals: [1.0, 0.0])
      resolve
    else
      puts probs.values.join.gsub('1.0', 'X').gsub('0.0', '_').scan(/.{#{tb.n}}/).join("\n")
    end
  end
end

q = Queeny.new(5)
# p q.fs.size
q.resolve
# p q.ct.nodes.size

# Basic factor. Given x and y, cells reacheable by queen:
#     x  y   p
#     -  -  --
#     1  1    0
#     1  0  1/3
#     0  1  1/3
#     0  0  1/3

