require File.expand_path('../../../config/environment', __FILE__)

class HealthGradeClient
  include HTTParty
  base_uri 'http://data.cityofnewyork.us'
  class << self
    def get_health_grades(offset: nil, limit: nil)
      get('/resource/xx67-kt59.json', { query: { "$offset" => offset, "$limit" => limit } })
    end
  end
end

class HealthGradePopulator
  # Hardcoded from manual testing; 600_000 is significantly higher than the total number of health grade entries
  @@count = 600_000
  @@connection = ActiveRecord::Base.connection
  @@errors = []

  def pull_from_api(&block)
    limit = 30_000 # Totally unscientific understimation to avoid heroku timeouts
    request_volume = @@count / limit + 1  # Avoid off by 1 errors
    threads = []
    request_volume.times do |i|
      offset = i * limit
      threads << Thread.new do
        puts "Thread Began #{i}"
        begin
          puts "Thread #{i} talking to OPEN DATA"
          response = HealthGradeClient.get_health_grades(offset: offset, limit: limit)
          response.success? ? puts("Thread #{i} successful return from OPENDATA") : puts("Thread #{i} unsuccesfull talking to OPEN DATA, response: #{response.body}, #{response.code}")
          response.success? ? block.call(response, i) : @@errors << "#{response}; {offset: #{offset}, limit: #{limit}}"
        rescue => e
          puts "OOPSS!! Error for thread #{i}"
          puts e.message
          puts e.backtrace
          puts
        end
      end
    end
    threads.each(&:join)
  end

  def mass_insert(response, thread_number)
    return if response.blank?
    response.each do |r|
      begin
        ActiveRecord::Base.transaction do
          HealthInspection.create(
            boro: r["boro"],
            building: r["building"],
            phone: r["phone"].gsub(/[\s+|\(|\)|-]/, ""),
            camis: r["camis"],
            dba: r["dba"],
            street: r["street"],
            inspection_type: r["inspection_type"],
            grade_date: r["grade_date"],
            cuisine_description: r["cuisine_description"],
            violation_description: r["violation_description"],
            inspection_date: r["inspection_date"],
            critical_flag: r["critical_flag"],
            violation_code: r["violation_code"],
            record_date: r["record_date"],
            action: r["action"],
            grade: r["grade"]
          )
      end
      rescue => e
        puts e.message
      end
    end
  end

  def run
    pull_from_api do |response, thread_number|
      mass_insert response, thread_number
    end
    if @@errors.empty?
      puts "All Done Without a hitch"
    else
      puts "All done with #{@@errors.size} failed requests\n #{@errors}"
    end
  end
end
HealthGradePopulator.new.run
