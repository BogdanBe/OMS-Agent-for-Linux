module Fluent
  class MysqlLogsFilter < Filter
    Fluent::Plugin.register_filter('filter_mysql_logs', self)
    
    def initialize
      super
      require 'socket'
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
      record["ResourceName"] = 'Mysql'
      record["Computer"] = IPSocket.getaddress(Socket.gethostname)
      record["ResourceId"] = Socket.gethostname
      record["ResourceType"] = tag.split('.')[3]

      record
    end
  end
end
