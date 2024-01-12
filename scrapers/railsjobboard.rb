#!/usr/bin/ruby
require 'nokogiri'
require 'open-uri'
require_relative '../modules/page_generator'

class RailsJobBoard
  include PageGenerator
  attr_reader :base_url, :jobs

  def initialize
    @base_url = 'https://jobs.rubyonrails.org'
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
    job_postings = doc.css('a[id^=job]')

    job_postings.each do |job|
      hash = {}
      hash[:href] = base_url + job[:href]

      title_element = job.at_css('h2')
      hash[:title] = title_element.text.gsub(/[[:space:]]+/, " ").strip

      misc = job.css('li')
      hash[:misc] = misc.text.gsub(/[[:space:]]+/, " ").strip
      @jobs << hash
    end
  end
end
