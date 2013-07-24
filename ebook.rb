require 'rubygems'
require 'require_relative'
require 'twitter'
require 'optparse'

require_relative 'twitter_init'
require_relative 'markov'

source_tweets = []
$rand_limit ||= 10
$markov_index ||= 2
$include_urls ||= false
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

def filtered_tweets(tweets)
  source_tweets = tweets.map {|t| t.text.gsub(/\b(RT|MT) .+/, '') }

  if !$include_urls
    source_tweets = source_tweets.reject {|t| t =~ /(https?:\/\/)/ }
  end

  source_tweets.map {|t| t.gsub(/(\#|@|(h\/t)|(http))\S+/, '') }
end

# randomly running only about 1 in $rand_limit times
unless rand_key == 0 || options[:force]
  puts "Not running this time (key: #{rand_key})"
else
  # Fetch a thousand tweets
  begin
    user_tweets = Twitter.user_timeline($source_account, :count => 200, :trim_user => true, :exclude_replies => true, :include_rts => false)
    max_id = user_tweets.last.id
    source_tweets += filtered_tweets(user_tweets)

    # Twitter only returns up to 3200 of a user timeline, includes retweets.
    17.times do
      user_tweets = Twitter.user_timeline($source_account, :count => 200, :trim_user => true, :max_id => max_id - 1, :exclude_replies => true, :include_rts => false)
      puts "MAX_ID #{max_id} TWEETS: #{user_tweets.length}"
      max_id = user_tweets.last.id
      source_tweets += filtered_tweets(user_tweets)
    end
  rescue
  end

  puts "#{source_tweets.length} tweets found"

  if source_tweets.length == 0
    raise "Error fetching tweets from Twitter. Aborting."
  end

  markov = MarkovChainer.new($markov_index)

  source_tweets.each do |twt|
    text = twt
    markov.add_text(text)
  end

  tweet = nil

  10.times do
    tweet = markov.generate_sentence

    if rand(3) == 0 && tweet =~ /(in|to|from|for|with|by|our|of|your|around|under|beyond)\s\w+$/
      puts "Losing last word randomly"
      tweet.gsub(/\s\w+.$/, '')   # randomly losing the last word sometimes like horse_ebooks
    end

    if !options[:tweet]
      puts "MARKOV: #{tweet}"
    end

    tweet_letters = tweet.gsub(/\W/, '')
    break if !tweet.nil? && tweet.length < 110 && !source_tweets.any? {|t| t.gsub(/\W/, '') =~ /#{tweet_letters}/ }
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
