module Fluent
  class MysqlLogsFilter < Filter
    Fluent::Plugin.register_filter('filter_mysql_logs', self)
    
    def initialize
      super
      require 'socket'
      require 'date'
      require_relative 'oms_common'
    end

    def configure(conf)
      super
    end

    def start
      super
    end

    def shutdown
      super
    end

    def filter(tag, time, record)
      record["ResourceName"] = 'MySQL'
      record["Computer"] = OMS::Common.get_hostname
      record["ResourceId"] = Socket.gethostname
      resource_type = tag.split('.')[3]
      record["ResourceType"] = resource_type

      if resource_type == "SlowQuery"
        # Convert type of decimal fields
        record["QueryTime"] = record["QueryTime"].to_f
        record["LockTime"] = record["LockTime"].to_f
        record["RowsSent"] = record["RowsSent"].to_i
        record["RowsExamined"] = record["RowsExamined"].to_i
        # Convert timestamp to OMS style
        timestamp = record["Timestamp"].to_i
        record["Timestamp"] = OMS::Common.format_time(timestamp)
      elsif resource_type == "General"
        # Convert InitTime to OMS style
        init_time = record["InitTime"]
        if init_time != nil
          record["InitTime"] = DateTime.parse(init_time).strftime("%FT%H:%M:%S.%3NZ")
        end
      elsif resource_type == "Error"
        # Convert timestamp to OMS style
        timestamp = record["Timestamp"]
        record["Timestamp"] = DateTime.parse(timestamp).strftime("%FT%H:%M:%S.%3NZ")
      end

      record
    end
  end
end
