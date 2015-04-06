# FakeBsmobil

FakeBsmobil is Ruby implementation of Fake Banc Sabadell API.

Useful for testing client libraries.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fake_bsmobil'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fake_bsmobil

## Usage


```ruby
run FakeBsmobil.freeze.app
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## TODO

- Instead of generating new CC, Account, Movements, etc. info, have a data store

## Contributing

1. Fork it ( https://github.com/mikz/fake_bsmobil/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
