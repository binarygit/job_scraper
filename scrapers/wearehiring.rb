#!/usr/bin/ruby
require 'nokogiri'
require 'open-uri'
require 'debug'
require_relative '../modules/page_generator'

class WeAreHiring
  include PageGenerator
  attr_reader :base_url, :jobs

  def initialize
    @base_url = 'https://www.wearehiring.io'
    @jobs = []
  end

  def scrape_and_generate_page
    scrape
    generate_page
    puts "#{site_name} page has been successfully generated!"
    jobs
  end

  private

  def scrape
    doc = Nokogiri::HTML(URI.open(scrap_url))
    job_postings = doc.css("#pagination-list a")

    job_postings.each do |job|
      anchor_tag = job
      hash = {}
      hash[:href] = base_url + anchor_tag['href']

      title_element = job.at_css('article')
      hash[:title] = title_element.text.strip

      misc = job.css('.content')[1]
      hash[:misc] = misc.text.strip.gsub("\n", " ")
      @jobs << hash
    end
  end

  private

  def scrap_url
    scrap_path = '/?search_for=ruby'
    base_url + scrap_path
  end
end
