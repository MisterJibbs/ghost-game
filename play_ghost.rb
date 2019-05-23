# Play Ghost

require_relative 'ghost'

print "Enter number of players: "
num_of_players = gets.chomp.to_i    # => turns "answer\n" to a number
player_names = []

(1..num_of_players).each do |i|
    print "Enter name for player #{i}: "
    player_names << gets.chomp
end

game = Ghost.new(player_names)  # => puts in the array of player names as an argument

game.run