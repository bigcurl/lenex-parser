# frozen_string_literal: true

# Run with `bundle exec ruby examples/parse_example_gesamt.rb`
# Parses the combined gesamt export and prints the full object tree.

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'lenex-parser'

full_export_path = File.expand_path('lxf_gesamt.lxf', __dir__)
lenex = Lenex::Parser.parse(full_export_path)

pp lenex
puts "Parsed LENEX document from #{full_export_path}:"
