# frozen_string_literal: true

# Run this script with `bundle exec ruby examples/builder_and_parser.rb`
# to see how to construct Lenex documents programmatically and how to
# parse Lenex XML.

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'lenex-parser'

puts '--- Building a Lenex document ---'

document = Lenex::Document.new
document.version = '3.0'

document.constructor[:name] = 'My Lenex Builder'
document.constructor[:registration] = 'LENEX'
document.constructor[:version] = '1.0.0'
document.constructor[:contact] = {
  email: 'support@example.com',
  phone: '+49 30 12345678'
}

meet = Lenex::Parser::Objects::Meet.new(
  name: 'City Championships',
  city: 'Berlin',
  nation: 'GER'
)

document.add_meet(meet)

puts "Constructor name: #{document.constructor[:name]}"
puts "Total meets added: #{document.meets.length}"

puts '\n--- Parsing Lenex XML ---'

xml_payload = <<~XML
  <LENEX version="3.0" revision="2023">
    <CONSTRUCTOR name="Demo Parser" registration="LENEX" version="1.2.3">
      <CONTACT email="lenex@example.com" />
    </CONSTRUCTOR>
    <MEETS>
      <MEET name="Spring Invitational" city="Hamburg" nation="GER">
        <SESSIONS>
          <SESSION number="1" date="2024-04-01">
            <EVENTS>
              <EVENT eventid="1" number="1">
                <SWIMSTYLE distance="100" relaycount="1" stroke="FREE" />
              </EVENT>
            </EVENTS>
          </SESSION>
        </SESSIONS>
      </MEET>
    </MEETS>
  </LENEX>
XML

lenex = Lenex::Parser.parse(xml_payload)

puts "Parsed version: #{lenex.version}"
puts "Parsed meet count: #{lenex.meets.count}"
puts "First meet city: #{lenex.meets.first.city}"
