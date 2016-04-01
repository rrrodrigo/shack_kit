Sequel.migration do
  change do
    create_table(:sota_summits) do
      primary_key :id
      String    :summit_code, index: true, null: false
      String    :association_name
      String    :region_name
      String    :summit_name
      Integer   :alt_m
      Integer   :alt_ft
      String    :grid_ref1
      String    :grid_ref2
      Float     :longitude
      Float     :latitude
      Integer   :points
      Integer   :bonus_points
      Date      :valid_from
      Date      :valid_to
      Integer   :activation_count
      Date      :activation_date
      String    :activation_call
    end
  end
end