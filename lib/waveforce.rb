# -*- coding: utf-8 -*-
require 'waveforce/crawler'
require 'waveforce/utils'

module WaveForce
  VERSION = '0.2.0'
  APP_NAME = 'waveforce2'
  CRAWLE_URL = "http://www.tv2ch.info/"
  CRAWLE_TIMEOUT = 3
  NOTIFY_TIMEOUT = 3
  DEFAULT_RESPONSE = 0
  DEFAULT_RESPONSE_BORDER = 30
  DBNAME = "waveforce.db"
  LOG_LEVEL = 1
  LEVEL_EMERGENCY = "★★★"
  LEVEL_IMPORTANT = "★★"
  LEVEL_WARNING   = "★"

  require 'timeout'
  class CrawlerException < Exception; end
  class ConfigFileNotFoundException < RuntimeError; end
  class GrowlInvalidHostException < SocketError; end
  class GrowlInvalidConfigException < Timeout::Error; end
  class GrowlBootException < RuntimeError; end
  class ChannelMappingException < RuntimeError; end

  class << self
    # 共通設定
    def init(params)
      params[:app_name] = APP_NAME
      begin
        params.merge!(Utils.load(params[:config]))
      rescue
        @log = Log.new(params[:log], params[:debug])
        unless params[:config].nil?
          raise ConfigFileNotFoundException, "Config file not found."
        end
      end
      @log = Log.new(params[:log], params[:debug])
      params[:response_border] ||= DEFAULT_RESPONSE_BORDER
      params
    end

    # 通知処理を開始する
    def notify(params)
      begin
        init(params)
        notifier = Notify.new(params)
        channel_data.each do |data|
          result = notifier.run(data)
          unless result.nil?
            @log.info = "#{result[:text]} / #{result[:title].gsub(/\n/, ' - ')}"
          end
        end
      rescue => e
        @log.error = e.message
      end
      # エラーがあった場合は出力
      @log.error.print
      @log.fatal.print
    end

    # 地上波実況データを取得する
    def channel_data
      data = []
      begin
        data = Crawler.new.run
      rescue CrawlerException=> e
        @log.error = e.message
      end
      data
    end

    # チャンネルをマッピングする
    def mapper(v)
      channel_en = [
        'nhk1','nhk2','ntv','tbs','fuji','asahi','tx'
      ]
      channel_ja = [
        'NHK総合','NHK教育','日本テレビ','TBSテレビ','フジテレビ','テレビ朝日','テレビ東京'
      ]
      if !channel_en.index(v).nil?
        channel_ja[channel_en.index(v)]
      elsif !channel_ja.index(v).nil?
        channel_en[channel_ja.index(v)]
      end
    end
  end
end