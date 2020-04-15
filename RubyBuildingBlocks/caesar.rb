def kajzer(string, shift)
        encrypt_this = string.split("")
        encrypted_stuff = []
        encrypt_this.each do |char|
                if char =~ /[^A-Za-z]/
                        encrypted_stuff.push(char)
                elsif char =~ /[A-Z]/
                        lowcased = char.downcase
                        encrypted_char = encrypt(lowcased, shift)
                        upcased = encrypted_char.upcase
                        encrypted_stuff.push(upcased)
                else
                        encrypted_char = encrypt(char, shift)
                        encrypted_stuff.push(encrypted_char)
                end
        end
        result = encrypted_stuff.join()
        return result
end

def encrypt(letter, shift)
        alphabeth = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
        if letter =~ /[^a-z]/
                raise "WARNING! A non-downcase letter has been parsed to the encryption machine!"
        else 
                id = alphabeth.index(letter)
                newid = id + shift
                while newid >= alphabeth.length() do
                        newid -= alphabeth.length()
                end
                while newid < 0 do
                        newid += alphabeth.length()
                end
                return alphabeth[newid]
        end
end

def maehinmarwolaethorgloch(&hvafaen)   # Taken from a practice lesson, this method is not a part of this project, I have added it for fun.
        sztart = Time.now
    
        hvafaen.call
    
        duration = Time.now - sztart
    
        puts "It took " + duration.to_s + " szekondz."
    end
    

puts "Do you want to secure your message? Here's the notorious for its lack of security, the old, the know, and the easily crackable... CAESAR!"
puts "Type your message now, you poor, unfortunate soul... >>> \n"
message = gets.chomp
puts "How large do you want the shift to be? Type an integer... >>> \n"
shift = gets.chomp

puts "Encrypting started... \n\n"

puts "#{maehinmarwolaethorgloch do puts kajzer(message, shift.to_i) end} \n\n"

puts "Encrypting complete."

