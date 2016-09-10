require 'fluent/test'
require_relative '../../../source/code/plugins/filter_mysql_logs.rb'

class MysqlerrorlogFilterTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
  ]

  def create_driver(conf = CONFIG, tag = 'oms.api.Mysql.General.logs')
    Fluent::Test::FilterTestDriver.new(Fluent::MysqlLogsFilter, tag).configure(conf)
  end

  def test_log_tokanization_error
    d1 = create_driver(CONFIG, 'oms.api.Mysql.Error.logs')
    d1.run do
      d1.filter('Command'=>"12300 [Note] /usr/sbin/mysqld: Normal shutdown",'Arguments'=>"")
    end
    filtered = d1.filtered_as_array
    assert_equal filtered[0][2]['ResourceName'], 'Mysql'
    assert_equal filtered[0][2]['ResourceType'], 'Error'
  end

  def test_log_tokanization_general
    d1 = create_driver
    d1.run do
      d1.filter('InitTime'=>"160908 15:21:29",'Id'=>"1",'Command'=>"Connect",'Arguments'=>"UNKNOWN_MYSQL_USER@localhost as on")
    end
    filtered = d1.filtered_as_array
    assert_equal filtered[0][2]['ResourceName'], 'Mysql'
    assert_equal filtered[0][2]['ResourceType'], 'General'
  end

  def test_log_tokanization_slow
    d1 = create_driver(CONFIG, 'oms.api.Mysql.SlowQuery.logs')
    d1.run do
      d1.filter('UserHost'=>"debian-sys-maint[debian-sys-maint] @ localhost []",'QueryTime'=>"0.000168",'LocalTime'=>"0.000073",'RowsSent'=>"1",'RowsExamined'=>"5",'Timestamp'=>"1473364535",'Query'=>"SELECT count(*) FROM mysql.user WHERE user='root' and password='';")
    end
    filtered = d1.filtered_as_array
    assert_equal filtered[0][2]['ResourceName'], 'Mysql'
    assert_equal filtered[0][2]['ResourceType'], 'SlowQuery'
  end

  def test_outgoing_logs_format
    d1 = create_driver
    d1.run do
      d1.filter('UserHost'=>" debian-sys-maint[debian-sys-maint] @ localhost []")
    end
    filtered = d1.filtered_as_array
    assert_equal Hash, filtered[0][2].class
  end
end

  