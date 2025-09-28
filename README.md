# Lenex Parser

Lenex Parser is a fast and lightweight SAX parser designed for the Lenex 3 file format used in swimming data exchange.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lenex-parser'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install lenex-parser
```

## Usage

```ruby
require 'lenex/parser'

xml = File.read('meet.lenex')

lenex = Lenex::Parser.parse(xml)

puts "Lenex version: #{lenex.version}"
puts "Revision: #{lenex.revision}"
puts "Built by: #{lenex.constructor.name} (#{lenex.constructor.version})"
puts "Contact email: #{lenex.constructor.contact.email}"
```

`Lenex::Parser.parse` accepts any IO-like object (such as a `File` opened in binary mode) or a raw XML string.

### Object model overview

The parser returns a `Lenex::Parser::Objects::Lenex` instance that exposes the top-level metadata of the Lenex file:

- `version` – Lenex schema version string declared in the `<LENEX>` root element.
- `revision` – Revision identifier provided by the source system.
- `constructor` – A `Lenex::Parser::Objects::Constructor` with information about who produced the file.
- `meets` – Array of `Lenex::Parser::Objects::Meet` describing meet level information found under `<MEETS>`.

The constructor object provides these accessors:

- `name` – Application or organisation name responsible for generating the export.
- `registration` – Registration number reported in the `<CONSTRUCTOR>` element.
- `version` – Constructor application version string.
- `contact` – A `Lenex::Parser::Objects::Contact` containing communication details for the file creator.

The contact object yields:

- `email` – Email address for follow-up questions.
- `phone` – Optional phone number if available.
- `fax` – Optional fax number.
- `name` – Contact person's full name when supplied.

The meet object exposes:

- `name` – Required meet name taken from the `<MEET>` element.
- `city` – Required meet city name.
- `nation` – Required meet nation code.
- `course` – Optional course attribute describing the pool length.
- `contact` – Optional `Lenex::Parser::Objects::Contact` for the meet organiser when provided.
- `clubs` – Array of `Lenex::Parser::Objects::Club` objects describing participating clubs.
- `sessions` – Array of `Lenex::Parser::Objects::Session` objects capturing the meet schedule.

The club object exposes:

- `name` – Full club name when provided (required unless the club type is `UNATTACHED`).
- `name_en` – Optional English representation of the club name.
- `shortname` / `shortname_en` – Optional abbreviated names for local and English contexts.
- `code` – Optional national federation club code.
- `nation` – Optional federation nation code for the club.
- `number` – Optional differentiator used when a club fields multiple teams.
- `region` – Optional code for the regional swimming committee.
- `swrid` – Optional SwimRankings.net identifier.
- `type` – Optional classification such as `CLUB`, `NATIONALTEAM`, `REGIONALTEAM`, or `UNATTACHED`.
- `contact` – Optional `Lenex::Parser::Objects::Contact` with meet-specific club contact details.

The session object exposes:

- `number` – Required session number unique within a meet.
- `date` – Required session date in `YYYY-MM-DD` format.
- `course` – Optional pool length overriding the meet-wide course.
- `daytime` – Optional start time for the session.
- `endtime` – Optional time the session finished.
- `max_entries_athlete` – Optional limit on individual entries per athlete for the session.
- `max_entries_relay` – Optional limit on relay entries per club for the session.
- `name` – Optional descriptive session name (e.g., "Day 1 – Prelims").
- `official_meeting` – Optional meeting time for officials.
- `remarks_judge` – Optional referee remarks.
- `team_leader_meeting` – Optional meeting time for team leaders.
- `timing` – Optional timing system information for the session.
- `touchpad_mode` – Optional touchpad mode description.
- `warmup_from` / `warmup_until` – Optional warm-up window times.
- `pool` – Optional `Lenex::Parser::Objects::Pool` describing the lane configuration and environment of the competition pool.
- `judges` – Array of `Lenex::Parser::Objects::Judge` objects covering the meet officials attached to the session.
- `events` – Array of `Lenex::Parser::Objects::Event` objects with the events contested in the session.

The event object exposes:

- `event_id` – Required identifier unique across all events in a meet (sourced from the `eventid` attribute).
- `number` – Required event number within the meet program.
- `gender` – Optional gender designator (`A`, `M`, `F`, or `X`).
- `round` – Optional round identifier such as `PRE`, `SEM`, or `FIN`.
- `daytime` – Optional scheduled start time for the event.
- `max_entries` – Optional maximum number of entries per club for the event.
- `order` – Optional event order overriding the numeric sequence when necessary.
- `previous_event_id` – Optional identifier of the preceding round for finals progression.
- `run` – Optional swim-off run counter.
- `timing` – Optional timing type overriding the session defaults.
- `type` – Optional event classification (e.g., `MASTERS`).
- `fee` – Optional `Lenex::Parser::Objects::Fee` representing the event specific entry fee.
- `swim_style` – `Lenex::Parser::Objects::SwimStyle` describing the stroke, distance, and relay composition of the event.
- `age_groups` – Array of `Lenex::Parser::Objects::AgeGroup` objects defining eligible age ranges.
- `heats` – Array of `Lenex::Parser::Objects::Heat` objects describing detailed start lists.
- `time_standard_refs` – Array of `Lenex::Parser::Objects::TimeStandardRef` objects referencing applicable time standard lists and optional fines.

The heat object exposes:

- `heat_id` – Required identifier unique across all heats within a meet (from the `heatid` attribute).
- `number` – Required heat number unique within an event.
- `age_group_id` – Optional reference to an age group that the heat belongs to.
- `daytime` – Optional scheduled start time for the heat.
- `final` – Optional final designator (`A`, `B`, `C`, or `D`).
- `order` – Optional order override when heats do not run sequentially.
- `status` – Optional heat status such as `SCHEDULED`, `SEEDED`, `INOFFICIAL`, or `OFFICIAL`.

The age group object exposes:

- `age_group_id` – Required identifier unique within the event, referenced by entries.
- `age_max` – Required upper bound of the age range (`-1` indicates no upper bound).
- `age_min` – Required lower bound of the age range (`-1` indicates no lower bound).
- `calculate` – Optional calculation mode for relay totals (`SINGLE` or `TOTAL`).
- `gender` – Optional gender limitation for the age group (`A`, `M`, `F`, or `X`).
- `handicap` – Optional para-swimming handicap class grouping.
- `level_max` / `level_min` – Optional bounds restricting athlete levels.
- `levels` – Optional comma-separated list of explicitly allowed athlete levels.
- `name` – Optional display name for the age group (e.g., "Juniors").
- `rankings` – Array of `Lenex::Parser::Objects::Ranking` objects capturing the final placements for the age group within the event.

The swim style object exposes:

- `distance` – Required event distance in meters for each competitor (per-leg distance for relays).
- `relay_count` – Required number of swimmers per entry (use `1` for individual events).
- `stroke` – Required stroke enumeration for the event (e.g., `FREE`, `BACK`, `MEDLEY`).
- `code` – Optional short code to distinguish custom swim styles when the stroke is `UNKNOWN`.
- `name` – Optional descriptive name for unusual swim styles.
- `swim_style_id` – Optional identifier to uniquely track special swim styles across the meet.
- `technique` – Optional technique modifier (e.g., `KICK`, `TURN`) for skill-specific events.

The fee object exposes:

- `currency` – Optional three-letter currency code describing the fee currency.
- `type` – Optional fee classification (e.g., `ATHLETE`, `RELAY`, `CLUB`) used in the context of fee collections.
- `value` – Required monetary value expressed in cents.

The ranking object exposes:

- `place` – Required final place within the rankings list.
- `result_id` – Required identifier referencing the associated result entry.
- `order` – Optional explicit ordering override for ranking presentation.

The pool object exposes:

- `lane_min` – Optional first lane number used during the meet or session.
- `lane_max` – Optional last lane number available for competition.
- `temperature` – Optional reported water temperature.
- `type` – Optional venue type (e.g., `INDOOR`, `OUTDOOR`, `LAKE`, `OCEAN`).

The judge object exposes:

- `official_id` – Required identifier referencing the official in the meet's official list.
- `number` – Optional sequencing or lane assignment for the judge.
- `role` – Optional role descriptor reflecting the official's duties (e.g., `REF`, `TIK`).
- `remarks` – Optional free-form remarks about the assignment.

The time standard reference object exposes:

- `time_standard_list_id` – Required identifier pointing to the referenced time standard list.
- `marker` – Optional string used to annotate results that met or missed the referenced time standard.
- `fee` – Optional `Lenex::Parser::Objects::Fee` describing fines or penalties linked to the time standard reference.

The athlete object exposes:

- `athlete_id` – Required identifier unique to the athlete within the meet.
- `birthdate` – Required birth date of the athlete in `YYYY-MM-DD` format.
- `first_name` / `first_name_en` – Required first name and optional English variant.
- `last_name` / `last_name_en` – Required last name and optional English variant.
- `gender` – Required gender flag (`M` or `F`).
- `level` – Optional athlete level string.
- `license` / `license_ipc` – Optional federation and IPC license identifiers.
- `name_prefix` – Optional surname prefix (e.g., "van den").
- `nation` – Optional athlete nation code.
- `passport` – Optional passport number.
- `status` – Optional status flag such as `ROOKIE`, `FOREIGNER`, or `EXHIBITION`.
- `swrid` – Optional SwimRankings.net identifier.
- `entries` – Array of `Lenex::Parser::Objects::Entry` representing the athlete's entries.
- `results` – Array of `Lenex::Parser::Objects::Result` representing the athlete's results.

The entry object exposes:

- `event_id` – Required reference to the event the entry belongs to.
- `entry_time` – Optional entry time string.
- `status` – Optional status flag such as `SICK` or `WDR`.
- `lane` – Optional assigned lane number.
- `heat_id` – Optional reference to the scheduled heat.
- `age_group_id` – Optional reference to the event age group.
- `entry_course` – Optional pool length for the entry time.
- `entry_distance` – Optional entry distance in centimetres for fin-swimming events.
- `handicap` – Optional para-swimming sport class override.
- `meet_info` – Optional `Lenex::Parser::Objects::MeetInfo` describing when the entry time was achieved.

The meet info object exposes:

- `approved` – Optional approving organisation code (e.g., `AQUA`, `LEN`).
- `city` / `state` – Optional city and state where the time was achieved.
- `course` – Optional pool length used for the entry or record.
- `date` – Optional date when the time was achieved.
- `daytime` – Optional time of day when the swim occurred.
- `name` – Optional meet name.
- `nation` – Optional nation code for the city.
- `qualification_time` – Optional qualifying time differing from the entry time.
- `timing` – Optional timing system used for the swim.
- `pool` – Optional `Lenex::Parser::Objects::Pool` describing the pool where the time was achieved.

The result object exposes:

- `result_id` – Required identifier unique to the result within the meet.
- `swim_time` – Required final swim time string or `NT`.
- `status` – Optional status flag such as `DSQ`, `DNS`, or `EXH`.
- `comment` – Optional free-text comment (e.g., new record remarks).
- `event_id` – Optional reference to the event.
- `heat_id` – Optional reference to the heat.
- `lane` – Optional lane number.
- `points` – Optional points scored for the swim.
- `reaction_time` – Optional start reaction time for the swim.
- `handicap` – Optional para-swimming sport class override.
- `swim_distance` – Optional distance in centimetres for fin-swimming events.
- `splits` – Array of `Lenex::Parser::Objects::Split` describing split times.

The split object exposes:

- `distance` – Required split distance in meters.
- `swim_time` – Required split time for the distance in swim-time format.

### Error handling

Parsing issues raise `Lenex::Parser::ParseError`. This includes missing required elements or attributes, as well as XML syntax errors encountered while reading the document.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.

To run RuboCop:

```sh
bundle exec rubocop
```

To run tests with coverage:

```sh
bundle exec rake test:coverage
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/your_username/lenex-parser.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
