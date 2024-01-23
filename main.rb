require 'debug'
require 'erb'
require 'json'

Dir.new('./scrapers').children.each do |file|
  require_relative "./scrapers/#{file}"
end

class SiteBuilder
  attr_reader :site_names, :pages

  def initialize
    @site_names = %w[GoRails WeWorkRemotely RubyOnRemote
                     RubyOnRailsJobs RailsHotwireJobs WeAreHiring RailsJobBoard]
    @pages = {}
    @mutex = Mutex.new
  end

  def create_site
    threads = []
    site_names.each do |name|
      threads << Thread.new do
        page = Object.const_get(name).new
        page.scrape_and_generate_page
        @mutex.synchronize { pages[name.downcase.to_s] = page }
      end
    end

    threads.each(&:join)
    create_json_file
  end

  private

  def create_json_file
    File.open('/home/kali/Documents/jobs/jobs.json', 'w') do |f|
      all_jobs = []

      pages.each_value do |val|
        all_jobs << val.jobs
      end

      # Create a timestamp
      all_jobs << Time.now.utc
      f.write(JSON.dump(all_jobs))
    end
  end
end

sb = SiteBuilder.new
sb.create_site
