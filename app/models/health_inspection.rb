class HealthInspection < ActiveRecord::Base
  geocoded_by :address
  
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
    inspections
  end

  def address
    "#{building.rstrip} #{street.rstrip}, #{boro}"
  end
end
