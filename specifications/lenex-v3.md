# Lenex 3.0 Technical Specification (ChatGPT Edition)

> **Purpose.** Markdown transcription of the official Lenex 3.0 Technical Documentation for interactive use in ChatGPT conversations.
> **Source.** Derived from the SwimRankings Lenex 3.0 PDF; structure and wording are preserved where possible, with light editorial notes for clarity.
> **How to use.** Jump to a section with the quick navigation below, then drill into the detailed element tables. When in doubt, cross-reference §5 for data type legends.
> **Legend.** Attribute tables use the abbreviations documented in §5 (e.g., `r` = required attribute, `o` = optional).

## Quick navigation
- [1. General](#1-general)
- [2. Lenex files](#2-lenex-files)
- [3. Lenex tree](#3-lenex-tree)
- [4. Lenex element documentation](#4-lenex-element-documentation)
- [5. Lenex data types](#5-lenex-data-types)
- [6. Specific extensions for different federations](#6-specific-extensions-for-different-federations)
- [7. Frequently asked questions (FAQ)](#7-frequently-asked-questions-faq)
- [8. Version history](#8-version-history)

An international data exchange format for swimming.

## 1. General
A "Lenex" file is a XML file with some additional constraints, which cannot be defined with an XSD schema. Because of this, and to give programmers an easier to read document with additional information on the format, we have put together this "non-standard" kind of documentation for you.

## 2. Lenex files
A Lenex file is a XML file with the extension **.lef**. Usually, Lenex files are compressed (in the ZIP file format) and are labeled with the extension **.lxf**. A Lenex file can contain all kinds of data at the same time. However, when exchanging data, the following files with a subset of possible objects are commonly used:
  * **Invitation:** An invitation file contains general information, the schedule and the event structure of one meet. Additionally, it could be necessary or helpful to add time standards and/or qualification times, which are important for the meet.
  * **Entries:** An entry file contains the entries for one meet. One file might contain the entries of one club only, or it can contain all entries of all clubs.
  * **Results:** A result file contains the results of one meet. Normally, it contains all results of all clubs, but it is possible to split the results for each club into a separate file.
  * **Records:** A record file contains one or more list(s) of records.
  * **Time standards:** A time standards file may contain different kinds of time standards and/or qualification times. It might make sense to store time standards in separate files, if they are independent of meets (e.g. Olympic A and B time standards). If the time standards are bound to a certain meet, they should be included in the invitation file of that meet.

Generally the items in a Lenex file fall into three categories:
  * **Elements:** An element contains any number of child objects and attributes.
  * **Collections:** A collection is an element that contains elements of one type only. By default, the collection will be given the plural name of the element name it contains (e.g. SESSIONS contains SESSION objects). In most cases, the objects contained in a collection have at least one required attribute for identification purposes (e.g. attribute "distance" for element SPLIT).
  * **Attributes:** Attributes contain data in one of the basic Lenex data formats. The recognized formats are documented in the chapter "Lenex data types". Attributes can be attached to objects or to collections.

## 3. Lenex tree
This is an overview of the Lenex structure. Subchapter 3.1 is a tree with the most important elements. The other subchapters describe some of the sub trees in more details. To get the full information about all elements that are allowed or required, please refer to the chapter with the "Lenex element documentation".

### 3.1. Tree overview
The following tree shows the most important elements in a Lenex tree.
```
<LENEX> <!-- The root of a Lenex file. -->
	<CONSTRUCTOR /> <!-- Information about the creator of the file. -->
    <MEETS>
    	<MEET> <!-- The root for a meet sub tree. -->
        	<SESSIONS /> <!-- The schedule and event details of a meet. -->
            <CLUBS>
            	<CLUB> <!-- All data of one club at the meet. -->
                	<ATHLETES />
                    <RELAYS />
                    <OFFICIALS />
                </CLUB>
            </CLUBS>
        </MEET>
    </MEETS>
    <RECORDLISTS /> <!-- The root for the record lists sub tree. -->
    <TIMESTANDARDLISTS /> <!-- The root for the time standard lists sub tree. -->
</LENEX>
```

### 3.2 Sub tree `<SESSIONS />`
The SESSIONS sub tree describes the entire event structure with prelims and final events and the age groups used for the result lists.
```
<SESSIONS>
	<SESSION> <!-- Data of one session with all its events.  -->
    	<POOL />
        <EVENTS>
        	<EVENT> <!-- Description of one event/round. -->
            	<AGEGROUPS>
                	<AGEGROUP> <!-- Details of one age group.  -->
                    	<RANKINGS>
                        	<RANKING /> <!-- Details for ranking with reference to result elements.  -->
                        </RANKINGS>
                    </AGEGROUP>
                </AGEGROUPS>
                <HEATS>
                	<HEAT /> <!-- Details of one heat (number, starttime). -->
                </HEATS>
                <SWIMSTYLE />
                <TIMESTANDARDREFS>
                	<TIMESTANDARDREF /> <!-- Reference to a timestandard list. -->
                </TIMESTANDARDREFS>
            </EVENT>
        </EVENTS>
        <JUDGES>
        	<JUDGE /> <!-- Details about judges for a session. -->
        </JUDGES>
    </SESSION>
</SESSIONS>
```

### 3.3. Sub tree `<ATHLETES \>`
The ATHLETES sub tree contains all athletes of one club with their entries and/or results.
```
<ATHLETES>
	<ATHLETE> <!-- Data of one athlete. -->
    	<ENTRIES>
        	<ENTRY> <!-- Entry for one event/round. -->
            	<MEETINFO />
            </ENTRY>
        </ENTRIES>
        <RESULTS>
        	<RESULT> <!-- Result for one event/round. -->
            	<SPLITS />
            </RESULT>
        </RESULTS>
    </ATHLETE>
</ATHLETES>
```

### 3.4. Sub tree `<RELAYS />`
The RELAYS part is used to describe relay entries and results of one club. The relay swimmers are not stored directly in this tree. A unique id is stored in the tree in order to reference an athlete in the ATHLETES sub tree.
```
<RELAYS>
	<RELAY>
    	<ENTRIES>
        	<ENTRY> <!-- Entry for one event/round. -->
            	<RELAYPOSITIONS>
                	<RELAYPOSITION>
                    	<MEETINFO />
                    </RELAYPOSITION>
                </RELAYPOSITIONS>
            	<MEETINFO />
            </ENTRY>
        </ENTRIES>
        <RESULTS>
        	<RESULT> <!-- Result for one event/round. -->
            	<RELAYPOSITIONS>
                	<RELAYPOSITION />
                </RELAYPOSITIONS>
            	<SPLITS />
            </RESULT>
        </RESULTS>
    </RELAY>
</RELAYS>
```

### 3.5. Sub tree `<RECORDLISTS />`
The sub tree RECORDLISTS is used to define all kind of records. One record list contains all records of a specific type (e.g. world records), gender and pool length (course). In this sub tree, the information about the athletes is represented by means of complete ATHLETE objects, and not just as a reference to some other sub tree.
```
<RECORDLISTS>
	<RECORDLIST> <!-- Data of one record list (type, gender, course). -->
    	<AGEGROUP />
        <RECORDS>
        	<RECORD> <!-- Data of one record (individual or relay). -->
            	<SWIMSTYLE />
                <ATHLETE />
                <RELAY>
                	<RELAYPOSITIONS>
                    	<RELAYPOSITION>
                        	<ATHLETE />
                        </RELAYPOSITION>
                    </RELAYPOSITIONS>
                </RELAY>
                <MEETINFO />
                <SPLITS />
            </RECORD>
        </RECORDS>
    </RECORDLIST>
</RECORDLISTS>
```

### 3.6. Sub tree `<TIMESTANDARDLISTS />`
The sub tree TIMESTANDARDLISTS is used to define time standards and qualification times.
```
<TIMESTANDARDLISTS>
	<TIMESTANDARDLIST> <!-- Time standards (type, gender, course). -->
    	<TIMESTANDARDS>
        	<TIMESTANDARD> <!-- Data of one time standard / qual. time. -->
            	<SWIMSTYLE />
            </TIMESTANDARD>
        </TIMESTANDARDS>
    </TIMESTANDARDLIST>
</TIMESTANDARDLISTS>
```

## 4. Lenex element documentation
The following list is alphabetically ordered and describes the meaning and content of every element in a Lenex tree. Element names are in uppercase. Attribute names are in lowercase. The basic data types are described in chapter "Lenex data types". Elements can appear in different ways:
* **Normal (-):** Zero or one instance of an attribute/element is allowed.
* **Required (r):** Exactly one instance of an attribute/element is required.
* **Multiple (m):** There can be any number of instances of an elements (including zero). An attribute is always allowed once in maximum per element.

Every element or collection can have an attribute with the name "[elementname]id" (e.g. "athleteid" for the element ATHLETE). For some objects, this attribute is mandatory, because it is used to build relationships between elements in different sub trees. Attributes have to be unique over all instances of element type.

### Element `<AGEDATE />`
The AGEDATE is the date used to calculate the age of an athlete.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| type | e | r | The type describes how the age is calculated. Acceptable values: **YEAR** – the age is calculated using the year of the meet and the year of birth only; **DATE** – the age is calculated exactly between the date and the birth date; **POR** – age calculation according to the Portuguese federation; **CAN.FNQ** – calculation according to the Quebec federation; **LUX** – calculation according to the Luxembourg federation. |
| value | d | f | The date value. |

### Element `<AGEGROUP />`
This element contains information about an age range. It is used in events and record lists.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| agegroupid | n | r | Only for events, every AGEGROUP element needs an id, because the objects can be referenced from ENTRY objects. The id has to be unique within an AGEGROUPS collection. |
| agemax | n | r | The upper bound of the age range. -1 means no upper bound. |
| agemin | n | r | The lower bound of the age range. -1 means no lower bound. |
| gender | e | - | In mixed events, the gender can be specified in the AGEGROUP objects. Values can be **M** (male), **F** (female), **X** (mixed, used for relays only) or **A** (all). Setting the gender to all can be useful when the event is open to everyone, but the ranking is separated. This attribute is not allowed in the context of a RECORDLIST or TIMESTANDARDLIST element. |
| calculate | e | - | Information for relay events about how the age is calculated. Use **SINGLE** when each relay swimmer must be within the range (default) or **TOTAL** when the combined age of all swimmers must stay within the range. |
| handicap | e | - | The handicap class for the agegroup, used to group results by disability categories. Allowed values are **1 – 15**, **20**, **34** and **49** (standard handicap classes). |
| levelmax | s | - | The maximum level (A-Z) of the agegroup. If the value is missing, this means no upper bound. |
| levelmin | s | - | The minimum level (A-Z) of the agegroup. If the value is missing, this means no lower bound. |
| levels | s | - | A comma separated list of codes of allowed athlete levels. |
| name | s | - | The name of the age group (e.g. "Juniors"). |
| RANKINGS | o | - | A collection with references to results ranked in this agegroup. |

### Collection `<AGEGROUPS />`
This collection contains all age group definitions of one event.

### Element `<ATHLETE />`
This contains all information of a athlete including all entries and results in the context of a meet sub tree.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| athleteid | n | r | The id attribute should be unique over all athletes of a meet. It is required for ATHLETE objects in a meet sub tree. |
| birthdate | d | r | The date of birth for the athlete. If only the year of birth is known, the date should be set to January 1st of that year. |
| CLUB | o | - | The club or team for the athlete, when he swam the record. This element is allowed in a RECORDLIST sub tree only. |
| ENTRIES | o | - | All entries of the athlete. This element is allowed in a meet sub tree only. |
| firstname | s | r | The first name of the athlete. |
| firstname.en | si | - | The first name in english. |
| gender | e | r | Gender of the athlete. Values can be **M** (male) or **F** (female). |
| HANDICAP | o | - | Information about the handicap classes of a swimmer. |
| lastname | s | r | The last name of the athlete. |
| lastname.en | si | - | The last name in english. |
| level | s | - | The level of the athlete (used with levels in AGEGROUP). |
| license | s | - | The registration number given by the national federation. This number should be looked at together with the nation of the club the athlete is listed in the Lenex file. |
| license_ipc | n | - | The registration number given by World Para Swimming, also known as SDMS ID. |
| nameprefix | s | - | An optional name prefix. For example for Peter van den Hoogenband, this could be "van den". |
| nation | e | - | See table "Nation Codes" for acceptable values. |
| passport | s | - | The passport number of the athlete. |
| RESULTS | o | - | All results of the athlete. This element is allowed in a meet sub tree only. |
| status | e | - | Acceptable values are **EXHIBITION** (the athlete swims exhibition in all events), **FOREIGNER** (the athlete is a foreign competitor) and **ROOKIE** (first-year athlete). |
| swrid | n | - | The global unique athlete id given by swimrankings.net. |

### Collection `<ATHLETES />`
This collection contains all athletes of one club.

### Element `<BANK />`
This is used to represent bank payment information for a meet.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| accountholder | s | - | The name of the bank account holder. |
| bic | s | - | THE BIC code of the bank. |
| iban | s | r | The IBAN number of the bank account. Must be a valid IBAN number. |
| name | s | - | The name of the bank. |
| note | s | - | Note for the payment as additional information. |

### Element `<CLUB />`
In the meet sub tree, this element contains information about a club, including athletes and relays with their entries and/or results. In the record list sub tree, the element contains information about the club or nation of record holders.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| ATHLETES[^fn1] | o | - | The athletes of this club. |
| code | s | - | The official club code given by the national federation. Only official club codes should be used here! |
| CONTACT[^fn1] | o | - | Contact address for the specific meet. |
| name | s | r | The full name of the club or the team. |
| name.en | si | - | The club name in english. |
| nation | e | - | See table "Nation Codes" for acceptable values. |
| number[^fn1] | n | - | This value can be used to distinguish different teams of the same club in a meet entries or results file. |
| OFFICIALS[^fn1] | o | - | The officials from this club. |
| region | s | - | The code of the regional or local swimming committee. Only official codes should be used here! |
| RELAYS[^fn1] | o | - | The relay teams of this club. |
| shortname | s | - | A short version of the club name. This string is limited to 20 characters. |
| shortname.en | si | - | The short version of the club name in english. |
| swrid | n | - | The global unique club id given by swimrankings.net. |
| type | e | - | Allowed club types: **CLUB** (default), **NATIONALTEAM** (represents a national team — the code, region and nation attributes should match), **REGIONALTEAM** (represents a regional team — the code and region attributes should match) and **UNATTACHED** (club unknown; the `name` attribute and CONTACT element are not required). |

[^fn1]: These objects and elements are not used in CLUB objects that appear in the RECORDLIST sub tree.

### Collection `<CLUBS />`
This collection contains all clubs that take part of one meet.

### Element `<CONSTRUCTOR />`
This element contains information about the software, which created the Lenex file and the contact information about the provider of that software.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| CONTACT | o | r | Contact information of the provider of the software, which created the Lenex file. |
| name | s | - | Name of the application that created the Lenex file. |
| registration | s | r | Name of user, to who the creator application was registered. |
| version | s | r | The version number of the application that created the Lenex file. |

### Element `<CONTACT />`
This element contains the contact address for a person or organisation.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| city | s | - | The city of the contact address. |
| country | s | - | See table "Country codes" for acceptable values. |
| email | s | r | The e-mail address of the contact. The attribute is required in the context of a CONSTRUCTOR element only. |
| fax | s | - | The fax number of the contact. |
| internet | s | - | The full URL of the website of the contact person or organisation. The https:// should be included in the string. |
| name[^fn2] | s | - | The full name of the contact person or the name of the organisation. |
| mobile | s | - | The mobile phone number of the contact person. |
| phone | s | - | The phone number of the contact person or the organisation. |
| state | s | - | The state, province or county of the contact address. |
| street | s | - | The first additional line of the address. |
| street2 | s | - | The second additional line of the address. |
| zip | s | - | The postal code of the address. |

[^fn2]: These elements are not used in the context of an OFFICIAL element.

### Collection `<ENTRIES />`
This collection contains all entries of on athlete or a relay team.

### Element `<ENTRY />`
This element contains the information for a single entry of an athlete or a relay to a specific round of a meet.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| agegroupid | n | - | Reference to an age group (AGEGROUP element in the AGEGROUPS collection of the EVENT element). |
| entrycourse | e | - | This attribute indicates a pool length for the entry time. This is necessary when special seeding rules are used. See section 5.4. for acceptable values. |
| entrydistance | n | - | The entry distance in centimeters. Is used for some fin swimming events. For such entries the entrytime should be "NT". |
| entrytime | st | - | The entry time in the swim time format. |
| eventid | n | r | Reference to the EVENT element using the id attribute. |
| handicap | e | - | In special cases, the sport class can be different for a single entry. Allowed values match the standard sport classes *(use sparingly; generally not recommended)*. |
| heatid | n | - | Reference to a heat (HEAT element in HEATS collection of the EVENT element). |
| lane | n | - | The lane number of the entry. |
| MEETINFO | o | - | This element contains the information, about a qualification result for the entry time was achieved. |
| RELAYPOSITIONS | o | - | Only for relay entries. This element contains references to the relay swimmers. |
| status | e | - | This attribute is used for the entry status information. When empty, the entry is considered regular. Allowed values: **EXH** (exhibition swim), **RJC** (rejected entry), **SICK** (athlete is sick) and **WDR** (athlete or relay withdrawn). |

The combination of the attributes eventid, heatid and lane should be unique over all ENTRY objects of the same meet.

### Element `<EVENT />`
This element contains all information of an event. For events with finals, there has to be an EVENT element for each round.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| AGEGROUPS | o | - | The AGEGROUPS collection contains the descriptions for the age groups in this event. For Open/Senior events, AGEGROUPS is only needed with one AGEGROUP element as a placeholder for the RANKINGS element (for places in result lists). If round="FHT", then no AGEGROUPS element is allowed. |
| daytime | t | - | The daytime of the start of the event. |
| eventid | n | r | Every event needs to have an id attribute, so that it can be referenced by ENTRY and RESULT objects. The id attribute has to be unique over all EVENT objects of all sessions of a meet. |
| FEE | o | - | The entry fee for this event. If there are global fees per athlete, relay and/or meet, the FEE elements in the MEET element should be used. |
| gender | e | - | The gender of the event. Allowed values: **A** (all; default), **M** (male), **F** (female) and **X** (mixed, relays only). |
| HEATS | o | - | Collection with all heats in the event. |
| maxentries | n | - | The maximum number of entries per club in this event. To limit the number of entries per athlete or relay, use the maxentries attribute in the MEET element. |
| number | n | r | The number of the event. The event numbers should be unique over all events of a meet. The EVENT objects of the different rounds for the same event may have the same event number. |
| order | n | - | This value can be used to define the order of the events within a session if it is not by the event number and if there are no start times for the events. |
| preveventid | n | - | This value is a reference to a previous event's id. (e.g. the prelims events for final events). The default value is -1 and means, that there was no previous event. |
| round | e | - | Allowed values: **TIM** (timed finals; default), **FHT** (fastest heats that still reference the timed final event of the same distance, stroke and age groups; useful for schedule and entries only), **FIN** (finals including A/B/C…), **SEM** (semi-finals), **QUA** (quarterfinals), **PRE** (prelims), **SOP** (swim-off after prelims), **SOS** (swim-off after semi-finals), **SOQ** (swim-off after quarterfinals) and **TIMETRIAL** (time trial event). |
| run | n | - | Used if there is more than one swim-off necessary. Default value is 1. |
| SWIMSTYLE | o | r | The SWIMSTYLE element contains information about distance and stroke of the event. |
| TIMESTANDARDREFS | o | - | A list of references to TIMESTANDARDREF elements with references to time standard lists to be used for this event. |
| timing | e | - | The type of timing for an event. If missing, the session should be checked and finally the value for the meet should be used. See MEET for acceptable values. |
| type | e | - | Allowed values: the default empty value (regular events following FINA/AQUA rules) or **MASTERS** (events producing master rankings/records). |

### Collection `<EVENTS />`
This collection contains all events of one session.

### Element `<FACILITY />`
This element contains name and full address of meets facility (pool).

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| city | s | r | The city of the facility. |
| nation | s | r | See table "Country codes" for acceptable values. |
| name | s | - | The name of the facility (e.g. "Aquatic Center"). |
| state | s | - | The state, province or county of the address. |
| street | s | - | The first additional line of the address. |
| street2 | s | - | The second additional line of the address. |
| zip | s | - | The postal code of the address. |

### Element `<FEE />`
The fee is used in MEET and EVENT objects.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| currency | e | - | See table "Currency Codes" for acceptable values. |
| type[^fn3] | e | r | Used in the context of FEES in MEET or SESSION objects only. Acceptable values: **CLUB** (per club), **ATHLETE** (per athlete), **RELAY** (per relay team), **TEAM** (per team, e.g. Swiss Team Championship), **LATEENTRY.INDIVIDUAL** (per late individual entry, MEET.FEES only) and **LATEENTRY.RELAY** (per late relay entry, MEET.FEES only). |
| value | c | r | The value of the fee in the currency format. |

[^fn3]: This element is required only in the context of a FEES collection.

### Collection `<FEES />`
This collection contains all global fees in a MEET element.

### Element `<HANDICAP />`
The handicap is used for handicapped athletes.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| breast | e | r | The handicap class for breaststroke. Allowed values are **0 – 15**, matching the sport class (e.g. SB5 maps to 5). |
| breaststatus | e | - | The state of the sport class for breaststroke ([#9](https://github.com/SwimStandardHub/lenex/issues/9)). Allowed values: **NONE** (no official confirmation; default, see also [#15](https://github.com/SwimStandardHub/lenex/issues/15)), **NATIONAL** (national level only), **NEW** (not yet valid), **REVIEW** (must be reviewed within the year, but valid through year end), **OBSERVATION** (requires observation during the meet to confirm) and **CONFIRMED** (confirmed for international meets). |
| exception | s | - | The codes of exceptions according to the WPS rules. |
| free | e | r | The handicap class for freestyle, backstroke and fly. Allowed values are **0 – 15**, matching the sport class (e.g. S5 maps to 5). |
| freestatus | e | - | The state of the sport class for freestyle, backstroke and fly. Uses the same values as **breaststatus** ([#9](https://github.com/SwimStandardHub/lenex/issues/9)). |
| medley | e | r | The handicap class for individual medley. Allowed values are **0 – 15**, matching the sport class (e.g. SM5 maps to 5). |
| medleystatus | e | - | The state of the sport class for individual medley. Uses the same values as **breaststatus** ([#9](https://github.com/SwimStandardHub/lenex/issues/9)). |

### Element `<HEAT />`
The heat is used to define more details in the start list (e.g. schedule).

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| agegroupid | n | - | Reference to an age group (AGEGROUP element in the AGEGROUPS collection of the EVENT element). |
| daytime | t | - | The daytime of the start of the event. |
| final | e | - | This value is used to identify A, B, ... finals. Allowed are characters A, B, C and D. |
| heatid | n | r | The id attribute should be unique over all heats of a meet. It is required when you have ENTRY / RESULT objects that reference to a heat. |
| number | n | r | The number of the heat. The heat numbers have to be unique within one event, also in a case when you have A finals in different agegroups. |
| order | n | - | This value can be used to define the order of the heats within an event if it is not by the heat number and if there are no start times for the heats. |
| status | e | - | The status of the heat. Allowed values: **SCHEDULED** (scheduled but not yet seeded; see [#8](https://github.com/SwimStandardHub/lenex/issues/8)), **SEEDED** (seeding complete), **INOFFICIAL** (results available but not official) and **OFFICIAL** (results are official). |

### Collection `<HEATS />`
This collection contains all heats of one event.

### Element `<JUDGE />`
This element contains information to attach an official to a session with his role in the session.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| number | n | - | The number for judges where there are more than one. This can be used for example for the lane number for timekeepers. |
| officialid | n | r | A reference to a OFFICIAL element. |
| remarks | s | - | Additional information for the judge. |
| role | e | - | Indicates the role of a judge based on FINA descriptions. Accepted values include **OTH** (other/unknown; default), **MDR** (meet director), **TDG** (technical delegate), **REF** (referee), **STA** (starter), **ANN** (announcer or speaker), **JOS** (judge of strokes), **CTIK** (chief timekeeper), **TIK** (timekeeper), **CFIN** (chief finish judge), **FIN** (finish judge), **CIOT** (chief inspector of turns), **IOT** (inspector of turns), **FSR** (false start rope personnel), **COC** (clerk of course), **CREC** (chief recorder), **REC** (recorder), **CRS** (control room supervisor), **CR** (control room/computer room) and **MED** (medical service). |

### Collection `<JUDGES />`
This collection contains all judges of one session.

### Element `<LENEX />`
This is the root element of every Lenex file which identifies it as a XML file conforming to the Lenex data format.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| CONSTRUCTOR | o | r | This element contains information about the software which created the Lenex file. |
| MEETS | o | - | Contains all the information of meets like athletes, relays, entries and results. |
| RECORDLISTS | o | - | Contains different types of records (e.g. World records, Olympic records) including age group records. |
| TIMESTANDARDLISTS | o | - | Contains different type of time standards and qualification times. |
| revision | s | - | The patch or revision version number of the Lenex format. If this value is missing, the initial version from the attribute `version` is referenced (see [#15](https://github.com/SwimStandardHub/lenex/issues/15)). |
| version | s | r | The version number of the Lenex format. The value for this document version is `3.0`. |

### Element `<MEET />`
This element contains all information of one meet, including events, athletes, relays, entries and results.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| AGEDATE | o | - | The date to be used to calculate the age of athletes. The default value is the date of the first session and type by year of birth only. |
| BANK | o | - | Information for a bank account for payment of entry fees. |
| altitude | n | - | Height above sea level of the meet city. |
| city | s | r | The name of the city where the meet was run. Should be the same as FACILITY.city |
| city.en | si | - | Name of meet city in english. |
| CLUBS | o | - | Collection of clubs of the meet. |
| CONTACT | o | - | The contact address of the meet organizer. |
| course | e | - | The size of the pool. See section 5.4. for acceptable values. If the attribute is not available, all SESSION objects need to have a course attribute. |
| deadline | d | - | The date for the entry deadline. |
| deadlinetime | t | - | The exact time for the entry deadline. |
| entrystartdate | d | - | The date from when (online) entries are open/available. |
| entrytype | e | - | The type of (online) entries: **OPEN** (meet open to all clubs) or **INVITATION** (restricted to invited clubs). |
| FACILITY | o | - | The full address of the meets facility. |
| FEES | o | - | Fees used for this meet. On this level, different global fees for clubs, athletes and relays are allowed. If there are fees that have to be paid per entry, the FEE element in the EVENT objects should be used. |
| hostclub | s | - | The executing federation or club of the meet (e.g. the German Swimming Federation, if the European Champ was held in Berlin). |
| hostclub.url | s | - | A website url, that directs to the executing club for the meet. |
| maxentriesathlete | n | - | The maximum number of individual entries per athlete in this meet. |
| maxentriesrelay | n | - | The maximum number of relay entries per club in this meet. |
| name | s | r | The name of the meet. Normally the name should not contain a full date (maybe the year only) and/or a city or pool name. |
| name.en | si | - | Meet name in english. |
| nation | e | r | The three letter code of the nation of the meet city. This should be the same as FACILITY.nation |
| number | s | - | The sanction number for the meet by the federation. |
| organizer | s | - | The organisation which promotes the meet (e.g. AQUA for the World Championships). |
| organizer.url | s | - | A website url, that directs to the organizer of the meet. |
| POINTTABLE | o | - | Description of the point table used for scoring. |
| POOL | o | - | Details about the pool where the meet took place. |
| QUALIFY | o | - | Details about how qualification times for entries are defined. |
| reservecount | n | - | The number of reserve swimmers in finals and semifinals. |
| result.url | s | - | A website url, that directs to the results page. This should be a deep (direct) link to the result lists and not the general website of a meet. |
| SESSIONS | o | r | Description of all events grouped by session. |
| startmethod | e | - | Start method options ([#6](https://github.com/SwimStandardHub/lenex/issues/6)): **1** (one start allowed; default) or **2** (two starts allowed). |
| swrid | uid | - | The global unique meet id given by swimrankings.net. |
| timing | e | - | The timing system used for the meet. Options: **AUTOMATIC** (fully automatic system), **SEMIAUTOMATIC** (automatic start with manual finish button), **MANUAL3** (three manual times per lane), **MANUAL2** (two manual times per lane) and **MANUAL1** (one manual time per lane). |
| touchpadmode | e | - | Touchpad installation: **ONESIDE** (touchpads on one side of the pool) or **BOTHSIDE** (touchpads on both sides). |
| type | e | - | The meet type. Leave empty for meets that follow FINA rules; other values depend on national federation definitions. |
| withdrawuntil | d | - | The date for withdrawals from the entry list. |

### Element `<MEETINFO />`
This element is used in entries and records for general information about a meet.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| approved[^fn5] | s | - | Contains a code for the organisation that approved the qualification time (e.g. AQUA, LEN or an IOC nation code). Leave empty if the time was not approved. |
| city[^fn4] | s | r | The city name where the meet took place. |
| course[^fn5] | e | - | Indicates the pool length where the qualification time was achieved. See section 5.4 for acceptable values. |
| date[^fn4] | d | r | The date of the swim for the record or qualification time achievement. |
| daytime | t | - | The day time of the swim. |
| name | s | - | The meet name. |
| nation[^fn4] | e | r | The nation of the city for the meet. |
| POOL | o | - | The details about the pool. |
| qualificationtime[^fn5] | st | - | The qualification time, which may differ from the entry time. If missing, the entry time counts as the qualification time. |
| state | s | - | The state of the city for the meet. |
| timing | e | - | The type of timing. See MEET for acceptable values. |

[^fn4]: These elements are required only in the context of a RECORD element.
[^fn5]: These elements are used only in the context of an ENTRY or RELAYPOSITION element.

### Collection `<MEETS />`
This collection allows you to put the results of more than one meet in the same Lenex file. However, our experience with Lenex during the last years shows that it is better to keep different meets in separate files.

### Element `<OFFICIAL />`
This element contains all information about an official.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| CONTACT | o | - | The contact information of the official. |
| firstname | s | r | The first name if the official. |
| gender | e | - | Gender of the official. Values can be male (M) and female (F). |
| grade | s | - | The grade of the judge. The value here is specific to national federations and depends on their officials education system. |
| lastname | s | r | The last name of the official. |
| license | s | - | The registration number given by the national federation. |
| nameprefix | s | - | An optional name prefix. For example for Peter van den Hoogenband, this could be "van den". |
| nation | e | - | See table "Nation Codes" for acceptable values. |
| officialid | n | r | The id attribute should be unique over all officials of a meet. It is required for JUDGE objects in a meet sub tree. |
| passport | s | - | The passport number of the official. |

### Collection `<OFFICIALS />`
This collection contains all officials of a club.

### Element `<POINTTABLE />`
This element is used to describe the point scoring used for a meet.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| name | s | r | The name of the point score system. |
| pointtableid | e | - | Common point tables have a unique id. Details are in chapter 5.5. |
| version | s | r | The version number/year of the point score system. |

### Element `<POOL />`
This element is used to describe the pool where the meet took place.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| lanemax | n | - | Number of the last lane used in the pool for the meet. The number of lanes can be calculated with LANEMAX - LANEMIN + 1. |
| lanemin | n | - | Number of the first lane used in the pool for the meet. |
| temperature | n | - | The water temperature. |
| type | e | - | Pool type: **INDOOR**, **OUTDOOR**, **LAKE** or **OCEAN**. |

### Element `<QUALIFY />`
This element contains information about details, how qualification entrytimes are defined.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| conversion | e | - | The seeding conversion method: **NONE** (no conversion; default), **FINA_POINTS** (convert via FINA points when entry course differs), **PERCENT_LINEAR** (apply a fixed percentage adjustment) or **NON_CONFORMING_LAST** (seed entries matching the event course first, others afterward). |
| from | d | r | The first day of the qualification period for entry times. |
| percent | n | - | The percentage for conversion PERCENT_LINEAR. |
| until | d | - | The last day of the qualification period for entry times. If it is missing, then the default is the last day before the first day of the meet. |

### Element `<RANKING />`
This element describes one entry in the rankings of one agegroup. It contains the place and a reference to a result (individual or relay).

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| order | n | - | This value can be used to define the order of the results. If it is missing, the value for place is used to sort the elements in a collection. |
| place | n | r | The final position in the result list for the current event/round. |
| resultid | n | r | A reference to the RESULT element. |

### Collection `<RANKINGS />`
This collection contains a set of ranking elements.

### Element `<RECORD />`
This element describes one individual or relay record. It is possible to have no ATHLETE / RELAY objects. In this case the record is a "record standard time".

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| ATHLETE | o | - | The person who holds the record. This is only used for individual records. |
| comment | s | - | This value can be used for additional comments like "Swum in the prelims" or things like that. |
| MEETINFO | o | - | Information about the meet, where the record was swum. |
| RELAY | o | - | The relay team and swimmers, who holds the record. This is only used for relay records. |
| SPLITS | o | - | The split times of the record. |
| SWIMSTYLE | o | r | The swimstyle contains information like distance, stroke of the record. |
| swimtime | st | r | The final time of the record in the swim time format. |
| status | e | - | State of the record. Allowed values: **APPROVED** (approved and valid; default), **PENDING** (awaiting ratification), ~~INVALID~~ *(not recommended; indicates ratification failure)*, ~~APPROVED.HISTORY~~ *(not recommended; previously approved but no longer current)*, ~~PENDING.HISTORY~~ *(not recommended; pending but no longer current)* and **TARGETTIME** (no record yet, use a target time; see the [discussion about the values](https://github.com/SwimStandardHub/lenex/discussions/13)). |

### Element `<RECORDLIST />`
This element describes one single record list.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| AGEGROUP | o | - | For agegroup records. Agegroup is "Open", if the element is missing. |
| course | e | r | The course for the record list. See section 5.4. for acceptable values. |
| gender | e | r | The gender for records in this list. Acceptable values: **M** (male), **F** (female) and **X** (mixed, relays only). |
| handicap | e | - | The handicap class for the record list. Allowed values: 1 – 15, 20, 34 or 49 (standard handicap classes). |
| name | s | r | The name of the record list (e.g. "World Records"). |
| nation | s | - | For international records, this field is empty. For national or regional records, the field should contain the FINA three letter code of the national federation. |
| order | n | - | This value can be used to define an order for all recordlists within a collection. |
| RECORDS | o | r | The records of this record list. |
| region | s | - | For international and national records, this field is empty. For regional records, the field should contain the official code for the region. If region has a value, nation needs to have a value as well. |
| updated | d | - | The date of the last change to the record list. |
| type | e | - | The record type. Allowed values include **WR** (world), **OR** (Olympic), **ER** (European), **PAR** (Pan American), **AFR** (African), **AR** (Asian), **OCR** (Oceanian), **CWR** (Commonwealth) or a FINA three-letter nation code. Federations may extend the list using prefixes such as **SUI.RZW** for Swiss regional records. |

### Collection `<RECORDLISTS />`
This collection contains a set of record lists. For each different combination of gender, course, age group or type, a separate RECORDLIST element is needed.

### Collection `<RECORDS />`
This collection contains all records of a record list. If there is more than one athlete holding the same record, each of them has a RECORD element in the collection.

### Element `<RELAY />`
This element is used to describe one relay team for a record or for a meet.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| agemax[^fn7] | n | r | The maximum age allowed for the oldest swimmer in the team. The value -1 means no upper bound. |
| agemin[^fn7] | n | r | The minimal age allowed for the youngest swimmer in the team. The value -1 means no lower bound. |
| agetotalmax[^fn7] | n | r | The maximum total age of all swimmers in the relay team. The value -1 means that the total age is unknown. |
| agetotalmin[^fn7] | n | r | The minimum total age of all swimmers in the relay team. The value -1 means that the total age is unknown. |
| CLUB[^fn6] | o | - | The club or team of the relay in the context of a record. |
| ENTRIES[^fn7] | o | - | All entries of the relay team. |
| gender[^fn7] | e | r | The gender of the relay team. Acceptable values: **M** (male), **F** (female) and **X** (mixed). |
| handicap[^fn7] | e | - | For relays with handicapped swimmers. The default value is 0; other values are **14** (relay with II/S14 athletes), **20** (relay total of 0–20 handicap points, PI/S1–S10), **34** (relay total of 21–34 handicap points, PI/S1–S10) and **49** (relay total of 35 or more handicap points, VI/S11–S13). |
| name | s | - | The name of the relay team. |
| number[^fn7] | n | - | The team number of the relay team. Required only when a club fields multiple teams in the same age groups/events. |
| RELAYPOSITIONS[^fn6] | o | - | The relay swimmers in the context of a relay record. |
| RESULTS[^fn7] | o | - | All results of the relay team. |

[^fn6]: These objects are allowed in the context of a record only.
[^fn7]: These elements or objects are allowed in the context of a meet only.

### Collection `<RELAYS />`
This collection contains all relays of one club of a meet.

### Element `<RELAYPOSITION />`
This element is used for information about one relay swimmer.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| ATHLETE | o | - | Last name, first name, etc. of the athlete. Allowed only in the context of a record, where it is required. |
| athleteid | n | - | A reference to the ATHLETE element of the athlete. This attribute is allowed in the context of a meet sub tree only. |
| MEETINFO | o | - | This element contains the information, where the entry time was achieved. This element is only allowed in the context of a relay entry. |
| number | n | r | The number of the swimmer in the relay. The first swimmer is 1, the second 2 and so on. -1 can be used to add reserve swimmers. |
| reactiontime | rt | - | The reaction time at the start of the first swimmer and the relay take over times for other swimmers. |
| status | e | - | No status attribute means the swimmer finished their part correctly. Otherwise, use **DSQ** (relay athlete disqualified) or **DNF** (relay athlete did not finish). |

### Collection `<RELAYPOSITIONS />`
This collection contains information's about relay swimmers.

### Element `<RESULT />`
This element is used to describe one result of a swimmer or relay team.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| comment | s | - | Additional comment e.g. for new records or reasons for disqualifications. |
| eventid | n | - | Reference to the EVENT element using the id attribute. |
| handicap | e | - | In special cases, the sport class can be different for a single result. Allowed values match the standard sport classes (see [#5](https://github.com/SwimStandardHub/lenex/issues/5)). |
| heatid | n | - | Reference to a heat (HEAT element in HEATS collection of the EVENT element). |
| lane | n | - | The lane number of the entry. |
| points | n | - | The number of points for the result according to the scoring table used in a meet. |
| reactiontime | rt |  | The reaction time at the start. For relay events it is the reaction time of the first swimmer. |
| RELAYPOSITIONS | o | - | The information about relay swimmers in this result. Only allowed for relay RESULT objects. |
| resultid | n | r | Each result needs a unique id which should be unique over a meet. |
| status | e | - | This attribute is used for the result status information. When empty, the result is considered regular. Allowed values: **EXH** (exhibition swim), **DSQ** (athlete or relay disqualified), **DNS** (athlete or relay did not start; no reason or late withdrawal), **DNF** (athlete or relay did not finish), **SICK** (athlete is sick) and **WDR** (athlete or relay withdrawn on time). |
| SPLITS | o | - | The split times for the result. In a Lenex file, split times are always saved continuously. |
| swimdistance | n | - | The result distance in centimeters. Is used for some fin swimming events. For such results the swimtime should be "NT". |
| swimtime | st | r | The final time of the result in the swim time format. |

### Collection `<RESULTS />`
This collection contains all results of a athlete or relay team of a meet.

### Element `<SESSION />`
This element is used to describe one session of a meet.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| course | e | - | With indicating a pool length per session, the global value of the meet can be overridden, e.g. if the prelim sessions are short course and the finals are long course. See section 5.4. for acceptable values. |
| date | d | r | The date of the session. |
| daytime | t | - | The daytime when the session starts. |
| endtime | t | - | The time when the session ended. |
| EVENTS | o | r | The events of the session. |
| FEES | o | - | Fees used for this session. On this level, different global fees for clubs, athletes and relays are allowed. If there are fees that have to be paid per entry, the FEE element in the EVENT objects should be used. |
| JUDGES | o | - | The judges of the session. |
| maxentriesathlete | n | - | The maximum number of individual entries per athlete in this session. |
| maxentriesrelay | n | - | The maximum number of relay entries per club in this session. |
| name | s | - | Additional name for the session e.g. "Day 1 - Prelims". |
| number | n | r | The number of the session. Session numbers in a meet have to be unique. |
| officialmeeting | t | - | The daytime when the officials meeting starts. |
| POOL | o | - | The details about the pool, if they are different per session. Otherwise use the element in MEET. |
| remarksjudge | s | - | Additional remarks given by the referee. |
| teamleadermeeting | t | - | The daytime when the team leaders meeting starts. |
| timing | e | - | The type of timing for a session. If missing, the global value for the meet should be used. See MEET for acceptable values. |
| touchpadmode | e | - | Information about timing installation for a session. See MEET for acceptable values. |
| warmupfrom | t | - | The daytime when the warmup starts. |
| warmupuntil | t | - | The daytime when the warmup ends. |

### Collection `<SESSIONS />`
Depending on the context this collection contains all sessions of a meet or all sessions for a judge, where he is planed in.

### Element `<SPLIT />`
This element contains information about a single split time. In a Lenex file, split times are always saved continuously.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| distance | n | r | The distance where the split time was measured. |
| swimtime | st | r | The time of the result in the swim time format. |

### Collection `<SPLITS />`
This collection contains all available split times for a single result.

### Element `<SWIMSTYLE />`
This element is used to describe one swim style.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| code | s | - | A code (max. 6 characters) of the swim style if the stroke is unknown. |
| distance | n | r | The distance for the event. For relay events it is the distance for one single athlete. |
| name | s | - | The full descriptive name of the swim style if the stroke is unknown (e.g. "5 x 75m Breast with one Arm only"). |
| relaycount | n | r | The number of swimmers per entry / result. Value 1 means, that it is an individual event. All other values mean, that it is a relay event. |
| stroke | e | r | Allowed values: **APNEA** (apnea, fin swimming), **BACK** (backstroke), **BIFINS** (bi-fins, fin swimming), **MIXEDFINS** (special mixed relay per CMAS rules), **BREAST** (breaststroke), **DYNAMIC** (dynamic fin swimming; result measured in meters via `swimdistance`), **DYNAMIC_BIFINS** (dynamic with bi-fins; result measured in meters via `swimdistance`), **DYNAMIC_NOFINS** (dynamic without fins; result measured in meters via `swimdistance`), **FLY** (fly/butterfly), **FREE** (freestyle), **IMMERSION** (immersion fin swimming), **IMRELAY** (relay where each athlete swims all strokes like an individual medley), **MEDLEY** (individual or relay medley following FINA order — fly, back, breast, free for individual events; back, breast, fly, free for relays), **SPEED_APNEA** (speed apnea, fin swimming), **SPEED_ENDURANCE** (speed endurance, fin swimming), **STATIC** (static, fin swimming), **SURFACE** (surface, fin swimming) and **UNKNOWN** (special events; the event `name` attribute becomes mandatory). |
| swimstyleid | n | - | The id attribute is important for SWIMSTYLE objects, where the stroke attribute is "UNKNOWN". In this case, the id should be a unique value to help to identify the swim style. |
| technique | e | - | Technique modifiers (mainly for technical events for kids). Leave empty for normal swimming. Allowed values: **DIVE** (swimming underwater), **GLIDE** (gliding only), **KICK** (kick only, no arms), **PULL** (pull only, no legs), **START** (start only) and **TURN** (turn only). |

### Element `<TIMESTANDARD />`
This element describes one time standard.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| SWIMSTYLE | o | r | The style contains information like distance, stroke of the record. For each TIMESTANDARD in the same collection, the SWIMSTYLE should be unique. |
| swimtime | st | r | The time standard or qualification time. |

### Collection `<TIMESTANDARDS />`
This collection contains a set of time standards.

### Element `<TIMESTANDARDLIST />`
This element describes one single time standard list.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| AGEGROUP | o | - | For age group time standards. Agegroup is "Open", if the element is missing. |
| course | e | r | The course for the timestandard list. See section 5.4. for acceptable values. |
| gender | e | r | The gender for time standards in this list. Acceptable values: **M** (male), **F** (female) and **X** (mixed). |
| handicap | e | - | The handicap class for the time standard list. Allowed values: 1 – 15, 20, 34 or 49 (standard handicap classes). |
| name | s | r | The name of the time standard list (e.g. "Olympic A Time Standards"). |
| timestandardlistid | n | r | The unique id of the time standard list. |
| TIMESTANDARDS | o | r | The time standards or qualification times of this list. |
| type | e | - | Time standard type: **DEFAULT** (fallback time when a team result is missing or invalid), **MAXIMUM** (swimmers must be faster than the standard; default) or **MINIMUM** (swimmers must be slower than the standard). |

### Collection `<TIMESTANDARDLISTS />`
This collection contains a set of time standard lists. For each different combination of gender, course, age group or type, a separate TIMESTANDARDLIST element is needed.

### Element `<TIMESTANDARDREF />`
This element describes a reference from a meet to a time standard list.

| Element/Attribute | Type |  | Remarks |
| --- | --- | --- | --- |
| timestandardlistid | n | r | The id of the time standard list element. |
| FEE | o | - | An optional element with a fine for missed time standards. |
| marker | s | - | An optional string to be used to mark the result, if the time standard was missed. Or to mark a result if a qualification time was fulfilled. |

### Collection `<TIMESTANDARDREFS />`
This collection contains a set of time standard references.

## 5. Lenex data types
In a Lenex file, the following data types are used:

| String | s | A string containing any character. Special characters like &lt; &gt; " ' and &amp; have to be quoted with &amp;lt; &amp;gt; &amp;quot; &amp;apos; and &amp;amp;. For line ends in multiline strings you should use &amp;#10; (encoding for the LF character). |
| --- | --- | --- |
| String international | si | Same as "String" but only characters between ASCII #32 - #127 allowed. |
| Number | n | A signed 32-bit integer number. Only the characters "0" .. "9" and "-" are allowed. |
| Enumeration | e | An enumeration is a set of predefined values that are allowed in the attribute of that data type. |
| Date | d | Dates are always represented by a string in the form "YYYY-MM-DD". Example: "2004-03-09" means March 9, 2004 |
| Daytime | t | A daytime (hour and minutes) represented by a string in the form "HH:MM". Hours should be from 0 to 24, minutes from 0 to 59. |
| Currency | c | An integer number. Currency values are represented in cents, e.g. one dollar in the Lenex currency format is 100. |
| Swim time | st | The swim time data type is always a fixed length string of the following form: "HH:MM:SS.ss". HH: hours from 0 to 99, MM: minutes from 0 to 59, SS: seconds from 0 to 59, ss: Hundreds of a second from 0 to 99. Example: "00:14:45.86" means a time of 14:45.86. In addition the string "NT" is allowed if no time is available. |
| Reaction time | rt | All reaction times are numbers and are measured in hundreds of a second. The first character indicates, if the reaction time is positive (+) or negative (-). Example "+14" means a positive reaction time of 14 hundreds. The reaction time "0.00" should be transmitted as "0". If the reactiontime is missing, the value should be empty. |
| Unique id | uid | Unique id's are a character (A-Z) followed by a number. Additional separator characters (space, dash, point) are allowed but have no meaning and should be ignored when comparing unique id's. The id's are unique worldwide and are handled by swimrankings.net. |

### 5.1 Nation codes
For the nation codes, the three letter codes of FINA are used. The current table with all codes and nation names can be found in the file "Lenex_Nation.txt".

### 5.2. Country codes
For the country codes, the international two letter postal codes are used. The current table with all codes and country names can be found in the file "Lenex_Country.txt".

### 5.3. Currency codes
For the currency codes, the international three letter codes are used. The current table with all codes and currency names can be found in the file "Lenex_Currency.txt".

### 5.4. Course codes
For the course attribute, the following values are allowed:
* LCM, 
* SCM, 
* SCY, 
* SCM16, 
* SCM20, 
* SCM33, 
* SCY20, 
* SCY27, 
* SCY33, 
* SCY36 and 
* OPEN for open water swimming.

### 5.5. ID's for POINTTABLE elements
For common point scorings there is a list of id's that can / should be used for the POINTTABLE elements. It can be found in the file "Lenex_PointTable.txt".

## 6. Specific extensions for different federations

### 6.1 Germany (GER)
Element ATHLETE can have the attribute "license_dbs" for the registration id of the german para swimming federation. "license_dsv" is used for the german federation id (DSV).

For the round attribute in EVENT there is an additional value: "GER.RES". This means "Nachschwimmen" or re-swim and is used for the German team championships.

For stroke attribute in SWIMSTYLE there is an additional value "GER.APH" for "Apnoe mit Hebeboje".

### 6.2 Switzerland (SUI)
For the status attribute in ATHLETE there is an additional value: "SUI.STARTSUISSE ". This is a special registration for foreign athletes to be allow to swim in a relay for a Swiss Record.

## 7. Frequently asked questions (FAQ)

**(Q)** What should I put in the required attributes for an ATHLETE in a RECORD when there is no record but a required time only?
**(A)** The ATHLETE / RELAY element is not required in a RECORD. None of both elements should be there in such a case.

## 8. Version history
|Date|Change or addition|
|----|----|
|27. Sep 2025|ChatGPT-optimized Markdown transcription derived from the Lenex 3.0 PDF; reverted the default LENEX.version attribute to 3.0.|
|05. Dec 2024|Minor version number changed to version 3.1 (documented for awareness when comparing with upstream).|
|05. Dec 2024|The enum of HANDICAP.sportclass status changed (upstream note).|
|22. Nov 2024|Initial Markdown transcription published by SwimStandardHub.|
