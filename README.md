# ShackKit

Collection of HAM radio utilities packaged as Ruby gem, by SQ9OZM

## Functionality
### Data lookup
 * SOTA callsigns checker, using ON6ZQ database of SOTA activators and chasers (http://www.on6zq.be/w/index.php/SOTA/MasterDta)
 * SOTA summits checker, using the database of SOTA summits published at http://sotadata.org.uk/summits.aspx by Summits on the Air
 * SP operators callsigns checker, using data published by Republic of Poland Office of Electronic Communication (https://amator.uke.gov.pl/?locale=en)

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

#### How to use the data lookup functionality?

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

#### How to refresh the data in ShackKit database?

##### SOTA callsigns
Christophe ON6ZQ compiles the reference data every night and publishes them at http://www.on6zq.be/w/index.php/SOTA/MasterDta in a [zip file](http://www.on6zq.be/p/SOTA/SOTAdata/masterSOTA.zip). Upon extracting the zip, check for file named `masterSOTA.scp` and load its content into ShackKit database like this:

```ruby
ShackKit::Data::SOTACalls.update('masterSOTA.scp') #=> 6328 (this is the count of loaded callsigns)
```

##### SOTA summits
Summits on the Air Management Team maintains the database of SOTA award program at http://www.sotadata.org.uk. The database includes a list of summits,
updated daily, available for download in CSV format by following a link from the bottom of the [summits page](http://www.sotadata.org.uk/summits.aspx).
The file can be loaded into ShackKit database like this:
```ruby
ShackKit::Data::SOTASummits.update("db/sources/summitslist.csv") #=> 95618 (this is the count of loaded summits)
```
It is a large dataset and will take a while to load.

##### SP callsigns
[UKE, the Office of Electronic Communication](https://en.uke.gov.pl) has the authority over issuing amateur radio licenses in Poland. The current lists of valid licenses are published separately for individual and club stations and are downloadable as CSV files from these pages: https://amator.uke.gov.pl/individuals?locale=en (Individuals) and https://amator.uke.gov.pl/clubs?locale=en (Clubs). There is a blue "Download" button on the bottom left of each page. Both datasets can be then loaded into ShackKit database like this:

```ruby
ShackKit::Data::SPCalls.update("db/sources/individuals_2016-04-01.csv", "db/sources/clubs_2016-04-01.csv") #=> 13321 (number of loaded calls)
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


