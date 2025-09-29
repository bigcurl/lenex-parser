# Example scripts

This directory contains executable scripts that demonstrate how to use the library as a document builder and as a streaming parser.

## Available scripts

- `builder_and_parser.rb` – Builds a minimal `Lenex::Document` and parses a small Lenex XML payload.

## Running the examples

From the repository root run:

```sh
bundle exec ruby examples/builder_and_parser.rb
```

The script adjusts the `$LOAD_PATH` so it can load the gem straight from the repository. When the gem is installed from RubyGems you can omit that line and simply `require 'lenex-parser'`.
