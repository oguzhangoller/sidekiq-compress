# Sidekiq::Compress

Although it is a bad practice, one might have to pass huge string params to it's sidekiq worker, bloating redis memory. For such cases, *sidekiq-compress* can be used to compress worker's string parameters before pushing them to redis. When retrieving workers params from redis back, it decompresses compressed data and passes it to worker.  

This gem compresses sidekiq string params using facebook's [zstd](https://github.com/facebook/zstd) compression algorithm and thus reduces redis memory usage.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-compress'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq-compress

## Usage

To use, add sidekiq-compress to the middleware chains, it can be done following way:

```
Sidekiq.configure_server do |config|
  Sidekiq::Compress.configure_server_middleware config
end

Sidekiq.configure_client do |config|
  Sidekiq::Compress.configure_client_middleware config
end
```

And in your worker:

```ruby
class MyJob
  include Sidekiq::Worker
  include Sidekiq::Compress::Worker # compresses all string job params

  def perform(*args)
  # your code goes here
  end
end
```

Optionally, you can state explicitly which string params to compress with compress_params keyword:

```ruby
class MyJob
  include Sidekiq::Worker
  include Sidekiq::Compress::Worker # compresses string job params
  
  compress_params index: [0,2]

  def perform(param1, param2, param3) # only param1 and param3 is compressed
  # your code goes here
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sidekiq-compress. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sidekiq::Compress project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/sidekiq-compress/blob/master/CODE_OF_CONDUCT.md).
