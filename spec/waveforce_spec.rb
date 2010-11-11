# -*- coding: utf-8 -*-
require File.dirname(__FILE__) + "/waveforce_helper.rb"

describe WaveForce, 'が実行する処理' do
  before do
    @rspec = WaveForce::Rspec.new
    @rspec.rewrite_nofiable
    @rspec.add_log_inspector
    @params = @rspec.params
    @dummy = WaveForce::Rspec::DUMMY_VALUE
  end

  after do
    @rspec.init_constant
  end

  describe "正常系" do
    after do
      WaveForce.log_inspector(:error).should be_nil
    end

    it "コマンドライン引数による実行ができること" do
      WaveForce.notify(@params)
    end

    it "設定ファイルによる実行ができること" do
      # TODO ハードコードはいずれ設定ファイルに移す
      @params[:config] = "e:/tmp/config.yml"
      WaveForce.notify(@params)
    end

    it "パスワード指定正常、DBファイル指定正常、アドレスなしの場合、正常に実行出来ること" do
      @params[:host] = nil
      WaveForce.notify(@params)
    end

    it "アイコンの指定が間違っている場合でも正常に実行出来ること" do
      # TODO ハードコードはいずれ設定ファイルに移す
      @params[:icon] = "http://xxxxxxxxxxxxxxxxxxxxx/xxx.png"
      WaveForce.notify(@params)
    end

    it "WARNINGレベル(勢い100～199％増)の通知を受信できること" do
      @rspec.init_constant
      @rspec.rewrite_nofiable(:warning, 100)
      WaveForce.notify(@params)
    end

    it "IMPORTANTレベル(勢い200～299％増)の通知を受信できること" do
      @rspec.init_constant
      @rspec.rewrite_nofiable(:important, 200)
      WaveForce.notify(@params)
    end

    it "EMERGENCYレベル(勢い300％超増)の通知を受信できること" do
      @rspec.init_constant
      @rspec.rewrite_nofiable(:emergency, 300)
      WaveForce.notify(@params)
    end
  end

  describe "異常系" do
    it "パスワードなしの場合「Invalid password.」と表示されること" do
      @params[:passwd] = nil
      WaveForce.notify(@params)
      @rspec.error_inspector("Invalid password.")
    end

    it "パスワードが間違っている場合「Invalid password.」と表示されること" do
      @params[:passwd] = @dummy
      WaveForce.notify(@params)
      @rspec.error_inspector("Invalid password.")
    end

    it "アドレスが間違っている場合「Invalid host.」と表示されること" do
      @params[:host] = @dummy
      WaveForce.notify(@params)
      @rspec.error_inspector("Invalid host.")
    end

    it "ログ出力ディレクトリパスが間違っている場合「Invalid log directory path.」と表示されること" do
      @params[:log] = @dummy
      WaveForce.notify(@params)
      @rspec.error_inspector("Invalid log directory path.")
    end

    it "DBファイルパスがまちがっている場合「Invalid dbfile path.」と表示されること" do
      @params[:db] = @dummy
      WaveForce.notify(@params)
      @rspec.error_inspector("Invalid dbfile path.")
    end

    it "設定ファイルのパスが間違っている場合「Config file not found.」と表示されること" do
      @params[:config] = @dummy
      WaveForce.notify(@params)
      @rspec.error_inspector("Config file not found.")
    end

    it "地上波実況データを取得出来ない場合「Crawler timeout error.」と表示されること" do
      def_const = WaveForce::CRAWLE_TIMEOUT
      @rspec.rewrite_constant(:CRAWLE_TIMEOUT, 0.000000001)
      WaveForce.notify(@params)
      @rspec.error_inspector("Crawler timeout error.")
      @rspec.rewrite_constant(:CRAWLE_TIMEOUT, def_const)
    end
  end
end