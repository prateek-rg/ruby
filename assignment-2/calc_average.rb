
class StringEmptyError < StandardError
end

class NoNumbersError < StandardError
end

class NoPositiveNumbersError < StandardError
end

puts "Enter Input String"
input = gets.chomp

puts "Input string entered was : " + input

raise StringEmptyError, 'String was empty' if input.length == 0

numbers = input.scan(/-\d|\d/).map(&:to_i)

raise NoNumbersError, 'No numbers found in string' if numbers.size == 0

numbers.select! {|num| num >= 0 }

raise NoPositiveNumbersError, 'No non-negative numbers found in string' if numbers.size == 0

puts "average is " + (numbers.inject(0.0) { |sum, el| sum + el } / numbers.size).to_s