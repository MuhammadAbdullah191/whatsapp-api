class AddConstraintsToMessages < ActiveRecord::Migration[6.0]
  def up
    change_column :messages, :content, :string, null: false, default: '', limit: 2000

    execute <<-SQL
      CREATE TRIGGER messages_insert_content_constraint
      BEFORE INSERT ON messages
      FOR EACH ROW
      WHEN (length(NEW.content) > 2000)
      BEGIN
        SELECT RAISE(ABORT, 'Content must be 2000 characters or less');
      END;§
    SQL

    execute <<-SQL
      CREATE TRIGGER messages_update_content_constraint
      BEFORE UPDATE ON messages
      FOR EACH ROW
      WHEN (length(NEW.content) > 2000)
      BEGIN
        SELECT RAISE(ABORT, 'Content must be 2000 characters or less');
      END;
    SQL

  end

  def down
    change_column :messages, :content, :string, null: true, default: nil
    execute <<-SQL
      DROP TRIGGER IF EXISTS messages_insert_content_constraint;
      DROP TRIGGER IF EXISTS messages_update_content_constraint;
    SQL
  end

end
