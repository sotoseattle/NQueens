require 'primo'
require './tablero'

class Cell < RandomVar
  def initialize(r, c)
    super(card: 2, name: "#{r}-#{c}", ass: %w(X O))
  end
end

class Queeny
  attr_accessor :tb, :ct

  def initialize(n)
    @tb = Tablero.new(n)
    @ct = CliqueTree.new(*fucktorize)
  end

  def fucktorize
    arr = []
    @tb.cells.each do |x|
      @tb.queen_cells(x.name).each do |y|
        if x!=y
          arr << Factor.new(vars: [y, x], vals: [0.0, 1.0, 1.0, 1.0])
        end
      end
    end
    arr
  end

  def resolve
    ct.calibrate

    probs = {}
    tb.cells.each { |e| probs[e] = ct.query(e, 'X') }
    anti_probs = probs.invert
    anti_probs.delete(1.0)
    pick = anti_probs.keys.max

    if pick != 0.0
      cell = anti_probs[pick]
      f = ct.nodes.find { |n| n.vars.include?(cell) }
      ct.observation(f, cell, [1.0, 0.0])
      resolve
    else
      puts probs.values.join.gsub('1.0', 'X').gsub('0.0', '_').scan(/.{#{tb.n}}/).join("\n")
    end
  end
end

class CliqueTree # monkey patching Clique Tree to reduce with Identity function
  def observation(factotum, cell, valores)
    factotum.bag[:phi] * Factor.new(vars: [cell], vals: valores)
  end
end

start = Time.now
  q = Queeny.new(4)
  q.resolve
puts "Time: #{Time.now - start}"

# Basic factor. Given x and y, cells reacheable by queen:
#     x  y   p
#     -  -  --
#     1  1    0
#     1  0  1/3
#     0  1  1/3
#     0  0  1/3

