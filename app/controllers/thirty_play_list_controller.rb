class ThirtyPlayListController < ApplicationController
  def main # "/"
    @key_song_list = []
    if(cookies[:key_song] && cookies[:key_time])
      @key_song_list = cookies[:key_song].split(',')
    end
  end

  def play # "/play/:video_id/:time" 受け取ったデータをもとに動画を再生
   @song_list = params['video_id'].split(',') # urlパラメータから曲のリストを取得
   @time = params['time'].to_i
  end

  def detect # "/detect/:times" 15分プレイリストを計算するところ
    @song_data = [] # 曲のyoutube_id,時間を入れる2次元配列
    if(cookies[:key_song] && cookies[:key_time]) # key_song用のcookiesが存在するなら
     key_id = cookies[:key_song].split(',')
     key_time = cookies[:key_time].split(',')
     if(key_id.count == key_time.count) # 同じ数あるか確認
       key_id.count.times do |i|
         @song_data << [key_id[i],key_time[i].to_i] # 追加
       end
     end
    end
    data = YoutubeSongInfo.all # データベースから曲のデータを取ってくる
    data.each do |i|
      @song_data << [i.youtube_id,i.time] # 追加
    end

    key_song = @song_data.first(params[:times].to_i) # 先頭に入っているものをkey_songとして取っておく

    @song_data = @song_data.sort_by{|data| -data[1]} # 再生時間が大きい順ソート (detect_play_list関数のため
    gosa = 0 # 誤差
    @song_num_max = @song_data.count # すべての曲数
    @range_min = 15*60 -gosa # 範囲を15分に設定
    @range_max = 15*60 +gosa

    # 15分プレイリストを計算
    @result = detect_play_list(0,[],0) # 再帰関数により、合計時間が15分になったプレイリストを見つける。そしてそのインデックスを返す

    list = []
    @result.each do |i| # インデックスを用いて、youtube_idと時間がペアになった配列を作る
      buf = []
      i.each do |j|
        buf << @song_data[j]
      end
      list << buf
    end    

    use_song_list = []
    params['times'].to_i.times do |i| # key_songが必ず1つ入ったプレイリストの配列を作る 
      buf = list.select do |item|
        flag = true #フラグを初期化
        if(id_include?(item,key_song[i][0]) != true) # 任意のkey_songが含まれてないならだめ
          flag =  false
        end
        key_song.count.times do |count|
          if(flag)
            if(count != i)
              if(id_include?(item,key_song[count][0])) # 他のkey_songが含まれているならだめ
                flag = false
              end
            end
          end
        end
        # return flagとするとdetectアクションを抜けてしまうので,return省略
        flag
      end
      if(buf == [] || buf == false) # 該当するものがなかったら"/"に戻す
        redirect_to("/",:notice => "プレイリストが見つかりませんでした")
        return
      else
        use_song_list << buf
      end
    end

    use_song = []
    i=0
    use_song_list.each do |value|
      use_song << value.sample # key_songが一つ含まれている曲リストたちからランダムで1つ選ぶ
      use_song[i].delete(key_song[i]) # key_songを一回消す
      use_song[i].unshift(key_song[i])# そして前につける
      i += 1
    end
    
    send_list = []
    send_time = 0
    use_song.each do |i| # youtube_id と時間を分けて、処理
      i.each do |j|
        send_list.unshift(j[0]) # 前に入れていき、順番を変える
        send_time += j[1] # 合計時間を計算 
      end
    end

    redirect_to "/play/#{send_list.join(',')}/#{send_time}" # 再生ページにリダイレクト
  end

  def set # "/set(/:video_id/:time)" 動画から再生時間を取得し、key_songとしてcookiesに保存する。
   if(params['time']) # このパラメータがあるということは、redirectしてきたということ。cookiesを設定する 
     if(cookies[:key_song] && cookies[:key_time]) # cookiesの存在を確認
       key_song = cookies[:key_song].split(',') # クッキーを配列としていれる
       key_time = cookies[:key_time].split(',')
     else # ないなら空の配列 
       key_song = []
       key_time = []
     end
     if(key_song.count >= 4 && key_time.count >= 4) # 要素の数が4個までにしたいので、4個以上のときは古いほうから１つ消す
       key_song.pop
       key_time.pop
     end
     key_song.unshift(params['video_id']) # 要素を追加
     key_time.unshift(params['time'])
     
     if(key_song.count != key_song.uniq.count) # 要素がかぶっていたらだめ
       redirect_to("/",:notice => "#{params['video_id']}はすでに設定されてます。")
       return
     end
     if(params['time'].to_i > 900) # 要素が15分以上では15分プレイリストがどうやっても作れないのでだめ
       redirect_to("/",:notice => "#{params['video_id']}の再生時間が長すぎます。少なくとも15分以下のものにしてください。")
       return
     end
     if(params['time'].to_i <= 0) # 時間が0より小さいことはありえない
        redirect_to("/",:notice => "key_songの設定に失敗しました。")
        return
     end
     # クッキーを保存
     cookies[:key_song] = { value:key_song.join(','),
       expires:3.months.from_now, http_only: true}
     cookies[:key_time] = { value:key_time.join(','),
       expires:3.months.from_now, http_only: true}

    redirect_to("/",:notice => "key_songの設定に成功しました")
   end
   @video_id = params['video_id'].to_s # youtube_idを用いて動画をiframeで読み込んで再生時間を取得するために、変数にidを保存し、javascriptへ渡す準備をする
  end

  # 2015/11/22新しく追加
  def cookies_delete
    delete_num = params['delete_num'].to_i
    if(cookies[:key_song] && cookies[:key_time]) # cookiesの存在を確認
     key_song = cookies[:key_song].split(',') # クッキーを配列としていれる
     key_time = cookies[:key_time].split(',')
    else # ないなら空の配列 
      redirect_to("/",:notice => "key_songは設定されていません。")
      return
    end
    key_song.delete_at(delete_num)
    key_time.delete_at(delete_num)
    # クッキーを保存
    cookies[:key_song] = { value:key_song.join(','),
     expires:3.months.from_now, http_only: true}
    cookies[:key_time] = { value:key_time.join(','),
     expires:3.months.from_now, http_only: true}

    redirect_to("/",:notice => "key_songを削除しました。")
  end

  private
  def detect_play_list(total,list,index) # 本システムの最重要箇所
    result = []# 初期化
    while index < @song_num_max # 曲数なるまでループ
      total_ = total # トータルを複製
      list_ = []     # 初期化
      list.each do |i| # 曲リストを複製
        list_ << i
      end
      total_ += @song_data[index][1] # 再生時間を足す
      if total_ < @range_min    # 目的の時間より小さいとき
        list_ << index        # リスト追加
        result.concat(detect_play_list(total_,list_,index+1)) # 再帰する　返り値をresultへつなげる
      elsif total_ > @range_max # 目的の時間より大きいとき
        #何もしない
      else                      # ここに入ったってことはマッチした
        list_ << index        # リスト追加
        result << list_       # resultに入れる
      end
        index +=1
    end
    return result # 曲リストの配列を返す
  end

  def id_include?(target,serch_id) # youtube_idが含まれているか調べる関数
    target.each do |i|
      if(i[0] == serch_id)
        return true
      end
    end
    return false
  end
end
