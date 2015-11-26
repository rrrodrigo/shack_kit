Sequel.migration do
  change do
    create_table(:sota_calls) do
      primary_key :id
      String :callsign, null: false
    end
  end
end