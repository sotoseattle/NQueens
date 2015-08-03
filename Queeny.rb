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

  def highest_probability_cell
    atlas = {}
    tb.cells.each_with_index { |x, i| atlas[ct.query(x, 'X')] = i }
    pick = (atlas.keys - [1.0]).max
    if pick != 0.0
      tb.cells[atlas[pick]]
    else
      nil
    end
  end

  def resolve
    ct.calibrate
    if cell = highest_probability_cell
      f = ct.nodes.find { |n| n.vars.include?(cell) }
      ct.observation(f, cell, [1.0, 0.0])
      resolve
    else
      print_solution
    end
  end

  def print_solution
      puts tb.cells.map { |x| ct.query(x, 'X') }
             .join.gsub('1.0', 'X').gsub('0.0', '_')
             .scan(/.{#{tb.n}}/).join("\n")
  end
end

class CliqueTree # monkey patch => reduce with Identity factor
  def observation(factotum, cell, valores)
    factotum.bag[:phi] * Factor.new(vars: [cell], vals: valores)
  end
end

q = Queeny.new(4)
q.resolve

# Basic factor. Given x and y, cells reacheable by queen:
#     x  y   p
#     -  -  --
#     1  1    0
#     1  0  1/3
#     0  1  1/3
#     0  0  1/3

