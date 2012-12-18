# QQWry

A Ruby interface to QQWry IP database.

## Installation

Add this line to your application's Gemfile:

    gem 'qqwry'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install qqwry

## Usage

At first, you need to get the latest QQWry IP database from http://www.cz88.net

````ruby
require 'rubygems'
require 'bundler/setup'
require 'qqwry'

db = QQWry::Database.new('QQWry.Dat')
r = db.query('8.8.8.8')
puts "#{r.country} #{r.area}"
````

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
