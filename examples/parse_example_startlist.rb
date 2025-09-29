# frozen_string_literal: true

# Run with `bundle exec ruby examples/parse_example_startlist.rb`
# Parses the published start list and prints the lane assignments for the
# first heat.

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'lenex-parser'

startlist_path = File.expand_path('example-startlist.lxf', __dir__)
lenex = Lenex::Parser.parse(startlist_path)

meet = lenex.meets.fetch(0)
sessions = meet.sessions
events = sessions.flat_map(&:events)
heats = events.flat_map(&:heats)

puts "Meet: #{meet.name}"
location = [meet.city, meet.nation].compact.join(', ')
puts "Location: #{location}" unless location.empty?
puts "Sessions: #{sessions.length}"
puts "Events: #{events.length}"
puts "Heats: #{heats.length}"

first_event = events.first
first_heat = first_event&.heats&.first

if first_event && first_heat
  swim_style = first_event.swim_style
  puts
  puts "First event: #{first_event.event_id} – #{swim_style.distance}m #{swim_style.stroke}"
  puts "Heat ##{first_heat.number}"

  athletes = meet.clubs.flat_map(&:athletes)
  lane_assignments = athletes.flat_map do |athlete|
    athlete.entries.map { |entry| [athlete, entry] }
  end

  lane_assignments = lane_assignments.select do |(_, entry)|
    entry.heat_id == first_heat.heat_id
  end
  lane_assignments.sort_by! { |(_, entry)| entry.lane.to_i }

  lane_assignments.each do |athlete, entry|
    name = [athlete.first_name, athlete.last_name].compact.join(' ').strip
    name = 'Unknown athlete' if name.empty?
    lane = entry.lane || 'n/a'
    seed_time = entry.entry_time || 'n/a'
    puts "  Lane #{lane}: #{name} – seed #{seed_time}"
  end
end
