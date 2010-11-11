# -*- coding: utf-8 -*-
require 'mechanize'
require 'kconv'

module WaveForce
  class Crawler
    def run
      agent = Mechanize.new
      agent.read_timeout = CRAWLE_TIMEOUT
      channels = []
      begin
        page = agent.get(CRAWLE_URL)
        html = (page / '//div').inner_html.gsub(/\u00A0|\n|\.|\s|　/, '').split(/<br>/)
        html.each do |e|
          channel_data = e.split("│")
          next unless /^[1-7]{1}/ =~ e && channel_data.length == 5
          channels << {
            :channel => channel_data[1],
            :program => channel_data[4],
            :response => ($1 if /^(\d*)/ =~ channel_data[2])
          }
        end
      rescue
        raise CrawlerException, "Crawler timeout error."
      end
      channels
    end
  end
end