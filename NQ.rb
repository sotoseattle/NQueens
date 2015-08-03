require 'primo'
require './tablero'

class NQueens
  attr_accessor :t, :factors

  def initialize(n)
    @t = Tablero.new(n)
    @factors = []
    fucktorize_idle_cells(t.board)
  end

  def fucktorize_idle_cells(rest)
    vars = t.queen_cells(rest.first.name)
    @factors << values(vars)
    rest -= vars
    fucktorize_idle_cells(rest) unless rest.empty?
  end

  def nesting_loops(n)
    if n==0
      return [1, 0]
    else
      [1, 0].product(nesting_loops(n-1))
    end
  end

  def values(vars)
    vars = vars.rotate
    n = vars.size - 1
    vals = nesting_loops(n).map(&:flatten)
                           .map {|e| e.reduce(:+) > 1 ? 0.0 : 1.0}
    Factor.new( vars: vars, vals: vals)
  end

  def resolve
    clique_tree = CliqueTree.new(*factors)
    clique_tree.calibrate

    probs = {}
    t.board.each { |e| probs[e] = clique_tree.query(e, 'X') }
    anti_probs = probs.invert
    anti_probs.delete(1.0)

    pick = anti_probs.keys.max

    p pick
    probs.each{|k, v| puts "#{k.name}: #{v}"}
    puts "-------------------"

    if pick != 0.0
      cell = anti_probs[pick]
      # f = factors.detect{|g| g.vars.include?(cell)}
      f = values(t.queen_cells(cell.name))
      f.reduce(cell => 'X')
      factors << f
      resolve
    else
      # probs.each{|k, v| puts "#{k.name}: #{v}"}
    end
  end
end

s = NQueens.new(3)
s.resolve

