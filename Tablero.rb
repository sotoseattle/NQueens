require 'primo'

class Cell < RandomVar
  def initialize(r, c)
    super(card: 2, name: "#{r}-#{c}", ass: %w(X O))
  end
end

class Tablero
  attr_accessor :board

  def initialize(n)
    @n = n
    @board = []
    (1..n).each { |r| (1..n).each { |c| @board << Cell.new(r, c) } }
  end

  def row(r)
    @board.select {|e| e.name=~/^#{r}-/ }
  end

  def col(c)
    @board.select {|e| e.name=~/-#{c}$/ }
  end

  def sqr(cname)
    @board.select {|e| e.name == cname }
  end

  def tower_cells(cname)
    r, c = cname.split('-').map(&:to_i)
    row(r) + col(c)
  end

  def diag_equal_grow(i, j)
    kk = []
    while i<=@n && j<=@n do
      kk << "#{i}-#{j}"
      i += 1
      j += 1
    end
    kk
  end

  def diag_oppos_grow(i, j)
    kk = []
    while i<=@n && j>=1 do
      kk << "#{i}-#{j}"
      i += 1
      j -= 1
    end
    kk
  end

  def bishopy(r, c)
    if r < c
      i = 1
      j = (r - c).abs + 1
    else
      i = (r - c).abs + 1
      j = 1
    end
    arr = diag_equal_grow(i, j)

    if r + c <= @n + 1
      i = 1
      j = (r + c - 1)
    else
      j = @n
      i = r + c - j
    end
    arr += diag_oppos_grow(i, j)

    arr.map{|e| sqr(e)}.flatten
  end

  def bishop_cells(cname)
    r, c = cname.split('-').map(&:to_i)
    bishopy(r, c)
  end

  def queen_cells(cname)
    r, c = cname.split('-').map(&:to_i)
    (bishopy(r, c) + row(r) + col(c)).uniq
  end
end

