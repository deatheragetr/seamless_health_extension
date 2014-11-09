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
    limit = 10_000 # Totally unscientific understimation to avoid heroku timeouts
    request_volume = @@count / limit + 1  # Avoid off by 1 errors
    threads = []
    1.times do |i|
      offset = i * limit
      threads << Thread.new do
        puts "Thread Began #{i}"
        begin
          puts "Thread #{i} talking to OPEN DATA"
          response = HealthGradeClient.get_health_grades(offset: offset, limit: limit)
          response.success? ? puts("Thread #{i} successful return from OPENDATA") : puts("Threade #{i} unsuccesfull talking to OPEN DATA")
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
    return if response.empty? || response.blank?
    inserts = []
    column_names = HealthInspection.column_names.reject { |c| c == "id" }
    puts "Thread #{thread_number} compiling data for insertion"
    response.each do |inspection|
      values = column_names.collect do |name|
        inspection[name] = Time.parse(inspection[name]).to_s if ['grade_date', 'record_date', 'inspection_date'].include?(name) && !inspection[name].blank?
        inspection[name].blank? ? 'NULL' : "'#{inspection[name].gsub(/\'/, "\\'")}'"
      end
      inserts.push "(#{values.join(', ')})"
    end
    column_names = column_names.collect {|c| "#{c}"}
    sql = "INSERT INTO health_inspections (#{column_names.join(', ')}) VALUES #{inserts.join(", ")}"
      require 'pry'; binding.pry
    puts "Thread #{thread_number} about to insert into db"
    begin
      @@connection.execute sql
      puts "Thread #{thread_number} successfull insertion of sql into database"
    rescue => e
      puts "Thread Number #{thread_number} this sequel caused an error"
      puts "for this response from OPEN DATA"
      require 'pry'; binding.pry
      puts "The response is #{response}"
      puts e.message
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
