def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines

dns_raw = File.readlines("zone")

def parse_dns(dns_raw)
  main_records = {} #create a empty harsh
  dns_raw.each.with_index { |row, index|
    row = row.strip!.split(", ") # converted to array
    main_records[index + 1] = { row[0] => { row[1] => row[2] } } #add or push the keys and values to the main_records harsh
  }
  return main_records
end

def resolve(dns_records, lookup_chain, domain)
  found = true # check value is there or not in that harshes
  dns_records.each { |i|
    if (i[1].include? "A" and (i[1]["A"][domain])) # find the domain and check the domain inside of the "A" key or not
      found = false
      return lookup_chain.push(i[1]["A"][domain]) # push or add the values to the lookup_chain array
    elsif (i[1].include? "CNAME" and i[1]["CNAME"][domain]) # find the domain and check the domain inside of the "CNAME" key or not
      found = false
      lookup_chain.push(i[1]["CNAME"][domain])  # push or add the values to the lookup_chain array
      return resolve(dns_records, lookup_chain, i[1]["CNAME"][domain]) # call the function recursively
    end
  }
  if found
    lookup_chain = [] # i create empty array because of prevent to print the extra elements
    return lookup_chain.push("Error: record not found for #{domain}") # i push the error message to the lookup_chain array
  end
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
