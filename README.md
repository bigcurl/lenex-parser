# Lenex Parser

Lenex Parser is a streaming Lenex 3 parser built on Nokogiri's SAX interface. It incrementally assembles the object graph without materialising the full DOM, keeping memory usage low even for multi-megabyte swim meet exports.

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

`Lenex::Parser.parse` accepts any IO-like object (such as a `File` opened in binary mode) or a raw XML string. When given an IO it reads chunk-by-chunk, emitting SAX events into the builder so the full XML tree is never loaded at once.

### Building documents incrementally

The gem also exposes a lightweight `Lenex::Document` model for callers that need to build Lenex payloads programmatically before exporting them. The class mirrors the `<LENEX>` root element and provides helpers for accumulating constructor metadata as well as meet, record list, and time-standard list entries.

```ruby
require 'lenex/document'
require 'lenex/parser/objects'

document = Lenex::Document.new

document.constructor[:name] = 'LENEX Builder'
document.constructor[:version] = '1.2.3'

meet = Lenex::Parser::Objects::Meet.new(
  name: 'City Championships',
  city: 'Berlin',
  nation: 'GER'
)

document.add_meet(meet)

document.record_lists # => []
document.time_standard_lists # => []
```

`Lenex::Document::ConstructorMetadata` normalizes all keys to symbols so you can pass either strings or symbols when writing attributes (e.g., `constructor['contact'] = contact_details`). Each helper method returns the object you passed in, making it easy to chain builder flows.
### Parsing zipped Lenex files

`Lenex::Parser.parse` also recognises ZIP archives that contain a `.lef` or `.xml` payload and automatically extracts the first matching file. This makes it easy to work with the compressed exports that many federation systems produce:

```ruby
require 'lenex/parser'

zip_data = File.binread('meet.lenex.zip')

lenex = Lenex::Parser.parse(zip_data)
puts lenex.constructor.name
```

The parser lazily loads the optional `rubyzip` dependency the first time a ZIP archive is encountered. Install it ahead of time with `gem install rubyzip` (or add it to your Gemfile) to keep parsing seamless in production environments.

### Object model overview

The parser returns a `Lenex::Parser::Objects::Lenex` instance that exposes the top-level metadata of the Lenex file:

- `version` – Lenex schema version string declared in the `<LENEX>` root element.
- `revision` – Revision identifier provided by the source system.
- `constructor` – A `Lenex::Parser::Objects::Constructor` with information about who produced the file.
- `meets` – Array of `Lenex::Parser::Objects::Meet` describing meet level information found under `<MEETS>`.
- `record_lists` – Array of `Lenex::Parser::Objects::RecordList` objects representing the `<RECORDLISTS>` section when present.
- `time_standard_lists` – Array of `Lenex::Parser::Objects::TimeStandardList` objects representing `<TIMESTANDARDLISTS>` when supplied.

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
- `name_en` – Optional English representation of the meet name.
- `city` – Required meet city name.
- `city_en` – Optional English representation of the meet city.
- `nation` – Required meet nation code.
- `course` – Optional course attribute describing the pool length.
- `entry_type` – Optional classification describing whether the meet accepts open or invitation-only entries.
- `max_entries_athlete` – Optional limit on individual entries per athlete for the entire meet.
- `max_entries_relay` – Optional limit on relay entries per club for the entire meet.
- `reserve_count` – Optional number of reserve swimmers tracked for finals.
- `start_method` – Optional start method flag (`1` for one-start, `2` for two-start procedures).
- `timing` – Optional timing system information recorded at the meet level.
- `touchpad_mode` – Optional description of the touchpad installation.
- `type` – Optional meet classification supplied by the federation.
- `altitude` – Optional venue altitude in metres above sea level.
- `swrid` – Optional SwimRankings.net identifier for the meet.
- `result_url` – Optional URL pointing to published meet results.
- `contact` – Optional `Lenex::Parser::Objects::Contact` for the meet organiser when provided.
- `age_date` – Optional `Lenex::Parser::Objects::AgeDate` describing how to calculate athlete ages for the meet.
- `bank` – Optional `Lenex::Parser::Objects::Bank` containing payment instructions for entry fees.
- `facility` – Optional `Lenex::Parser::Objects::Facility` describing the venue address.
- `point_table` – Optional `Lenex::Parser::Objects::PointTable` identifying the scoring system in use.
- `qualify` – Optional `Lenex::Parser::Objects::Qualify` outlining qualification period and conversion rules.
- `pool` – Optional `Lenex::Parser::Objects::Pool` describing lane configuration when the meet defines a default pool.
- `fee_schedule` – Optional `Lenex::Parser::Objects::FeeSchedule` containing global meet fee definitions.
- `host_club` – Optional `Lenex::Parser::Objects::HostClub` with information about the executing organisation.
- `organizer` – Optional `Lenex::Parser::Objects::Organizer` describing the promoting body.
- `entry_schedule` – Optional `Lenex::Parser::Objects::EntrySchedule` capturing entry start dates, deadlines, and withdrawal cut-offs.
- `clubs` – Array of `Lenex::Parser::Objects::Club` objects describing participating clubs.
- `sessions` – Array of `Lenex::Parser::Objects::Session` objects capturing the meet schedule.

The age date object exposes:

- `type` – Required strategy for calculating ages (e.g., `YEAR`, `DATE`).
- `value` – Optional reference date when the calculation requires a specific day.

The bank object exposes:

- `account_holder` – Optional name attached to the bank account.
- `bic` – Optional bank identifier code.
- `iban` – Required IBAN for the receiving account.
- `name` – Optional bank name.
- `note` – Optional payment note or reference instructions.

The facility object exposes:

- `city` – Required city containing the venue.
- `nation` – Required nation code for the facility location.
- `name` – Optional display name of the venue.
- `state` – Optional state, province, or region for the venue.
- `street` / `street2` – Optional address lines.
- `zip` – Optional postal code for the facility.

The point table object exposes:

- `name` – Required name of the scoring system.
- `point_table_id` – Optional identifier for well-known point tables.
- `version` – Required edition or year of the scoring system.

The qualify object exposes:

- `conversion` – Optional conversion method applied to entry times.
- `from` – Required start date of the qualification window.
- `percent` – Optional percentage used when conversion requires it.
- `until` – Optional end date of the qualification window.

The host club object exposes:

- `name` – Host club name responsible for executing the meet.
- `url` – Optional URL pointing to the host club's website.

The organizer object exposes:

- `name` – Organization that promotes the meet.
- `url` – Optional URL with more details about the organizer.

The entry schedule object exposes:

- `entry_start_date` – Optional date when entries open.
- `withdraw_until` – Optional date by which withdrawals must be submitted.
- `deadline_date` – Optional entry deadline date.
- `deadline_time` – Optional entry deadline time.

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
- `fee_schedule` – Optional `Lenex::Parser::Objects::FeeSchedule` containing session-specific fee overrides.
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

The fee schedule object exposes:

- `fees` – Array of `Lenex::Parser::Objects::Fee` instances contained in the surrounding `<FEES>` collection.

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
- `handicap` – Optional `Lenex::Parser::Objects::Handicap` detailing para-swimming classifications for the athlete.
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

The handicap object exposes:

- `breast` – Required breaststroke sport class (matching SB codes).
- `breast_status` – Optional confirmation status for the breaststroke class.
- `exception` – Optional comma-separated exception codes as defined by WPS rules.
- `free` – Required freestyle/backstroke/fly sport class (matching S codes).
- `free_status` – Optional confirmation status for the freestyle/backstroke/fly class.
- `medley` – Required individual medley sport class (matching SM codes).
- `medley_status` – Optional confirmation status for the individual medley class.

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

The relay object exposes:

- `age_max` – Required maximum age for the oldest swimmer on the relay team.
- `age_min` – Required minimum age for the youngest swimmer on the relay team.
- `age_total_max` – Required maximum combined age for all swimmers on the team.
- `age_total_min` – Required minimum combined age for all swimmers on the team.
- `gender` – Required gender classification for the relay (`M`, `F`, or `X`).
- `handicap` – Optional para-swimming relay handicap classification.
- `name` – Optional descriptive team name (e.g., "Mixed Medley A").
- `number` – Optional team number used when clubs field multiple relays in the same age group.
- `relay_positions` – Array of `Lenex::Parser::Objects::RelayPosition` describing the swimmers ordered within the relay.
- `entries` – Array of `Lenex::Parser::Objects::RelayEntry` with the relay's scheduled starts.
- `results` – Array of `Lenex::Parser::Objects::RelayResult` summarising the relay's outcomes.

The relay entry object exposes:

- `event_id` – Required reference to the event contested by the relay team.
- `entry_time` – Optional entry time string for seeding.
- `status` – Optional status flag describing the relay entry (`EXH`, `RJC`, `SICK`, or `WDR`).
- `lane` – Optional assigned lane number.
- `heat_id` – Optional reference to the scheduled heat.
- `age_group_id` – Optional reference to the event age group.
- `entry_course` – Optional pool length for the entry time.
- `entry_distance` – Optional entry distance in centimetres for fin-swimming events.
- `handicap` – Optional relay sport-class override.
- `meet_info` – Optional `Lenex::Parser::Objects::MeetInfo` describing where the qualifying swim occurred.
- `relay_positions` – Array of `Lenex::Parser::Objects::RelayPosition` representing the swimmers declared for the entry.

The relay result object exposes:

- `result_id` – Required identifier for the relay result within the meet.
- `swim_time` – Required final relay time string (or `NT`).
- `status` – Optional status flag such as `DSQ`, `DNS`, `DNF`, `SICK`, `WDR`, or `EXH`.
- `comment` – Optional free-text comment (e.g., new record notes).
- `event_id` – Optional reference to the event contested.
- `heat_id` – Optional reference to the heat.
- `lane` – Optional lane number.
- `points` – Optional points earned for the swim.
- `reaction_time` – Optional reaction time of the lead-off swimmer.
- `handicap` – Optional relay sport-class override.
- `swim_distance` – Optional distance in centimetres for fin-swimming events.
- `splits` – Array of `Lenex::Parser::Objects::Split` objects for the relay's split times.
- `relay_positions` – Array of `Lenex::Parser::Objects::RelayPosition` representing the swimmers who swam the race.

The relay position object exposes:

- `athlete_id` – Optional reference to the athlete representing a leg of the relay.
- `number` – Required leg number (1 for lead-off; `-1` for alternates).
- `reaction_time` – Optional reaction or takeover time for the leg.
- `status` – Optional status flag such as `DSQ` or `DNF` for the swimmer.
- `athlete` – Optional embedded `Lenex::Parser::Objects::Athlete` used when relay swimmers are inlined (e.g., records).
- `meet_info` – Optional `Lenex::Parser::Objects::MeetInfo` with the qualification details for the swimmer.

The official object exposes:

- `official_id` – Required identifier unique to the official within the meet.
- `first_name` – Required first name of the official.
- `last_name` – Required last name of the official.
- `gender` – Optional gender marker (`M` or `F`).
- `grade` – Optional certification grade supplied by the federation.
- `license` – Optional federation-issued license number.
- `name_prefix` – Optional surname prefix (e.g., "van den").
- `nation` – Optional nation code of the official.
- `passport` – Optional passport identifier.
- `contact` – Optional `Lenex::Parser::Objects::Contact` describing how to reach the official.

The record list object exposes:

- `course` – Required pool length for records in the list.
- `gender` – Required gender classification for the contained records.
- `handicap` – Optional handicap classification for para records.
- `name` – Required human readable list name (e.g., "World Records").
- `nation` – Optional federation nation code for the records.
- `order` – Optional ordering hint when multiple lists appear.
- `region` – Optional region code for regional record lists.
- `type` – Optional record type identifier such as `WR` or `ER`.
- `updated` – Optional date the record list was last updated.
- `age_group` – Optional `Lenex::Parser::Objects::AgeGroup` describing the age category covered by the list.
- `records` – Array of `Lenex::Parser::Objects::Record` entries within the list.

The record object exposes:

- `swim_time` – Required record time string.
- `status` – Optional approval status such as `APPROVED` or `PENDING`.
- `comment` – Optional free-text comment about the record.
- `meet_info` – Optional `Lenex::Parser::Objects::MeetInfo` describing where the performance occurred.
- `swim_style` – Optional `Lenex::Parser::Objects::SwimStyle` describing the stroke and distance.
- `athlete` – Optional `Lenex::Parser::Objects::RecordAthlete` when the record is held by an individual.
- `relay` – Optional `Lenex::Parser::Objects::RecordRelay` when the record is held by a relay team.
- `splits` – Array of `Lenex::Parser::Objects::Split` objects containing available split times.

The record athlete object exposes:

- `athlete_id` – Optional identifier supplied when the record references a meet athlete id.
- `birthdate` – Required birth date of the athlete in `YYYY-MM-DD` format.
- `first_name` / `first_name_en` – Required first name and optional English variant.
- `last_name` / `last_name_en` – Required last name and optional English variant.
- `gender` – Required gender flag (`M` or `F`).
- `level` – Optional athlete level string.
- `license` / `license_ipc` – Optional federation and IPC license identifiers.
- `name_prefix` – Optional surname prefix (e.g., "van den").
- `nation` – Optional nation code.
- `passport` – Optional passport number.
- `status` – Optional status flag such as `ROOKIE` or `FOREIGNER`.
- `swrid` – Optional SwimRankings.net identifier.
- `club` – Optional `Lenex::Parser::Objects::Club` describing the athlete's club when the export provides it.

The record relay object exposes:

- `name` – Optional descriptive relay name.
- `club` – Optional `Lenex::Parser::Objects::Club` representing the relay's club affiliation.
- `relay_positions` – Array of `Lenex::Parser::Objects::RecordRelayPosition` describing the swimmers listed with the record.

The record relay position object exposes:

- `number` – Required swimmer order within the relay (1 for the first swimmer).
- `reaction_time` – Optional reaction or takeover time for the swimmer.
- `status` – Optional status such as `DSQ` for the swimmer's leg.
- `athlete` – Required `Lenex::Parser::Objects::RecordAthlete` describing the swimmer attached to the record.

The time standard list object exposes:

- `time_standard_list_id` – Required identifier unique to the time standard list.
- `name` – Required descriptive label for the list (e.g., "Olympic A").
- `course` – Required course designation matching the covered pool length.
- `gender` – Required gender classification (`M`, `F`, or `X`).
- `handicap` – Optional handicap classification when the list targets para swimmers.
- `type` – Optional behaviour flag indicating whether entries must be faster (`MAXIMUM`), slower (`MINIMUM`), or use the list as a fallback (`DEFAULT`).
- `age_group` – Optional `Lenex::Parser::Objects::AgeGroup` specifying the eligible ages.
- `time_standards` – Array of `Lenex::Parser::Objects::TimeStandard` entries contained in the list.

The time standard object exposes:

- `swim_time` – Required benchmark time string to compare entries against.
- `swim_style` – `Lenex::Parser::Objects::SwimStyle` describing the distance, stroke, and relay composition tied to the standard.

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
