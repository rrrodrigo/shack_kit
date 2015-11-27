Sequel.migration do
  change do
    create_table(:sp_calls) do
      String  :callsign, index: true, null: false
      String  :station_type
      String  :uke_branch
      String  :licence_number
      Date    :valid_until
      String  :licence_category, size: 1
      Integer :tx_power
      String  :station_location
    end
  end
end