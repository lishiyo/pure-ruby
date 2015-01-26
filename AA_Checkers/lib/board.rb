require_relative 'piece'
require 'colorize'

class Board

	COLOR_ROWS = {
		:top => :red,
		:bottom => :black
	}

	attr_reader :grid, :size

	def initialize(fill_board = true, size = 8)
		@size = size
		create_grid(fill_board, size)
	end

	def [](pos)
		x, y = pos[0], pos[1]
		@grid[x][y]
	end

	def []=(pos, piece)
		x, y = pos[0], pos[1]
		@grid[x][y] = piece
	end

	def add_piece(piece, pos)
		raise CheckersError.new("Position not empty") unless empty?(pos)

		self[pos] = piece
	end

	def delete_piece(piece, pos)
		raise CheckersError.new("You don't have a piece there!") if empty?(pos)

		self[pos] = nil
	end

	def empty?(pos)
		self[pos].nil?
	end

	def self.in_bounds?(pos)
		pos.all?{|coord| coord.between?(0, 7) }
	end

	def dup # pass in now_king as parameter
		duped_board = Board.new(false, self.size) # blank grid
		pieces.each do |piece| # instantiate new pieces with same pos, color, now_king
			piece.class.new(duped_board, piece.pos.dup, piece.color, piece.now_king)
		end

		duped_board
	end

	# color wins if only its colors are left on board
	def won?(color)
		pieces.all?{|piece| piece.color == color }
	end

	def render
		@grid.each_with_index do |row, row_i|
			str = ""
			row.each_with_index do |space, col_i|
				if (row_i + col_i).odd? # dark background
					str += (space.nil?) ? darken_bg("   ") : darken_bg(space.render)
				else
					str += (space.nil?) ? "   " : space.render
				end
			end
			first_in_row = row_i * 4 + 1
			notations = (first_in_row .. first_in_row + 3).to_a
			splits = [notations.take(2), notations.drop(2)]
				.map{|half| "#{half}".colorize(:light_white) }
			puts (splits.first.ljust(24) + str + "   " + splits.last.rjust(20))
		end

		nil
	end

	def pieces
		@grid.flatten.compact
	end

	def inspect
		@grid.each do |row|
			puts "#{ row.map{ |square| square.nil? ? square : square.color } }"
		end
	end

	protected

	def darken_bg(str)
		str.colorize(:background => :light_black)
	end

	def create_grid(fill_board, size)
		@grid = Array.new(size) { Array.new(size) }
		return unless fill_board  # stop here unless place pieces
		# fill with red and black pieces

		@grid.each_with_index do |row, row_i|
			row.each_with_index do |col, col_j|
				fill_row = Proc.new do |color|
					Piece.new(self, [row_i, col_j], color) if (row_i + col_j).odd?
				end

				fill_row.call(COLOR_ROWS[:top]) if row_i.between?(0, 2) # red pieces
				fill_row.call(COLOR_ROWS[:bottom]) if row_i.between?(5, 7) # black pieces
			end
		end

	end

end
