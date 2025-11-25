#!/usr/bin/ruby
require 'nokogiri'
require 'open-uri'

require_relative '../modules/page_generator'

class GoRails
  include PageGenerator
  attr_reader :base_url, :jobs

  def initialize
    @base_url = 'https://jobs.gorails.com'
    @jobs = []
  end

  def scrape_and_generate_page
    scrape
    generate_page
    puts "#{site_name} page has been successfully generated!"
  end

  private

  def scrape
    begin
      # it's taking a long time to open so had to have a timeout here
      doc = Nokogiri::HTML(URI.open(base_url, read_timeout: 5, open_timeout: 5))
    rescue Net::OpenTimeout
      puts "Gorails taking too long to get"
      return
    end
    job_postings = doc.css("body > div ul[role='list'] li")

    job_postings.each do |job|
      anchor_tag = job.at_css('a')
      hash = {}
      hash[:href] = base_url + anchor_tag['href']

      title_element = job.at_css('h3')
      hash[:title] = title_element.text

      misc = job.at_css('div.w-full.truncate').css('div')[3]
      hash[:misc] = misc.text.strip.gsub("\n", ' ')
      @jobs << hash
    end
  end
end
