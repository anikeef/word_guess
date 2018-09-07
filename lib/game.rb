require "./lib/errors.rb"

class Game
	attr_reader :correct_letters, :result_letters, :mistakes
	attr_accessor :is_win

	def initialize
		@correct_letters = File.readlines("5desk.txt").map {|word| word.chomp}
			.select { |word| word.length.between?(5,12) }
			.sample.chomp.split("")
		@mistakes = []
		@result_letters = Array.new(correct_letters.length).map { "_" }
		@is_win = false
	end
	def play
		make_attempt until mistakes.length == 6 || is_win
		display
		puts is_win ? "You win!" : "You lose. The right answer is #{correct_letters.join}"
	end
	def display
		puts
		puts result_letters.join(" ")
		puts "Mistakes (#{mistakes.length}): #{mistakes.join(", ")}"
	end
	def make_attempt
		display
		begin
			print "Letter: "
			letter = gets.chomp.downcase
			raise unless /^[a-z]$/i.match?(letter)
			raise MistakeRepeat if mistakes.any? { |mistake| letter == mistake }
		rescue MistakeRepeat
			puts "You've already tried #{letter}, try again"
			retry
		rescue
			puts "Incorrect input, try again"
			retry
		end
		evaluate(letter)
		self.is_win = result_letters.none? { |letter| letter == "_" }
	end
	def evaluate(letter)
		right_guesses = 0
		correct_letters.each.with_index do |correct_letter, i|
			if letter == correct_letter
				result_letters[i] = letter
				right_guesses += 1
			end
		end
		mistakes << letter if right_guesses == 0
	end
end

game = Game.new
game.play
