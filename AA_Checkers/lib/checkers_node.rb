class CheckersNode
  attr_reader :board, :curr_color, :prev_move_pos

  def initialize(board, curr_color, prev_move_pos)
    @board, @curr_color, @prev_move_pos = board, curr_color, prev_move_pos
  end

  # Dup the board
  # for each of my pieces, make a valid jump, score += 1, and switch player
  # opposing player does same thing - if this piece was captured, score -= 1
  # back to you - make another valid jump.
  # Return max_jump_score if no valid jumps are possible.
  def net_jumps(color)
    curr_jump_score = 0
    max_jump_score = 0

    # return 0 if no valid jumps for any of my pieces
    return max_jump_score if my_pieces.all?{|piece| valid_jumps_for(color, piece.pos).zero? }

    my_pieces.each do |piece|
      next if valid_jumps_for(color, piece.pos).zero? # skip jumpless pieces
      duped_board = board.dup
      duped_piece = duped_board[piece.pos]
      valid_jumps_for(color, piece.pos).each do |jump|
        
      end
    end
  end

  def my_pieces(color)
    board.pieces.select{|piece| piece.color == color }
  end

  # Returns array of valid one-step jumps for a position
  def valid_jumps_for(color, pos)
    valid_jumps = []

    empty_pos.each do |empty_pos|
      next unless (empty_pos[0] - pos[0]).abs == 2 &&
        (empty_pos[1] - pos[1]).abs == 2
      duped_board = board.dup
      duped_piece = duped_board[pos]
      if duped_piece.valid_move_seq?(empty_pos)
        valid_jumps << empty_pos
      end
    end

    valid_jumps
  end

  def valid_slides_for(color, pos)
    valid_slides = []

    empty_pos.each do |empty_pos|
      next unless (empty_pos[0] - pos[0]).abs == 1 &&
        (empty_pos[1] - pos[1]).abs == 1
      duped_board = board.dup
      duped_piece = duped_board[pos]
      if duped_piece.valid_move_seq?(empty_pos)
        valid_slides << empty_pos
      end
    end

    valid_slides
  end

  # array of empty_pos for this board
  def empty_pos
    empty_pos = []
    board.grid.each_with_index do |row, row_i|
      row.each_with_index do |col, col_i|
        empty_pos << [row_i, col_i] if board[[row_i, col_i]].nil?
      end
    end
    empty_pos
  end

end
