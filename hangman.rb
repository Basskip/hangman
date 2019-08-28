require 'json'

class Hangman

    def initialize(word, turns)
        @word = word.downcase
        @guesses_remaining = turns
        @incorrect_letters = []
        @progress = Array.new(@word.length, "_")
    end

    def start
        puts "Welcome to hangman, select an option to start:"
        puts "1 - Start a new game"
        puts "2 - Load a game from file"
        selection = get_selection
        if selection == "1"
            play
        elsif selection == "2"
            show_saves
            load_from_file(select_save)
            play
        end
    end

    def show_saves
        puts Dir.glob('saves/*.json').map {|fname| fname.match(/^saves\/(\w+)\.json$/)[1] }.join("\n")
    end

    def select_save
        print "Select a savegame to load: "
        filename = ""
        loop do
            filename = gets.chomp
            if File.exists?("saves/#{filename}.json")
                break
            else
                print "Invalid filename, try again:"
            end
        end
        "saves/#{filename}.json"
    end

    def get_selection
        print "Your selection: "
        input = ""

        loop do
            input = gets.chomp
            if input.match?(/[1-2]/)
                break
            else 
                print "Invalid selection try again:"
            end
        end
        input
    end

    def play
        puts "Let's play! Input 'save' at any time to save your game"
        until game_won? || game_lost?
            print_status
            letter = get_letter
            if letter == "save"
                name = get_filename
                save(name)
            else
                guess(letter)
                @guesses_remaining -= 1
            end
        end
        if game_won?
            puts "You win! The word was #{@word}"
        elsif game_lost?
            puts "No more turns! The word was #{@word}"
        end
    end

    def game_lost?
        @guesses_remaining == 0
    end

    def game_won?
        @word == @progress.join
    end

    def guess(letter)
        indexes = (0..@word.length).find_all {|i| @word[i] == letter}
        if indexes.length > 0
            indexes.each {|index| @progress[index] = letter}
        else
            @incorrect_letters << letter
        end
    end

    def get_letter
        print "Guess a letter: "
        input = ""

        loop do
            input = gets.chomp
            if input.match?(/[a-zA-Z]/) || input == "save"
                break
            else 
                print "Invalid input try again:"
            end
        end
        input.downcase
    end

    def print_status
        puts "Word progress: #{progress_string} Incorrect guesses: #{incorrect_string} Turns left: #{@guesses_remaining}"
    end

    def incorrect_string
        @incorrect_letters.join(",")
    end

    def progress_string
        @progress.join(" ")
    end

    def get_filename
        print "Choose a name for your savegame: "
        name = gets.chomp.strip
        name
    end

    def save(filename)
        begin
            Dir.mkdir("saves") unless File.exists?"saves"
            File.open("saves/#{filename}.json", "w") {|file| file.puts self.to_json}
            puts "Game saved as #{filename}!"
        rescue
            puts "Error saving file"
        end
    end

    def load_from_file(filename)
        data = File.open(filename, "r").read
        load_from_json(data)
    end

    def to_json
        JSON.dump ({
            :word => @word,
            :guesses_remaining => @guesses_remaining,
            :incorrect_letters => @incorrect_letters,
            :progress => @progress
        })
    end

    def load_from_json(string)
        data = JSON.load string
        @word = data['word']
        @guesses_remaining = data['guesses_remaining']
        @incorrect_letters = data['incorrect_letters']
        @progress = data['progress']
    end


end

dictionary = File.open("5desk.txt","r").readlines

word = ""
until word.length >= 5 && word.length <= 12 do 
    word = dictionary.sample.strip
end

game = Hangman.new(word,10)
game.start