#!/usr/bin/ruby
require 'nokogiri'
require 'open-uri'
require_relative '../modules/page_generator'

class RubyOnRailsJobs
  include PageGenerator
  attr_reader :base_url, :jobs

  def initialize
    @base_url = 'https://www.ruby-on-rails-jobs.com'
    @jobs = []
  end

  def scrape_and_generate_page
    scrape
    generate_page
    puts "#{site_name} page has been successfully generated!"
  end

  def scrape
    doc = Nokogiri::HTML(URI.open(base_url))
    job_postings = doc.css('div[id^=job]')

    job_postings.each do |job|
      anchor_tag = job.at_css('a')
      hash = {}
      hash[:href] = base_url + anchor_tag['href']

      title = job.at_css('span.h5 + span').text
      hash[:title] = title

      misc = job.at_css('div:last-child').at_css('div:last-child').text
      hash[:misc] = misc.strip.gsub("\n", " ")
      hash[:misc].gsub!(Regexp.new('Icons/solid/[^\s]+'), "")
      hash[:misc].sub!(/.*marker/, '')
      jobs << hash
    end
  end
end
