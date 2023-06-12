class AddConstraintsToUsers < ActiveRecord::Migration[6.0]
  def up
    change_column :users, :username, :string, null: false, default: '', limit: 25
    change_column :users, :status, :string, null: false, default: '', limit: 50
    change_column :users, :phone, :string, null: false, limit: 13, default: ''
    change_column :users, :verified, :boolean, default: false
    
    execute <<-SQL
      CREATE TRIGGER users_insert_username_constraint
      BEFORE INSERT ON users
      FOR EACH ROW
      WHEN (length(NEW.username) > 25)
      BEGIN
        SELECT RAISE(ABORT, 'Username must be 25 characters or less');
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER users_update_username_constraint
      BEFORE UPDATE ON users
      FOR EACH ROW
      WHEN (length(NEW.username) < 5 OR length(NEW.username) > 25)
      BEGIN
        SELECT RAISE(ABORT, 'Username must be between 5 and 25 characters');
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER users_insert_status_constraint
      BEFORE INSERT ON users
      FOR EACH ROW
      WHEN (length(NEW.status) > 50)
      BEGIN
        SELECT RAISE(ABORT, 'Status must be 50 characters or less');
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER users_update_status_constraint
      BEFORE UPDATE ON users
      FOR EACH ROW
      WHEN (length(NEW.status) < 5 OR length(NEW.status) > 50)
      BEGIN
        SELECT RAISE(ABORT, 'Status must be between 5 and 50 characters');
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER users_insert_phone_constraint
      BEFORE INSERT ON users
      FOR EACH ROW
      WHEN (length(NEW.phone) < 11 OR length(NEW.phone) > 13)
      BEGIN
        SELECT RAISE(ABORT, 'Phone must be between 11 and 13 characters');
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER users_update_phone_constraint
      BEFORE UPDATE ON users
      FOR EACH ROW
      WHEN (length(NEW.phone) < 11 OR length(NEW.phone) > 13)
      BEGIN
        SELECT RAISE(ABORT, 'Phone must be between 11 and 13 characters');
      END;
    SQL
  end

  def down
    change_column :users, :phone, :string, null: true
    change_column :users, :status, :string, null: true
    change_column :users, :username, :string, null: true
    change_column :users, :verified, :boolean, default: nil
    execute <<-SQL
      DROP TRIGGER IF EXISTS users_insert_username_constraint;
      DROP TRIGGER IF EXISTS users_update_username_constraint;
      DROP TRIGGER IF EXISTS users_insert_status_constraint;
      DROP TRIGGER IF EXISTS users_update_status_constraint;
      DROP TRIGGER IF EXISTS users_insert_phone_constraint;
      DROP TRIGGER IF EXISTS users_update_phone_constraint;
    SQL
  end
end
