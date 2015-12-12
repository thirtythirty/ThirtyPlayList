class YoutubeSongInfosController < ApplicationController
  before_action :set_youtube_song_info, only: [:show, :edit, :update, :destroy]

  # GET /youtube_song_infos
  # GET /youtube_song_infos.json
  def index
    @youtube_song_infos = YoutubeSongInfo.all
  end

  # GET /youtube_song_infos/1
  # GET /youtube_song_infos/1.json
  def show
  end

  # GET /youtube_song_infos/new
  def new
    @youtube_song_info = YoutubeSongInfo.new
  end

  # GET /youtube_song_infos/1/edit
  def edit
  end

  # POST /youtube_song_infos
  # POST /youtube_song_infos.json
  def create
    @youtube_song_info = YoutubeSongInfo.new(youtube_song_info_params)

    respond_to do |format|
      if @youtube_song_info.save
        format.html { redirect_to @youtube_song_info, notice: 'Youtube song info was successfully created.' }
        format.json { render :show, status: :created, location: @youtube_song_info }
      else
        format.html { render :new }
        format.json { render json: @youtube_song_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /youtube_song_infos/1
  # PATCH/PUT /youtube_song_infos/1.json
  def update
    respond_to do |format|
      if @youtube_song_info.update(youtube_song_info_params)
        format.html { redirect_to @youtube_song_info, notice: 'Youtube song info was successfully updated.' }
        format.json { render :show, status: :ok, location: @youtube_song_info }
      else
        format.html { render :edit }
        format.json { render json: @youtube_song_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /youtube_song_infos/1
  # DELETE /youtube_song_infos/1.json
  def destroy
    @youtube_song_info.destroy
    respond_to do |format|
      format.html { redirect_to youtube_song_infos_url, notice: 'Youtube song info was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_youtube_song_info
      @youtube_song_info = YoutubeSongInfo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def youtube_song_info_params
      params.require(:youtube_song_info).permit(:title, :youtube_id, :time, :attr)
    end
end
