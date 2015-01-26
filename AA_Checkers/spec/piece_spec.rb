require 'piece'


describe Piece do
  subject { Piece.new(board, pos, color, now_king) }

  describe "#pos" do
    context "Black starting at 5, 0" do
      let(:
