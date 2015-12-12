require 'test_helper'

class YoutubeSongInfosControllerTest < ActionController::TestCase
  setup do
    @youtube_song_info = youtube_song_infos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:youtube_song_infos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create youtube_song_info" do
    assert_difference('YoutubeSongInfo.count') do
      post :create, youtube_song_info: { attr: @youtube_song_info.attr, time: @youtube_song_info.time, title: @youtube_song_info.title, youtube_id: @youtube_song_info.youtube_id }
    end

    assert_redirected_to youtube_song_info_path(assigns(:youtube_song_info))
  end

  test "should show youtube_song_info" do
    get :show, id: @youtube_song_info
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @youtube_song_info
    assert_response :success
  end

  test "should update youtube_song_info" do
    patch :update, id: @youtube_song_info, youtube_song_info: { attr: @youtube_song_info.attr, time: @youtube_song_info.time, title: @youtube_song_info.title, youtube_id: @youtube_song_info.youtube_id }
    assert_redirected_to youtube_song_info_path(assigns(:youtube_song_info))
  end

  test "should destroy youtube_song_info" do
    assert_difference('YoutubeSongInfo.count', -1) do
      delete :destroy, id: @youtube_song_info
    end

    assert_redirected_to youtube_song_infos_path
  end
end
