# Lenex Parser

Lenex Parser is a fast and lightweight SAX parser designed for the Lenex 3 file format used in swimming data exchange.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lenex-parser'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install lenex-parser
```

## Usage

```ruby
require 'lenex/parser'

xml = File.read('meet.lenex')

lenex = Lenex::Parser.parse(xml)

puts "Lenex version: #{lenex.version}"
puts "Revision: #{lenex.revision}"
puts "Built by: #{lenex.constructor.name} (#{lenex.constructor.version})"
puts "Contact email: #{lenex.constructor.contact.email}"
```

`Lenex::Parser.parse` accepts any IO-like object (such as a `File` opened in binary mode) or a raw XML string.

### Object model overview

The parser returns a `Lenex::Parser::Objects::Lenex` instance that exposes the top-level metadata of the Lenex file:

- `version` – Lenex schema version string declared in the `<LENEX>` root element.
- `revision` – Revision identifier provided by the source system.
- `constructor` – A `Lenex::Parser::Objects::Constructor` with information about who produced the file.
- `meets` – Array of `Lenex::Parser::Objects::Meet` describing meet level information found under `<MEETS>`.

The constructor object provides these accessors:

- `name` – Application or organisation name responsible for generating the export.
- `registration` – Registration number reported in the `<CONSTRUCTOR>` element.
- `version` – Constructor application version string.
- `contact` – A `Lenex::Parser::Objects::Contact` containing communication details for the file creator.

The contact object yields:

- `email` – Email address for follow-up questions.
- `phone` – Optional phone number if available.
- `fax` – Optional fax number.
- `name` – Contact person's full name when supplied.

The meet object exposes:

- `name` – Required meet name taken from the `<MEET>` element.
- `city` – Required meet city name.
- `nation` – Required meet nation code.
- `course` – Optional course attribute describing the pool length.
- `contact` – Optional `Lenex::Parser::Objects::Contact` for the meet organiser when provided.

### Error handling

Parsing issues raise `Lenex::Parser::ParseError`. This includes missing required elements or attributes, as well as XML syntax errors encountered while reading the document.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.

To run RuboCop:

```sh
bundle exec rubocop
```

To run tests with coverage:

```sh
bundle exec rake test:coverage
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/your_username/lenex-parser.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
