class HealthInspection < ActiveRecord::Base

  def self.query_or_fetch_all(params)
    vendor_ids = params.keys
    inspections = where("seamless_vendor_id IN (#{vendor_ids.join(', ')})")

    populated_vendor_ids = inspections.collect(&:seamless_vendor_id).uniq.map(&:to_s)
    missing_vendor_ids = vendor_ids - populated_vendor_ids
    cached_do_not_call_ids = missing_vendor_ids.map { |id| Rails.cache.fetch(id) }.compact
    noncached_missing_vendor_ids = missing_vendor_ids - cached_do_not_call_ids

    threads = []
    noncached_missing_vendor_ids.each do |vendor_id|
      threads << Thread.new do
        phone = SeamlessClient.new(params[vendor_id]).phone
        new_inspections = HealthInspection.where(:phone => phone)

        new_inspections.each { |inspection| inspection.update(:seamless_vendor_id => vendor_id) }
        inspections.push(new_inspections).flatten!
        ActiveRecord::Base.connection.close
      end
    end

    threads.each(&:join)
    filter_and_sort(inspections.to_a)
  end

  def self.index_page_inspections(letter_grade, cuisine_description=nil)
    # inspections = self.where('seamless_vendor_id IS NOT NULL') \
    #   .where("grade = '#{letter_grade}'")

    # if cuisine_description
    #   inspections = inspections.where("cuisine_description = '#{cuisine_description}'")
    # end

    # inspections.order('inspection_date desc') \
    #   .select('id', 'dba', 'seamless_vendor_id') \
    #   .group('dba') \
    #   .limit(30)

    inspections = find_by_sql(
                              "select inspection_date, dba, grade, seamless_vendor_id from health_inspections
                              where grade = '#{letter_grade}' AND seamless_vendor_id IS NOT NULL AND (inspection_date, dba)
                              in (
                                select max(inspection_date) as inspection_date, dba
                                from health_inspections group by dba limit 1000
                              )"
                             )

    inspections.uniq(&:dba).slice(0, 10);
  end

  def address
    "#{building.rstrip} #{street.rstrip}, #{boro}"
  end

  def encoded_address
    address.gsub(' ', '+')
  end

  private
    def self.filter_and_sort(inspections)
      inspections = inspections.select! {|insp| !insp.grade.nil?  } || []
      inspections.sort! { |insp1, insp2| insp2.inspection_date <=> insp1.inspection_date } \
        .uniq! { |insp| insp.seamless_vendor_id }
    end

    def self.restaurant_phone_number(url)
      SeamlessClient.new(url).phone
    end

end
