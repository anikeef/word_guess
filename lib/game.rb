require "./lib/errors.rb"
require "./lib/get_input.rb"
include Input

class Game
	attr_reader :correct_letters, :result_letters, :mistakes
	attr_accessor :is_win

	def initialize(
		correct_letters = File.readlines("5desk.txt").map {|word| word.chomp}
			.select { |word| word.length.between?(5,12) }
			.sample.chomp.split(""),
		mistakes = [],
		result_letters = Array.new(correct_letters.length).map { "_" }
	)
		@correct_letters = correct_letters
		@mistakes = mistakes
		@result_letters = result_letters
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
		ask_for_saving
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
			if letter.downcase == correct_letter.downcase
				result_letters[i] = letter
				right_guesses += 1
			end
		end
		mistakes << letter if right_guesses == 0
	end

	def ask_for_saving
		choice = Input.get("Do you want to save current game? (y/n): ", /^[yn]$/i)
		save_game if choice == "y"
	end

	def save_game
		game_name = Input.get("Enter the name of your game: ", /^[\w\d]+$/i, "Incorrect name, try again")
		Dir.mkdir("saved_games") unless Dir.exists?("saved_games")
		File.open("saved_games/#{game_name}.txt", "w") { |file| file.puts Marshal.dump(self) }
	end

	def marshal_dump
		[@correct_letters, @mistakes, @result_letters]
	end

	def marshal_load array
		@correct_letters, @mistakes, @result_letters = array
	end
end

choice = Input.get("Do you want to start new game or to open saved one?\n1.New\n2.Open\nEnter 1 or 2: ", /^[12]$/)

case choice
when "1"
	game = Game.new
when "2"
	game_name = Input.get("Enter the name of your game: ", nil, "Incorrect name, try again") do |input|
		File.exists?("saved_games/#{input}.txt")
	end
	game = Marshal.load(File.read("saved_games/#{game_name}.txt"))
end
game.play
