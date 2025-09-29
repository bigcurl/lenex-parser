# frozen_string_literal: true

# Run with `bundle exec ruby examples/parse_example_results.rb`
# Parses the sample results export and prints a short overview.

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'lenex-parser'

results_path = File.expand_path('example-results.lxf', __dir__)
lenex = Lenex::Parser.parse(results_path)

meet = lenex.meets.fetch(0)
sessions = meet.sessions
athletes = meet.clubs.flat_map(&:athletes)
results = athletes.flat_map(&:results)

puts "Meet: #{meet.name}"
location = [meet.city, meet.nation].compact.join(', ')
puts "Location: #{location}" unless location.empty?
puts "Sessions: #{sessions.length}"
puts "Athletes with results: #{athletes.count { |athlete| athlete.results.any? }}"
puts "Individual results: #{results.length}"

sample = results.first
if sample
  owner = athletes.find { |athlete| athlete.results.include?(sample) }
  athlete_name = [owner&.first_name, owner&.last_name].compact.join(' ').strip
  athlete_name = 'Unknown athlete' if athlete_name.empty?

  puts
  puts 'First recorded swim:'
  puts "  Event ID: #{sample.event_id || 'n/a'}"
  puts "  Athlete: #{athlete_name}"
  puts "  Swim time: #{sample.swim_time}"
  lane = sample.lane || 'n/a'
  puts "  Lane: #{lane}"
  reaction = sample.reaction_time || 'n/a'
  puts "  Reaction time: #{reaction}"
  entry_time = sample.entry_time || 'n/a'
  course = sample.entry_course ? " (#{sample.entry_course})" : ''
  puts "  Entry time: #{entry_time}#{course}"

  if (split = sample.splits.first)
    puts "  First split: #{split.distance}m in #{split.swim_time}"
  end
end
