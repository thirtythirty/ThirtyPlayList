class CreateYoutubeSongInfos < ActiveRecord::Migration
  def change
    create_table :youtube_song_infos do |t|
      t.string :title
      t.string :youtube_id
      t.integer :time
      t.string :attr

      t.timestamps null: false
    end
  end
end
