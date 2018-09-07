class Game
	attr_reader :word

	def initialize
		@word = File.readlines("5desk.txt").sample.chomp.split("")
	end
end

Game.new