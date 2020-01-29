# ShackKit

[![Gem Version](https://badge.fury.io/rb/shack_kit.svg)](https://badge.fury.io/rb/shack_kit)
[![Code Climate](https://codeclimate.com/github/rrrodrigo/shack_kit/badges/gpa.svg)](https://codeclimate.com/github/rrrodrigo/shack_kit)

Collection of HAM radio utilities packaged as Ruby gem by Marcin SQ9OZM

## Functionality

### Data lookup

#### Offline
 * SOTA callsigns checker, using [ON6ZQ database of SOTA activators and chasers](http://www.on6zq.be/w/index.php/SOTA/MasterDta).
 * SOTA summits checker, using [the database of SOTA summits](http://sotadata.org.uk/summits.aspx) published by Summits on the Air.
 * SP callsigns checker, using licensing data published by [Republic of Poland Office of Electronic Communication](https://amator.uke.gov.pl/?locale=en).

#### Online
 * [QRZ.com](https://www.qrz.com) callsign lookup, using [the XML API](http://www.qrz.com/page/xml_data.html) of the most popular callbook ("phone book" for radio amateurs) worldwide. Note that paid subscription is needed to access complete datasets.
 * [HamQTH.com](https://www.hamqth.com) callsign lookup, using [the XML API](https://www.hamqth.com/developers.php) of a less popular, but free callbook service.
 * [QRZ.pl](http://qrz.pl) callsign lookup, using the most popular callbook service in Poland - and hence limited to SP callsigns.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shack_kit'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shack_kit

Next, to setup the database (ShackKit is using [SQLite](https://www.sqlite.org) for data storage), fire up `irb` and enter:

```ruby
require 'shack_kit'
ShackKit::Data.db_setup
ShackKit::Data.db_load
```

The last line loads the reference data from included source files. You might want to update this data from time to time - for instructions how to do it see the [Usage](#usage) below.

Now you are all set to use ShackKit in your code or from Ruby console!

## Usage

#### Offline data lookup

```ruby
require 'shack_kit'

# Check whether a callsign belongs to a SOTA program participant - the method returns true or false:
ShackKit::Data::SOTACalls.include?('SQ9OZM') #=> true
# that's my own callsign :-)
ShackKit::Data::SOTACalls.include?('EA0JC') #=> false
# apparently, the King of Spain does not do SOTA yet

# Check whether a SP callsign is valid - the method returns callsign licence info or nil (for invalid calls)
ShackKit::Data::SPCalls.check('SQ9OZM')
#=> {:callsign=>"SQ9OZM", :station_type=>"individual", :uke_branch=>"UKE Kraków",
#    :licence_number=>"3285/I/2010", :valid_until=>#<Date: 2020-12-28>, :licence_category=>"1",
#    :tx_power=>150, :station_location=>"Skrzynka"}
#
# Now some club call:
ShackKit::Data::SPCalls.check('SP9KDR')
#=> {:callsign=>"SP9KDR", :station_type=>"club", :uke_branch=>"UKE Kraków",
#    :licence_number=>"188/K/I/2014", :valid_until=>#<Date: 2019-05-23>, :licence_category=>"1",
#    :tx_power=>150, :station_location=>"Pcim"}
#
# and an invalid call:
ShackKit::Data::SPCalls.check('SP0AAA') #=> nil

# Check the details of a SOTA summit by giving its reference:
ShackKit::Data::SOTASummits.check('SP/BZ-059')
#=> {:id=>148420, :summit_code=>"SP/BZ-057", :association_name=>"Poland", :region_name=>"Beskidy Zachodnie",
#    :summit_name=>"Koskowa Góra", :alt_m=>866, :alt_ft=>2841, :grid_ref1=>"19.7833", :grid_ref2=>"49.7528",
#    :longitude=>19.7833, :latitude=>49.7528, :points=>6, :bonus_points=>0,
#    :valid_from=>#<Date: 2008-04-01 ((2454558j,0s,0n),+0s,2299161j)>, :valid_to=>#<Date: 2099-12-31 ((2488069j,0s,0n),+0s,2299161j)>,
#    :activation_count=>29, :activation_date=>#<Date: 2016-03-31 ((2457479j,0s,0n),+0s,2299161j)>,
#    :activation_call=>"SQ9OZM/P"}

```

#### Online data lookup

Online means here that you need Internet access to perform a lookup and that the services you are querying are available when you do it.

```ruby
require 'shack_kit'

# To be able to query QRZ.com from your Ruby code you need to have created an account there.
# First, create a query object like this, substituting your own callsign and password:
qrz = ShackKit::Data::QRZ.new(login: "SQ9OZM", password: "t0ps3cr37")
=> #<ShackKit::Data::QRZ:0x007fc1424be8e8 @session_key="72e0ab57811969fd98f64692875d2c98">

# After that, you can make multiple queries until the session key expires (after one hour)
qrz.lookup("SQ9OZM")
=> {:call=>"SQ9OZM", :fname=>"Marcin", :name=>"Bajer", :addr2=>"Dobczyce", :country=>"Poland", :message=>"A subscription is required to access the complete record."}

qrz.lookup("EA0JC")
=> {:call=>"EA0JC", :fname=>"ex King of Spain", :name=>"- QSL ONLY via EA4URE", :addr2=>"P.O. Box: 55.055 - Madrid", :country=>"Spain", :message=>"A subscription is required to access the complete record."}

qrz.lookup("SP9KDR")
=> {:call=>"SP9KDR", :fname=>"Klub Krótkofalowców", :name=>"Dolina Raby", :addr2=>"Pcim", :country=>"Poland", :message=>"A subscription is required to access the complete record."}

qrz.lookup("N0CALL")
=> {:error=>"Not found: N0CALL"}

# To be able to query HamQTH from your Ruby code you need to have created an account there.
# First, create a query object like this, substituting your own callsign and password:
hamqth = ShackKit::Data::HamQTH.new(login: "SQ9OZM", password: "an07h3rs3cr37")
=> #<ShackKit::Data::HamQTH:0x007fc1427378b8 @session_key="984ebf6d925ee0bb12daaad00367d2c79d3c0e1e">

# After that, you can make multiple queries until the session key expires (after one hour)
hamqth.lookup("SQ9OZM")
=> {:callsign=>"SQ9OZM", :nick=>"Marcin", :qth=>"Dobczyce", :country=>"Poland", :adif=>"269", :itu=>"28", :cq=>"15", :grid=>"KN09BV", :adr_name=>"Marcin Bajer", :adr_street1=>"Marwin 199", :adr_city=>"Dobczyce", :adr_zip=>"32-410", :adr_country=>"Poland", :adr_adif=>"269", :district=>"M", :lotw=>"Y", :qsldirect=>"Y", :qsl=>"Y", :eqsl=>"Y", :email=>"sq9ozm@tigana.pl", :web=>"http://sq9ozm.tumblr.com", :latitude=>"49.880729", :longitude=>"20.116471", :continent=>"EU", :utc_offset=>"-1"}

hamqth.lookup("EA0JC")
=> {:callsign=>"ea0jc", :nick=>"King", :qth=>"Madrid", :country=>"Spain", :adif=>"281", :itu=>"37", :cq=>"14", :grid=>"IN80DJ", :adr_name=>"King Juan Carlos De Borb~n", :adr_street1=>"Royal Palace", :adr_city=>"Madrid", :adr_zip=>"", :adr_country=>"Spain", :adr_adif=>"281", :lotw=>"?", :qsldirect=>"?", :qsl=>"?", :eqsl=>"?", :latitude=>"40.416648864746094", :longitude=>"-3.7144553661346436", :continent=>"EU", :utc_offset=>"-1"}

hamqth.lookup("SP9KDR")
=> {:error=>"Callsign not found"}

hamqth.lookup("N0CALL")
=> {:error=>"Callsign not found"}

# In case you do not want to enter the QRZ.com/HamQTH.com password in your code,
# create a shack_kit config file at `~/.shack_kit/config.yml`
# with the following structure (subsitute your own callsigns and passwords):
  qrz_com:
    login: SQ9OZM
    password: t0ps3cr37
  ham_qth:
    login: SQ9OZM
    password: an07h3rs3cr37

# After that, the query objects can be created simply:

qrz = ShackKit::Data::QRZ.new
=> #<ShackKit::Data::QRZ:0x007fc1427cf8e8 @session_key="72e0ab57811969fd98f64692875d2c98">

hamqth = ShackKit::Data::HamQTH.new
=> #<ShackKit::Data::HamQTH:0x007fc142774380 @session_key="f0d0f750193b936927fdd841f459f4fb8de1a2a3">

# To get callsign information at qrz.pl from your Ruby code you do not need any account there.
# Just run the lookup like this:

ShackKit::Data::QRZ_PL.lookup("SP9AMH")
=> {:callsign=>"SP9AMH", :details=>["Data rejestracji: 2009-03-27 10:42:00", "Licznik odwiedzin strony: sp9amh.qrz.pl wskazuje: 6916"], :grid=>nil}

ShackKit::Data::QRZ_PL.lookup("SP9KDR")
=> {:callsign=>"SP9KDR", :details=>["Klub Krotkofalowcow Doliny Raby", "Pcim 597", "32-432 Pcim", "POLSKA", "LOKATOR: JN99XS", "QSL MANAGER: PZK OT-12", "QRG: FM: 145.450MHz  DV: 438.150MHz", "SP9KDR na mapie kompaktowej lub pe\xB3noekranowej", "Data rejestracji: 2012-12-06 22:14:58", "Licznik odwiedzin strony: sp9kdr.qrz.pl wskazuje: 1575"], :grid=>"JN99XS"}

ShackKit::Data::QRZ_PL.lookup("SP9KGP")
=> {:callsign=>"SP9KGP", :details=>["Klub Turystyczno-Radiowo-Astronomiczny 'Ryjek' SP9KGP", "Schronisko PTTK na Luboniu Wielkim", "34 - 701 Rabka Zaryte 165", "Polska", "LOKATOR: JN99XP", "QSL MANAGER: SQ9MCK", "QRG: 145.550 MHz", "SP9KGP na mapie kompaktowej lub pe\xB3noekranowej", "Data rejestracji: 2006-07-29 01:35:41", "Licznik odwiedzin strony: sp9kgp.qrz.pl wskazuje: 21432"], :grid=>"JN99XP"}

ShackKit::Data::QRZ_PL.lookup("EA0JC")
=> {:error=>"Not found: EA0JC"}
```


#### Refreshing the data in ShackKit database

##### SOTA callsigns
Christophe ON6ZQ compiles the reference data every night and publishes them at http://www.on6zq.be/w/index.php/SOTA/MasterDta in a [zip file](http://www.on6zq.be/p/SOTA/SOTAdata/masterSOTA.zip). Upon extracting the zip, check for file named `masterSOTA.scp` and load its content into ShackKit database like this:

```ruby
ShackKit::Data::SOTACalls.update('masterSOTA.scp')
=> 6328 (this is the count of loaded callsigns)
```

##### SOTA summits
Summits on the Air Management Team maintains the database of SOTA award program at http://www.sotadata.org.uk. The database includes a list of summits,
updated daily, available for download in CSV format by following a link from the bottom of the [summits page](http://www.sotadata.org.uk/summits.aspx).
The file can be loaded into ShackKit database like this:
```ruby
ShackKit::Data::SOTASummits.update("db/sources/summitslist.csv")
=> 95618 (this is the count of loaded summits)
```
It is a large dataset and will take a while to load.

##### SP callsigns
[UKE, the Office of Electronic Communication](https://en.uke.gov.pl) has the authority over issuing amateur radio licenses in Poland. The current lists of valid licenses are published separately for individual and club stations and are downloadable as CSV files from these pages: https://amator.uke.gov.pl/individuals?locale=en (Individuals) and https://amator.uke.gov.pl/clubs?locale=en (Clubs). There is a blue "Download" button on the bottom left of each page. Both datasets can be then loaded into ShackKit database like this:

```ruby
ShackKit::Data::SPCalls.update("db/sources/individuals_2016-04-01.csv", "db/sources/clubs_2016-04-01.csv")
=> 13321 (number of loaded callsigns)
```

Starting with version 0.2.1 it is possible to update SP callsigns dataset automatically from UKE website:
```ruby
ShackKit::Data::SPCalls.update_online
=> 14234 (number of loaded callsigns)
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rrrodrigo/shack_kit.

## Acknowledgments

ShackKit development has been sponsored by my employer [Ragnarson](http://www.ragnarson.com), a Ruby software shop from Poland, which is supporting open software contributions of its employees during quarterly Ragnarson Open Day events.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
