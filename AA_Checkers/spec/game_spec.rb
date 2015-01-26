require 'game'
require 'factory_girl'

describe Game do
  subject(:game) { Game.new } # only one allowed
  

  describe "set up" do
    it "creates a size 8x8 board as default" do
      expect(game.board.size).to eq(8)
    end

    it "fills the board as default" do
      expect(game.board[[0,1]]).not_to eq(nil)
      expect(game.board[[7,0]]).not_to eq(nil)
    end

  end

end
