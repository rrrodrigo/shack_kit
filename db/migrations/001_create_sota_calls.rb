Sequel.migration do
  change do
    create_table(:sota_calls) do
      String :callsign, index: true, null: false
    end
  end
end