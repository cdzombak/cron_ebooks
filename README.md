# cron_ebooks

**This is a really simple adaptation of [@harrisj's iron_ebooks](https://github.com/harrisj/iron_ebooks) to run on any server with cron.**

A simple and hackish ruby script for pseudorandomly posting to a _ebooks account tweets derived from a regular twitter account.

## Setup

1. Signup for a Twitter account you want to use for ebooking things
2. Sign into [dev.twitter.com](https://dev.twitter.com) with the same credentials
3. Create an application for your `_ebooks` account
4. Set its permissions to read/write and generate OAuth credentials
5. Create a file named `twitter_init.rb` in this directory with the OAuth credentials and the source account you want to use for seeding the markov process
6. Upload to your server
7. `gem install twitter require_relative`, or if you're going to use bundler or something better, set that up with those gems
8. Run it with `ruby ebook.rb` a few times
9. Schedule it to run regularly with cron. I'd suggest once every 53 minutes or so: `*/53   *   *   *   *   ruby /home/USER/scripts/USER_ebooks/ebook.rb`
