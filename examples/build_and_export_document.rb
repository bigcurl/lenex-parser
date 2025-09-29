# frozen_string_literal: true

require 'lenex-parser'

constructor = Lenex::Parser::Objects::Constructor.new(
  name: 'Example LENEX Builder',
  registration: 'Example Org',
  version: '1.0.0',
  contact: Lenex::Parser::Objects::Contact.new(email: 'support@example.com')
)

meet = Lenex::Parser::Objects::Meet.new(
  name: 'City Championships',
  city: 'Berlin',
  nation: 'GER'
)

record_list = Lenex::Parser::Objects::RecordList.new(
  course: 'LCM',
  gender: 'M',
  name: 'National Records',
  records: [
    Lenex::Parser::Objects::Record.new(
      swim_time: '00:55.00',
      associations: {
        swim_style: Lenex::Parser::Objects::SwimStyle.new(
          distance: '100',
          relay_count: '1',
          stroke: 'FREE'
        )
      }
    )
  ]
)

time_standards = Lenex::Parser::Objects::TimeStandardList.new(
  course: 'LCM',
  gender: 'F',
  name: 'Qualifying Times',
  time_standard_list_id: 'TSL1',
  time_standards: [
    Lenex::Parser::Objects::TimeStandard.new(
      swim_time: '00:58.00',
      swim_style: Lenex::Parser::Objects::SwimStyle.new(
        distance: '100',
        relay_count: '1',
        stroke: 'FREE'
      )
    )
  ]
)

document = Lenex::Document.new(version: '3.0', revision: '1')
document.constructor = constructor
document.add_meet(meet)
document.add_record_list(record_list)
document.add_time_standard_list(time_standards)

xml = document.to_xml

# Persist the export or send it across the wire.
File.write('export.lenex', xml)

puts 'LENEX document written to export.lenex'
