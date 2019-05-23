require_relative "player"
require "set"
require 'pry'

class Ghost
    ALPHABET = Set.new("a".."z")    # => set of alphabet {"a", "b", "c"...}
    MAX_LOSSES_ALLOWED = 5          # => sets max number of losses before a player drops out to be referenced from anywhere

    attr_reader :dictionary, :fragment, :players, :losses

    def initialize(player_names)
        @players = player_names.map { |name| Player.new(name) } # => maps each player_name as a new Player instance
        words = File.foreach('dictionary.txt').map { |word| word.chomp }   # => goes through each line of dictionary.txt and maps it to an array
        @dictionary = Set.new(words) # => takes in an array of words as an argument and creates a set out of the data
        @losses = {}

        @players.each { |player_name| @losses[player_name] = 0 }
    end

    def run
        self.play_round until game_over?
        game_over_announcement      # => UI methods to keep things looking clean and to avoid distracting from the core logic
    end

    def play_round
        @fragment = ""  # => creates an empty fragment at the beginning of each round to be added onto

        display_standings   # => more UI methods
        round_start_announcement    # => more UI methods

        until round_over? do    # => until the fragment is a word within @dictionary
            take_turn(current_player)
            next_player!   
        end

        @losses[previous_player] += 1

        round_over_announcement
    end

    def record(player)
        times_lost = @losses[player]
        "GHOST".slice(0, times_lost)    # => takes a chunk of the provided string from (0...times_lost) to represent their losses in letter form
    end

    def take_turn(current_player)
        turn_announcement
        
        answer = false  # => sets answer to false to allow for the following loop
        until answer    # => until answer is truthy. cannot use answer == true because the actual value of answer would need to be the boolean 'true'
            answer = current_player.guess
            
            unless valid_play?(answer)
                current_player.alert_invalid_guess  # => attaches a general error message at the end of the specific error message provided by valid_play?
                answer = false  # => sets answer to false so it doesn't bypass the until answer (until truthy) parameter
            end
        end

        @fragment += answer
        puts "[Success] #{current_player.name} added #{answer} to the fragment."

        sleep(1)
    end
    
    def valid_play?(string)
        puts

        if string.length != 1
            print "[Error] Answer must be a single character. "
            return false
        end

        if !ALPHABET.include?(string)
            print "[Error] Answer must be a letter of the alphabet. "
            return false
        end

        resulting_fragment = @fragment + string
        if @dictionary.none? { |word| word.start_with?(resulting_fragment) }    # => if the resulting fragment from adding the letter isn't the beginning of any words found in @dictionary
            print "[Error] No words begin with that fragment. "
            return false
        end

        true
    end

    def current_player
        @players.first
    end

    def previous_player
        @players.last
    end

    def next_player!
        @players.rotate!    # => need this initial rotate because the loop below may detect that the player who just finished their turn hasn't lost the game yet and won't rotate
        @players.rotate! until @losses[current_player] < MAX_LOSSES_ALLOWED
    end

    def round_over?
        @dictionary.include?(@fragment)
    end

    def game_over?
        remaining_players == 1
    end

    def remaining_players
        @losses.count { |player, times_lost| times_lost < MAX_LOSSES_ALLOWED }  # => counts up how many players are left that have less than the allowed amount of losses
    end

    # UI and display methods

    def display_standings
        system "clear"
        puts "Current Standings: "
        puts

        @losses.each do |player, times_lost|
            puts "#{player.name}: #{record(player)}"
        end

        sleep(1)
    end

    def record(player)
        times_lost = @losses[player]
        "GHOST".slice(0, times_lost)    # => takes a chunk of the provided string from (0...times_lost) to represent their losses in letter form
    end

    def turn_announcement
        system "clear"
        puts "#{self.current_player.name}'s turn."
        puts "Current fragment: #{@fragment}"
    end

    def round_start_announcement
        puts
        puts "= = = = = = ="
        puts " Round Start!"
        puts "= = = = = = ="
        puts
        puts "\tPress enter to continue"
        gets
    end
        
    def round_over_announcement
        player_name = previous_player.name
        puts "#{player_name} completed the word '#{@fragment}'. #{player_name} loses the round!"
        puts "#{player_name} is a GHOST! #{player_name} is out of the game!" if @losses[previous_player] == MAX_LOSSES_ALLOWED
        puts
        puts "= = = = = = ="
        puts " Round Ended."
        puts "= = = = = = ="
        puts
        puts "\tPress enter to continue"
        gets
    end
    
    def game_over_announcement
        system "clear"
        puts "= = = = = ="
        puts " Game Over"
        puts "= = = = = ="
        puts
        puts "#{current_player.name} wins the game!"
        puts
    end
end