# frozen_string_literal: true

# Run with `bundle exec ruby examples/parse_example_records.rb`
# Parses the record archive and prints details about the first list.

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'lenex-parser'

records_path = File.expand_path('example-records.lxf', __dir__)
lenex = Lenex::Parser.parse(records_path)

record_lists = lenex.record_lists
puts "Record lists: #{record_lists.length}"

first_list = record_lists.first
if first_list
  puts
  puts "First list: #{first_list.name}"
  puts "  Course: #{first_list.course}"
  puts "  Gender: #{first_list.gender}" if first_list.gender
  puts "  Records: #{first_list.records.length}"

  if (age_group = first_list.age_group)
    range = [age_group.age_min, age_group.age_max].compact.join('–')
    range = 'all ages' if range.empty?
    puts "  Age group: #{range}"
  end

  record = first_list.records.first
  if record
    swim_style = record.swim_style
    puts
    puts "Fastest swim: #{record.swim_time}"
    puts "  Event: #{swim_style.distance}m #{swim_style.stroke}"

    if (athlete = record.athlete)
      athlete_name = [athlete.first_name, athlete.last_name].compact.join(' ').strip
      athlete_name = 'Unknown athlete' if athlete_name.empty?
      puts "  Athlete: #{athlete_name}"
      puts "  Nation: #{athlete.nation}" if athlete.nation
    elsif (relay = record.relay)
      puts "  Relay: #{relay.name}"
      puts "  Nation: #{relay.club&.nation}" if relay.club&.nation
    end
  end
end
