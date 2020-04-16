dictionary1 = ['darkness','black','doom','evil','satan','devil','metal','church','fire','varg','depression','depress',
                      'apocalypse','sacrifice','altar','murder','blood','death','pain','suffering','disease','decay']



def substring(string,dictionary)                                #Iterative, brute force. Probably the most simpleton implementation possible, yet it seems to be working fine enough.
        separate_words = string.downcase.split(" ")
        result = {}
        dictionary.each do |word|
                separate_words.each do |gair|
                        if gair =~ /#{word}/
                                if result.keys.include?(word)
                                        result[word] = result[word] + 1
                                else 
                                        result[word] = 1
                                end
                        end
                end
        end
        return result.to_s
end




example1 = "Varg Vikernes has burned three churches in Norwey. He's a nameknown black metal, ambient, scaldic metal etc. artists." +
                " He murdered Euronymous, stabbing him multiple times with a knife. Varg does not worship satan nor the devil, AFAIK he's pagan."

example2 = "Blood death knights are a fun specialization to play in WoW. You'll enjoy it if you prefer defensive play style, blood-draining," + 
                " heavy plate metal armor, bringing death, pain and suffering to your foes. Or you can play unholy for more damage, " + 
                "playstyle including spreading diseases, rot, decay and a nice ghoul-summoning ability: Apocalypse!"

puts substring(example1,dictionary1)
puts substring(example2,dictionary1)