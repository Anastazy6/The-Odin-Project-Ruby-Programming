# frozen_string_literal: true

def caesar(string, shift)
  encrypt_this = string.split('')
  encrypted_stuff = []
  encrypt_this.each do |char|
    case char
    when /[^A-Za-z]/ then encrypted_stuff.push(char)
    when /[A-Z]/
      lowcased = char.downcase
      encrypted_char = encrypt(lowcased, shift)
      upcased = encrypted_char.upcase
      encrypted_stuff.push(upcased)
    else
      encrypted_char = encrypt(char, shift)
      encrypted_stuff.push(encrypted_char)
    end
  end
  encrypted_stuff.join
end

def encrypt(letter, shift)
  alphabeth = %w[a b c d e f g h i j k l m n o p q r s t u v w x y z]

  raise 'WARNING! A non-downcase letter has been parsed to the encryption machine!' if letter =~ /[^a-z]/

  id = alphabeth.index(letter)
  change = id + shift
  change -= alphabeth.length while change >= alphabeth.length
  change += alphabeth.length while change.negative?
  alphabeth[change]
end

puts "Do you want to secure your message? Here's the notorious for its lack of security, the old, the know, and the easily crackable... CAESAR!"
puts "Type your message now, you poor, unfortunate soul... >>> \n"
message = gets.chomp
puts "How large do you want the shift to be? Type an integer... >>> \n"
shift = gets.chomp

puts "Encrypting started... \n\n"
puts caesar(message, shift.to_i)

puts 'Encrypting complete.'
