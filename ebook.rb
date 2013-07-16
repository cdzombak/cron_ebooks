require 'rubygems'
require 'require_relative'
require 'twitter'
require 'optparse'

require_relative 'twitter_init'
require_relative 'markov'

source_tweets = []
$rand_limit ||= 10
options = { :tweet => true, :force => false }

opt_parser = OptionParser.new do |opt|
  opt.on("--no-tweet", "Do not post anything to Twitter") do
    options[:tweet] = false
  end

  opt.on("-f","--force", "Force sending tweet this time?") do
    options[:force] = true
  end
end

opt_parser.parse!
puts "OPTIONS: #{options}"

rand_key = rand($rand_limit)

# randomly running only about 1 in $rand_limit times
unless rand_key == 0 || options[:force]
  puts "Not running this time (key: #{rand_key})"
else
  # Fetch a thousand tweets
  begin
    user_tweets = Twitter.user_timeline($source_account, :count => 200, :trim_user => true, :exclude_replies => true, :include_rts => false)
    max_id = user_tweets.last.id
    source_tweets += user_tweets.reject {|t| t.text =~ /(https?:\/\/)/ }.map {|t| t.text.gsub(/\b(RT|MT) .+/, '') }

    # Twitter only returns up to 3200 of a user timeline, includes retweets.
    17.times do
      user_tweets = Twitter.user_timeline($source_account, :count => 200, :trim_user => true, :max_id => max_id - 1, :exclude_replies => true, :include_rts => false)
      puts "MAX_ID #{max_id} TWEETS: #{user_tweets.length}"
      max_id = user_tweets.last.id
      source_tweets += user_tweets.reject {|t| t.text =~ /(https?:\/\/)/ }.map {|t| t.text.gsub(/\b(RT|MT) .+/, '') }
    end
  rescue
  end

  puts "#{source_tweets.length} tweets found"

  markov = MarkovChainer.new(2)

  source_tweets.each do |twt|
    text = twt
    text.gsub!(/\#[\w\d]+/, '')  # remove hashtags
    markov.add_text(text)
  end

  tweet = nil

  5.times do
    tweet = markov.generate_sentence

    if rand(3) == 0 && tweet =~ /(in|to|from|for|with|by|our|of|your|around|under|beyond)\s\w+$/
      puts "Losing last word randomly"
      tweet.gsub(/\s\w+.$/, '')   # randomly losing the last word sometimes like horse_ebooks
    end

    break if !tweet.nil? && tweet.length < 110 && !source_tweets.any? {|t| t =~ /^#{tweet}/ || t =~ /#{tweet}$/ }
  end

  if options[:tweet]
    if !tweet.nil? && tweet != ''
      puts "TWEET: #{tweet}"
      Twitter.update(tweet)
    else
      raise "ERROR: EMPTY TWEET"
    end
  else
    puts "DEBUG: #{tweet}"
  end
end

