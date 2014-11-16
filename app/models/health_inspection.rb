class HealthInspection < ActiveRecord::Base
  def self.query_or_fetch_all(params)
    # params { :vendor_id => "/path/on/seamless"
    vendor_ids = params.keys
    inspections = where("seamless_vendor_id IN (#{vendor_ids.join(', ')})")
    populated_vendor_ids = inspections.collect(&:seamless_vendor_id)
    missing_vendor_ids = vendor_ids - populated_vendor_ids

    threads = []
    missing_vendor_ids.each do |vendor_id|
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
end
