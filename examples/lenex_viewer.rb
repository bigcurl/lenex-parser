# frozen_string_literal: true

# Run with `bundle exec ruby examples/parse_example_gesamt.rb [PATH]`
# Parses the combined gesamt export and prints the full object tree.
#
# When PATH is omitted the bundled `lxf_gesamt.lxf` fixture is parsed.
# Passing `-` as PATH reads the LENEX document from standard input.

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'lenex-parser'

default_export_path = File.expand_path('lxf_gesamt.lxf', __dir__)

if ARGV.length > 1
  warn 'Usage: bundle exec ruby examples/parse_example_gesamt.rb [PATH|-]'
  exit 1
end

source_argument = ARGV.first

source, source_label = if source_argument.nil? || source_argument.empty?
                         [default_export_path, default_export_path]
                       elsif source_argument == '-'
                         [$stdin.tap(&:binmode), 'standard input']
                       else
                         candidate_path = File.expand_path(source_argument)

                         unless File.file?(candidate_path)
                           warn "No such LENEX file: #{source_argument}"
                           exit 1
                         end

                         [candidate_path, candidate_path]
                       end

lenex = Lenex::Parser.parse(source)

pp lenex
puts "Parsed LENEX document from #{source_label}:"
