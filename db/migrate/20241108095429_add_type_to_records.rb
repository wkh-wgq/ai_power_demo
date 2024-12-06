class AddTypeToRecords < ActiveRecord::Migration[7.2]
  def change
    add_column :records, :type, :string, null: false, default: 'text', comment: '类型(文本text/图片picture/音频audio)'
    add_column :records, :file_id, :string
  end
end
