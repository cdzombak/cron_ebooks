# cron_ebooks

[![No Maintenance Intended](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)

**This is a really simple adaptation of [@harrisj's iron_ebooks](https://github.com/harrisj/iron_ebooks) to run on any server with cron.**

A simple and hackish ruby script for pseudorandomly posting to a _ebooks account tweets derived from a regular twitter account.

## Setup

1. Signup for a Twitter account you want to use for ebooking things
2. Sign into [dev.twitter.com](https://dev.twitter.com) with the same credentials
3. Create an application for your `_ebooks` account
4. Set its permissions to read/write and generate OAuth credentials
5. Create a file named `twitter_init.rb` in this directory with the OAuth credentials and the source account you want to use for seeding the markov process
6. Upload to your server
7. `gem install twitter require_relative optparse`, or if you're going to use bundler or something better, set that up with those gems
8. Run it with `ruby ebook.rb` a few times
9. Schedule it to run regularly with cron. I'd suggest once every 53 minutes or so: `*/53   *   *   *   *   ruby /home/USER/scripts/USER_ebooks/ebook.rb  > /dev/null 2>&1`

## Configuration

There are several parameters that control the behavior of the bot. You can override them by setting them in `twitter_init.rb`.

```
$rand_limit = 10
```

The bot does not run on every invocation. It runs in a pseudorandom fashion whenever `rand($rand_limit) == 0`. You can override it to make it more or less frequent. To make it run every time, you can set it to 0. You can also bypass it on a single invocation by passing `-f`.

```
$include_urls = false
```

By default, the bot ignores any tweets with URLs in them because those might just be headlines for articles and not text you've written. If you want to use them, you can set this parameter to true.

```
$markov_index = 2
```

The Markov index is a measure of associativity in the generated Markov chains. I'm not going to go into the theory, but 1 is generally more incoherent and 3 is more lucid.

## Command-line options (debugging)

* `--no-tweet`: Do not post anything to Twitter.
* `-f`; `--force`: Run the algorithm this time (bypasses the once-every-`n`-times pseudorandom logic).
