# Example scripts

This directory contains executable scripts that demonstrate how to use the library as a document builder and as a streaming parser.

## Available scripts

- `builder_and_parser.rb` – Builds a minimal `Lenex::Document` and parses a small Lenex XML payload.
- `parse_example_entries.rb` – Streams `example-entries.lxf` and reports meet, athlete and entry counts.
- `parse_example_results.rb` – Reads `example-results.lxf` and summarises the first recorded swim.
- `parse_example_startlist.rb` – Loads `example-startlist.lxf` and prints the first heat's lane assignments.
- `parse_example_records.rb` – Parses `example-records.lxf` and highlights the leading record in the first list.

## Running the examples

From the repository root run any script with:

```sh
bundle exec ruby examples/<script_name>.rb
```

Each script adjusts the `$LOAD_PATH` so it can load the gem straight from the repository. When the gem is installed from RubyGems you can omit that line and simply `require 'lenex-parser'`.
