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

    # row constraints
    (1..tb.n).each { |i| arr << fucktor(tb.row(i)) }

    # col constraints
    (1..tb.n).each { |i| arr << fucktor(tb.col(i)) }

    # diag 1 constraints
    (1..tb.n).each do |i|
      kk = tb.oppos_grow(1, i).map{|s| tb.sqr(s).first}
      arr << fucktor(kk) unless kk.size==1
    end

    # diag 2 constraints
    (2..tb.n).each do |i|
      kk = tb.oppos_grow(i, tb.n).map {|s| tb.sqr(s).first }
      arr << fucktor(kk) unless kk.size==1
    end

    # diag 3 constraints
    (1..tb.n).each do |i|
      kk = tb.equal_grow(1, i).map {|s| tb.sqr(s).first }
      arr << fucktor(kk) unless kk.size==1
    end

    # diag 4 constraints
    (1..(tb.n-1)).each do |i|
      kk = tb.equal_grow((i+1), 1).map {|s| tb.sqr(s).first }
      arr << fucktor(kk) unless kk.size==1
    end
    arr
  end

  def fucktor(vars)
    vars = vars.rotate
    n = vars.size - 1
    vals = nesting_loops(n).map(&:flatten)
                           .map {|e| e.reduce(:+) > 1 ? 0.0 : 1.0}
    Factor.new( vars: vars, vals: vals)
  end

  def nesting_loops(n)
    if n==0
      return [1, 0]
    else
      [1, 0].product(nesting_loops(n-1))
    end
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
    printout
    if cell = highest_probability_cell
      f = ct.nodes.find { |n| n.vars.include?(cell) }
      ct.observation(f, cell, [1.0, 0.0])
      resolve
    end
  end

  def printout
      puts tb.cells.map { |x| ct.query(x, 'X') }
             .map { |x| x==1.0 ? 'X' : (x==0.0 ? '_' : '?') }.join
             .scan(/.{#{tb.n}}/).join("\n") + "\n\n"
  end
end

class CliqueTree # monkey patch => reduce with Identity factor
  def observation(factotum, cell, valores)
    factotum.bag[:phi] * Factor.new(vars: [cell], vals: valores)
  end
end

q = Queeny.new(5)
q.resolve


# a, b, c = q.tb.cells.first(3)
# ff = q.fucktor([a, b, c])
# p ff.vals.flatten

# Basic factor. Given x and y, cells reacheable by queen:
#     x  y   p
#     -  -  --
#     1  1    0
#     1  0  1/3
#     0  1  1/3
#     0  0  1/3

