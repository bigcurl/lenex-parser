# frozen_string_literal: true

# Run with `bundle exec ruby examples/parse_example_entries.rb`
# Parses the provided entries export and prints a small summary.

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'lenex-parser'

entries_path = File.expand_path('example-entries.lxf', __dir__)
lenex = Lenex::Parser.parse(entries_path)

meet = lenex.meets.fetch(0)
clubs = meet.clubs
athletes = clubs.flat_map(&:athletes)
entries = athletes.flat_map(&:entries)

puts "Meet: #{meet.name}"
location = [meet.city, meet.nation].compact.join(', ')
puts "Location: #{location}" unless location.empty?
puts "Clubs: #{clubs.length}"
puts "Athletes: #{athletes.length}"
puts "Entries: #{entries.length}"

entry_owner = athletes.find { |athlete| athlete.entries.any? }
if entry_owner
  entry = entry_owner.entries.first
  athlete_name = [entry_owner.first_name, entry_owner.last_name].compact.join(' ').strip
  athlete_name = 'Unknown athlete' if athlete_name.empty?

  puts
  puts 'First entry:'
  puts "  Athlete: #{athlete_name}"
  puts "  Event ID: #{entry.event_id || 'n/a'}"
  seed_time = entry.entry_time || 'n/a'
  course = entry.entry_course ? " (#{entry.entry_course})" : ''
  puts "  Seed time: #{seed_time}#{course}"

  if (meet_info = entry.meet_info)
    summary_parts = []
    summary_parts << meet_info.name if meet_info.name
    venue = [meet_info.city, meet_info.nation].compact.join(', ')
    summary_parts << venue unless venue.empty?
    summary_parts << meet_info.date if meet_info.date
    puts "  Qualified at: #{summary_parts.join(' – ')}" unless summary_parts.empty?
  end
end
