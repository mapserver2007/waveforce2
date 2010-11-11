# -*- coding: utf-8 -*-
require 'pstore'

module WaveForce
  class StoreException < RuntimeError; end
  class Store
    def initialize(path)
      # ディレクトリパスをチェックして存在しなければ例外
      unless Utils.directory? File.dirname(path)
        raise StoreException, "Invalid dbfile path."
      end
      @db = PStore.new(path)
    end

    def save(key, value)
      @db.transaction do
        @db[key] = value
      end
    end

    def load(key)
      @db.transaction(true) do
        @db[key]
      end
    end
  end
end