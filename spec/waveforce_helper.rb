require 'rspec'
require File.dirname(__FILE__) + "/../lib/waveforce"
require File.dirname(__FILE__) + "/../lib/waveforce/notify"
require File.dirname(__FILE__) + "/../lib/waveforce/utils"

module WaveForce
  class Rspec
    def method_missing(name, *args)
      attr = name.to_s
      if @attr == "params"
        config = Utils.load(File.dirname(__FILE__) + "/spec_config.yml")
        @attr = nil
        if attr == "common" || attr == "other"
          config[attr.to_sym].inject({}){|r, entry| r[entry[0].to_sym] = entry[1]; r}
        else
          config[:common][attr] || config[:other][attr]
        end
      elsif attr == "params"
        @attr = attr
        self
      end
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