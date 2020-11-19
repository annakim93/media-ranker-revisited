require 'yaml'
require 'faker'
require 'date'

# Users
10.times do |num|
  puts "user_#{num+1}:"
  puts "  username: user_#{num+1}"
  puts "  email: #{Faker::Internet.email}"
  puts "  uid: #{rand(1111111..9999999)}"
  puts "  provider: github"
end


# Works
categories = %w[album movie book]
20.times do |num|
  puts "work_#{num+1}:"
  puts "  category: '#{categories.sample}'"
  puts "  title: work_#{num+1}"
  puts "  creator: #{Faker::Name.name}"
  puts "  publication_year: #{rand(1900..2020)}"
  puts "  description: this is a test work"
end


# Votes
10.times do |num|
  puts "vote_#{num+1}:"
  puts "  user: user_#{rand(1..10)}"
  puts "  work: work_#{rand(1..20)}"
end
