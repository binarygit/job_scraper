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
    doc = Nokogiri::HTML(URI.open(base_url))
    job_postings = doc.css('body > div li')

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
