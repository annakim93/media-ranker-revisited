# Old seeds generation

# require "csv"
# media_file = Rails.root.join("db", "media_seeds.csv")
#
# CSV.foreach(media_file, headers: true, header_converters: :symbol, converters: :all) do |row|
#   data = Hash[row.headers.zip(row.fields)]
#   puts data
#   Work.create!(data)
# end

####################################
require 'faker'

user_upload_failures = []
10.times do |num|
  user = User.new

  user.username = "user#{num}"
  user.email = Faker::Internet.email.to_s
  user.uid = rand(1_111_111..9_999_999)
  user.provider = 'github'

  successful = user.save
  if !successful
    user_upload_failures << user
    puts "Failed to save user: #{user.inspect}"
  else
    puts "Created user: #{user.inspect}"
  end
end

puts "Added #{User.count} user records"
puts "#{user_upload_failures.size} users failed to save"

####################################

categories = %w[album book movie]
work_upload_failures = []

50.times do |num|
  work = Work.new

  work.title = "work#{num}"
  work.creator = Faker::Name.name.to_s
  work.description = "Work #{num} is a work. It's cool I guess."
  work.category = categories.sample
  work.publication_year = rand(1900..2020)
  work.user_id = rand(0..9)

  successful = work.save
  if !successful
    work_upload_failures << work
    puts "Failed to save work: #{work.inspect}"
  else
    puts "Created work: #{work.inspect}"
  end
end

puts "Added #{Work.count} works"
puts "#{work_upload_failures.size} works failed to save"
