#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'octokit'
require 'date'
require 'trello'
require 'bitly'

Bitly.configure do |config|
  config.api_version = 3
  config.login = ENV['BITLY_USER']
  config.api_key = ENV['BITLY_TOKEN']
end

bitly = Bitly.client
github = Octokit::Client.new(:access_token => ENV['GITHUB_API_KEY'])
week_ago = Date.today - 7

puts "Tasks Completed This Week"

github.pull_requests('opscode/supermarket', :state => 'closed').each do |pr|
  if pr[:merged_at] && pr[:merged_at].to_date > week_ago
    puts "#{pr[:title]} (#{bitly.shorten(pr[:html_url]).short_url})"
  end
end

puts ""
puts "You can view our complete list of Pull Requests here: https://github.com/opscode/supermarket/pulls"
puts ""

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_APP_KEY']
  config.member_token = ENV['TRELLO_USER_TOKEN']
end

doing = Trello::List.find('532b17091b4da9e958dad21c').cards
todo = Trello::List.find('532b17091b4da9e958dad21b').cards

puts "Tasks Currently Being Worked On"
doing.each do |card|
  puts "#{card.name} (#{bitly.shorten(card.url).short_url})"
end

puts ""

puts "Tasks That Are Up Next"
todo.each do |card|
  puts "#{card.name} (#{bitly.shorten(card.url).short_url})"
end

puts ""
puts "The full Trello board can be viewed here:  https://trello.com/b/IGLbkBWL/supermarket"
