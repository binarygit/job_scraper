#!/usr/bin/ruby
require 'nokogiri'
require 'open-uri'
require_relative '../modules/page_generator'

class WeWorkRemotely
  include PageGenerator
  attr_reader :base_url, :jobs

  def initialize
    @base_url = 'https://weworkremotely.com'
    @jobs = []
  end

  def scrape_and_generate_page
    scrape
    generate_page
    puts "#{site_name} page has been successfully generated!"
  end

  private

  def scrape
    doc = Nokogiri::HTML(URI.open(scrap_url))
    job_postings = doc.css('.jobs li')
    # The last element is an li containing the link
    # to "back to all jobs"
    # so we discard it
    job_postings.pop
    # Redefine the base url so that
    # href links are correct

    job_postings.each do |job|
      anchor_tag = job.css('a')[1]
      hash = {}
      hash[:href] = base_url + anchor_tag['href']

      title = job.at_css('.title').text
      hash[:title] = title

      type = job.css('.company')[1].text
      region = job.at_css('.region.company').text
      hash[:misc] = type + "/" + region
      @jobs << hash
    end
  end

  def scrap_url
    @base_url + '/remote-ruby-on-rails-jobs'
  end
end
