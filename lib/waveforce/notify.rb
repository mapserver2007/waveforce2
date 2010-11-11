# -*- coding: utf-8 -*-
require 'waveforce/store'

module WaveForce
  class Notify
    def initialize(params)
      @request = params
      @dbdir = params[:db]
      @response_border = params[:response_border]
    end

    def run(data)
      channel = WaveForce.mapper(data[:channel])
      response = data[:response]
      db = WaveForce::Store.new(
        Pathname.new("#{@dbdir}/" + DBNAME).cleanpath.to_s
      )
      # DBから読み込む
      data[:prev_response] = db.load(channel) || DEFAULT_RESPONSE
      # 通知する
      result = notify(data)
      # DBに書き込む
      db.save(channel, response)
      result
    end

    # Growl経由で通知する
    def notify(data)
      data = notifiable(data)
      begin
        timeout(NOTIFY_TIMEOUT) do
          GNTP.notify(data.merge(@request))
        end unless data.nil?
        data
      # ホストが間違っている場合
      rescue SocketError => e
        raise GrowlInvalidHostException, "Invalid host."
      # パスワードが間違っている場合
      rescue RuntimeError => e
        raise GrowlInvalidConfigException, "Invalid password."
      # ローカルマシンでGrowlが起動していない場合
      rescue Timeout::Error
        raise GrowlBootException, "Growl does not started."
      # その他のエラー
      rescue => e
        raise e.message
      end
    end

    # 通知レベルを判定して通知用データを返却する
    def level(name, data, ratio)
      title = "LEVEL:#{eval("LEVEL_" + name.to_s.upcase)}\n#{data[:response]}レス/分 加速率:#{ratio}%"
      text = "#{data[:channel]} - #{data[:program]}"
      {:title => title, :text => text}
    end

    # 通知可能なデータを抽出する
    def notifiable(data)
      rb1 = data[:prev_response].to_i
      rb2 = data[:response].to_i
      # 今回取得の勢いが閾値を超えている場合
      if rb2 > @response_border
        ratio = ((rb2.to_f / rb1 - 1) * 100).round rescue 0
        case ratio
        # 前回比較で勢いの伸びが100%～199%の場合
        when 100 .. 199
          level :warning, data, ratio
        # 前回比較で勢いの伸びが200%～299%の場合
        when 200 .. 299
          level :important, data, ratio
        # 前回比較で勢いの伸びが300%超の場合
        when 300 .. (1.0 / 0)
          level :emergency, data, ratio
        end
      end
    end
  end
end