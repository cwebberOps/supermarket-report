#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'octokit'
require 'date'
require 'trello'

github = Octokit::Client.new(:access_token => ENV['GITHUB_API_KEY'])
week_ago = Date.today - 7

puts "<h2>Tasks Completed This Week</h2>"
puts "<ul>"
github.pull_requests('opscode/supermarket', :state => 'closed').each do |pr|
  if pr[:merged_at] && pr[:merged_at].to_date > week_ago
    puts "<li>#{pr[:title]} - (<a href='#{pr[:html_url]}'>PR \##{pr[:number]}</a></li>)"
  end
end
puts "</ul>"
puts "<p>You can view our complete list of Pull Requests here: https://github.com/opscode/supermarket/pulls</p>"
puts ""

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_APP_KEY']
  config.member_token = ENV['TRELLO_USER_TOKEN']
end

doing = Trello::List.find('532b17091b4da9e958dad21c').cards
todo = Trello::List.find('532b17091b4da9e958dad21b').cards

puts "Tasks Currently Being Worked On"
doing.each do |card|
  puts "* #{card.name} - (#{card.url})"
end

puts ""

puts "Tasks That Are Up Next"
todo.each do |card|
  puts "* #{card.name} - (#{card.url})"
end

puts "The full Trello board can be viewed here:  https://trello.com/b/IGLbkBWL/supermarket"
