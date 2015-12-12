json.array!(@youtube_song_infos) do |youtube_song_info|
  json.extract! youtube_song_info, :id, :title, :youtube_id, :time, :attr
  json.url youtube_song_info_url(youtube_song_info, format: :json)
end
