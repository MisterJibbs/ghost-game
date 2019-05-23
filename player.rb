class Player
    attr_reader :name

    def initialize(name)
        @name = name
    end

    def guess
        print "Enter a letter to add to the fragment: "
        answer = gets.chomp
        return answer.downcase
    end

    def alert_invalid_guess
        puts "Guess is invalid. Please try again."
    end
end