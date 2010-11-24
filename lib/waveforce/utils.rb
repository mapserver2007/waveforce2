require 'logger'
require 'pathname'

module WaveForce
  module Utils
    class << self
      def file?(e)
        !!(FileTest.exist?(e) rescue nil)
      end

      def directory?(e)
        !!(FileTest::directory?(e) rescue nil)
      end

      def os_encoding
        RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|cygwin|bccwin/ ?
          "Windows-31J" : "UTF-8"
      end

      def load(path)
        config = YAML.load_file(path)
        config.inject({}){|r, entry| r[entry[0].to_sym] = entry[1]; r}
      end
    end
  end

  class Log
    def initialize(path, debug_on)
      @debug = {}
      @debig_on = debug_on
      if Utils.directory? path
        level = [0, 1, 2, 3, 4].index(LOG_LEVEL) || Logger::DEBUG
        @log = Logger.new(logfile(path))
        @log.level = level
      else
        @debug["error"] = []
        @debug["error"] << "Invalid log directory path." unless path.nil?
      end
    end

    def logfile(dir)
      Pathname.new(dir + "/" + "#{Time.now.strftime("%Y%m%d")}.log").cleanpath
    end

    def write(name, *args)
      # ログ出力処理、デバッグスタックに保存
      if name =~ /=$/
        name.chop!
        @debug[name] = [] unless @debug[name].instance_of?(Array)
        args[0].each do |msg|
          @log.send(name, msg.encode(Utils.os_encoding)) unless @log.nil?
          @debug[name] << msg
        end
      end
    end

    def debug(name)
      # デバッグメッセージを標準出力
      if name == 'print'
        @debug[@name].each do |msg|
          puts msg
        end if @debug[@name].instance_of?(Array) && @debig_on
      else
         # ログメソッドを保存
        @name = name
        self
      end
    end

    def method_missing(name, *args)
      attr = name.to_s
      write(attr, args)
      debug(attr)
    end
  end
end
