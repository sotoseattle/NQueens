require 'primo'
require './tablero'

class NQueens
  attr_accessor :n, :t, :factors, :clique_tree

  def initialize(n)
    @t = Tablero.new(n)
    @factors = []
    fucktorize(t.board)
    @clique_tree = CliqueTree.new(*factors)
    p @clique_tree.nodes.size
  end

  def fucktorize(rest)
    # t.diag_equal_grow(1,1).map{|x| @factors << fucktor(t.diag_oppos_grow(x))}
    # t.diag_equal_grow(1,1).map{|x| @factors << fucktor(t.queen_cells(x))}
    t.board.map{|x| @factors << fucktor(t.tower_cells(x.name))}
  end

  def fucktor(vars)
    vars = vars.rotate
    n = vars.size - 1
    vals = nesting_loops(n).map(&:flatten)
                           .map {|e| e.reduce(:+) > 1 ? 0.0 : 1.0}
    Factor.new(vars: vars, vals: vals)
  end

  def nesting_loops(n)
    n==0 ? [1.0, 0.0] : [1.0, 0.0].product(nesting_loops(n-1))
  end

  def resolve
    clique_tree.calibrate
    clique_tree.nodes.each { |node| p node.vars.map(&:name) }

    probs = {}
    t.board.each { |e| probs[e] = clique_tree.query(e, 'X') }
    anti_probs = probs.invert
    anti_probs.delete(1.0)

    pick = anti_probs.keys.max

    puts "p(x) chosen: #{pick}"
    probs.each{|k, v| puts "#{k.name}: #{v}"}
    puts "-------------------"

    if pick != 0.0
      cell = anti_probs[pick]
      # f = clique_tree.nodes.find { |n| n.vars.include?(cell) }
      f = clique_tree.nodes.first
      # f.bag[:phi].reduce(cell => 'X')
      f.bag[:phi] * Factor.new(vars: [cell], vals: [0.1, 0.0])
      # @factors << Factor.new(vars: [cell], vals: [0.1, 0.0])

      clique_tree.calibrate
      p f.bag[:beta].clone.marginalize_all_but(t.sqr('2-1').first)

      resolve
    else
      puts probs.values.join.gsub('1.0', 'X').gsub('0.0', '_').scan(/.{#{t.n}}/).join("\n")
    end
  end

end

s = NQueens.new(3)
# s.resolve

# a b c d
# e f g h
# i j k l
# m n o p

# a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p

a, b, c, d, e, f, g, h, i = s.t.board
all = [a, b, c, d, e, f, g, h, i]
p all.map(&:name)

# a b c
# d e f
# g h i

f1 = s.fucktor [a, b, c, d, e, g, i]
f2 = s.fucktor [b, c, d, e, f, h, i]
f3 = s.fucktor [a, b, c, e, f, g, i]
f4 = s.fucktor [a, b, d, e, f, g, h]
f5 = s.fucktor [a, b, c, d, e, f, g, h, i]
f6 = s.fucktor [b, c, d, e, f, h, i]
f7 = s.fucktor [a, c, d, e, g, h, i]
f8 = s.fucktor [b, d, e, f, g, h, i]
f9 = s.fucktor [a, c, e, f, g, h, i]

# f1.reduce(a => 'X')
f5.reduce(a => 'X')
# f2.reduce(f => 'X')


clique_tree = CliqueTree.new(f5)
# clique_tree = CliqueTree.new(f1, f2, f3, f4, f5, f6, f7, f8, f9)
clique_tree.calibrate
s.t.board.each { |e| puts "#{e}: #{clique_tree.query(e, 'X')}" }

# f1 * f2 * f3 * f4 * f5 * f6 * f7 * f8 * f9
# all.each do |x|
#   p f1.clone.norm.marginalize_all_but(x).vals
# end





