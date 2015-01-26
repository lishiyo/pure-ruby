require_relative 'board'
require 'colorize'

class CheckersError < StandardError
end

class InvalidMoveError < CheckersError
end


class Piece

	attr_accessor :pos, :color, :now_king
	attr_reader :board

	def initialize(board, pos, color, now_king = false)
		@now_king = now_king
		@board, @pos, @color = board, pos, color

		board.add_piece(self, pos)
	end

	# one move diagonally
	def perform_slide(end_pos)
		valid_positions = get_valid_pos(move_diffs)
		return false unless valid_positions.include?(end_pos)

		move_piece(end_pos)

		true
	end

	# removes the jumped over piece from the Board
	def perform_jump(end_pos)
		deltas = move_diffs.map{ |x,y| [x * 2, y * 2] }
		valid_positions = get_valid_pos(deltas)
		return false unless valid_positions.include?(end_pos)

		piece_between = board[[((pos[0] + end_pos[0]) / 2), ((pos[1] + end_pos[1]) / 2)]]
		return false unless piece_between && piece_between.color != self.color

		move_piece(end_pos)
		board.delete_piece(piece_between, piece_between.pos) # capture the enemy piece

		true
	end

	# First checks valid_move_seq?
	# either calls perform_moves! OR raises an InvalidMoveError
	def perform_moves(move_sequence)
		raise InvalidMoveError.new("That move sequence was invalid!") unless valid_move_seq?(move_sequence)

		perform_moves!(move_sequence)
	end

	def perform_moves!(move_sequence)
		if move_sequence.size == 1 # one move, slide or jump
			end_pos = move_sequence.first
			raise InvalidMoveError unless (perform_slide(end_pos) || perform_jump(end_pos))
		else # must all be jumps
			move_sequence.each do |end_pos|
				raise InvalidMoveError unless perform_jump(end_pos)
			end
		end

	end

	# calls perform_moves! on a *duped* Piece/Board
	# returns true only if no error is raised
	def valid_move_seq?(move_sequence)
		begin
			duped_board = board.dup
			duped_piece = duped_board[pos]

			duped_piece.perform_moves!(move_sequence)
		rescue InvalidMoveError
			return false
		end

		true
	end

	def inspect
		"#{@color}#{@now_king}#{pos}"
	end

	def render
		if now_king
			color == :black ? " ♚ " : " ♔ "
		else
			color == :black ? " ☻ " : " ☻ ".colorize(:red)
		end
	end

	private

	def move_piece(end_pos)
		board.add_piece(self, end_pos) # add self to new position on board
		board.delete_piece(self, pos) # delete old position on board
		self.pos = end_pos # update self's internal pos

		self.now_king = true if should_promote?
	end

	def get_valid_pos(deltas)
		posx, posy = pos[0], pos[1]
		# both empty and in bounds
		deltas.map{ |(dx, dy)| [posx + dx, posy + dy] }
			.select{|pos| board[pos].nil? && Board.in_bounds?(pos) }
	end

	# checks to see if piece has reached back row
	def should_promote?
		row = pos[0]
		(self.color == :red) ? (row == 7) : (row == 0)
	end

	def move_diffs
		deltas = { red: [[1, 1], [1, -1]], black: [[-1, 1], [-1, -1]] }

		# if king, return both
		@now_king ? (deltas[:red] + deltas[:black]) : deltas[self.color]
	end


end
