require 'rspec'
require File.dirname(__FILE__) + "/../lib/waveforce"
require File.dirname(__FILE__) + "/../lib/waveforce/notify"

module WaveForce
  class Rspec
    DUMMY_VALUE = "xxxxxxxxxx"
    # 共通パラメータ
    def params
      {
        :host => "localhost",
        :passwd => "paranoia",
        :log => "e:/tmp",
        :debug => false,
        :db => "e:/tmp",
        :response_border => 10,
        :icon => nil,
        :config => nil
      }
    end

    # テスト用に必ず通知レベルWarningで返すようにメソッドを書き換える
    # テストケースが多いので通知処理は1回で終了する
    def rewrite_nofiable(level = :warning, ikioi = 100)
      WaveForce::Notify.const_set(:LEVEL, level)
      WaveForce::Notify.const_set(:IKIOI, ikioi)
      WaveForce::Notify.class_eval do
        def notifiable(data)
          unless !!@notified
            @notified = true
            level LEVEL, data, IKIOI
          else
            nil
          end
        end
      end
    end

    # 実行結果ログを取得するメソッドを動的に定義
    def add_log_inspector
      WaveForce::Log.class_eval do
        def log_inspector(level)
          @debug[level]
        end
      end

      class << WaveForce
        def log_inspector(level)
          @log.log_inspector(level.to_s)
        end
      end
    end

    # 実行結果エラーログを確認する
    def error_inspector(msg)
      WaveForce.log_inspector(:error).each do |inspect_msg|
        inspect_msg.should == msg
      end
    end

    # 定数を書き換える
    def rewrite_constant(name, value)
      WaveForce.module_eval{remove_const(name)}
      WaveForce.const_set(name, value)
    end

    # 定数を初期化する
    def init_constant
      WaveForce::Notify.class_eval{remove_const(:LEVEL)}
      WaveForce::Notify.class_eval{remove_const(:IKIOI)}
    end
  end
end