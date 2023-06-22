class AddConstraintsToOtp < ActiveRecord::Migration[6.0]
  def up
    change_column :otps, :code, :string, null: false, default: '', limit: 6
    change_column :otps, :expiration_time, :datetime, null: false
    execute <<-SQL
      CREATE TRIGGER otps_insert_code_constraint
      BEFORE INSERT ON otps
      FOR EACH ROW
      WHEN (length(NEW.code) != 6)
      BEGIN
        SELECT RAISE(ABORT, 'Code must be 6 characters');
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER otps_update_code_constraint
      BEFORE UPDATE ON otps
      FOR EACH ROW
      WHEN (length(NEW.code) != 6)
      BEGIN
        SELECT RAISE(ABORT, 'Code must be 6 characters');
      END;
    SQL

  end

  def down
    change_column :otps, :expiration_time, :datetime, null: true, default: nil
    change_column :otps, :code, :string, null: true, default: nil
    execute <<-SQL
      DROP TRIGGER IF EXISTS otps_insert_code_constraint;
      DROP TRIGGER IF EXISTS otps_update_code_constraint;
    SQL
  end

end
