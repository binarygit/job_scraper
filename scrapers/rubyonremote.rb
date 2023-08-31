#!/usr/bin/ruby
require 'nokogiri'
require 'open-uri'
require 'debug'
require_relative '../modules/page_generator'

class RubyOnRemote
  include PageGenerator
  attr_reader :base_url, :jobs

  def initialize
    @base_url = 'https://rubyonremote.com'
    @jobs = []
  end

  def scrape_and_generate_page
    scrape
    generate_page
    puts "#{site_name} page has been successfully generated!"
  end

  private

  def scrape
    (1..5).each do |page_num|
      doc = Nokogiri::HTML(URI.open(scrap_url(page_num)))
      job_postings = doc.css("a[href^='/jobs']")

      job_postings.each do |job|
        anchor_tag = job
        hash = {}
        hash[:href] = base_url + anchor_tag['href']

        title_element = job.at_css('h2')
        company_name =  job.at_css('h2 + p').text
        hash[:title] = title_element.text + ' | ' + company_name

        misc = job.css('div')[5]
        hash[:misc] = misc.text.strip.gsub("\n", " ")
        @jobs << hash
      end
    end
  end

  private

  def scrap_url(page_num)
    scrap_path = '/remote-jobs/'
    url = base_url + scrap_path
    return url if page_num == 1
    url + "?page=#{page_num}"
  end
end
