Sequel.migration do
  change do
    rename_column :sp_calls, :uke_branch, :club_name
  end
end
