require 'rubygems'
require 'test/unit'
require 'yaml'

require File.expand_path('./../../lib/romniture.rb', __FILE__)

class SaintTest < Test::Unit::TestCase

  
  def setup
    config = YAML::load(File.open("test/config.yml"))
    @config = config["omniture"]
    
    @client = ROmniture::Saint.new(
      @config["username"],
      @config["shared_secret"],
      @config["environment"],
      :verify_mode => @config['verify_mode'].to_sym,
      :wait_time => @config["wait_time"]
    )
  end
  
  def test_simple_request
    response = @client.request('Saint.ListFTP')

    assert_instance_of Hash, response, "Returned object is not a hash."
    assert(response.has_key?("ftp_list"), "Returned hash does not contain any report suites.")
  end
  
  def test_start_job
    request_data = {
      campaign_filter_option:"0",
      date_filter_row_end_date: 'Nov 2012',
      date_filter_row_start_date: 'Dec 2012',
      email_address:"igraham@build.com",
      encoding:"UTF-8",
      relation_id:"109",
      report_suite_array:[
        "buildcom"
      ],
      select_all_rows:"1"
    }
    response = @client.start_job(request_data)
    assert_instance_of String, response, "Returned object is not a string"
  end
  
  def test_report_request
    response = @client.get_report "Report.QueueOvertime", {
      "reportDescription" => {
        "reportSuiteID" => "#{@config["report_suite_id"]}",
        "dateFrom" => "2011-01-01",
        "dateTo" => "2011-01-10",
        "metrics" => [{"id" => "pageviews"}]
        }
      }
    
    assert_instance_of Hash, response, "Returned object is not a hash."
    assert(response["report"].has_key?("data"), "Returned hash has no data!")
  end
  
  def test_a_bad_request
    # Bad request, mixing commerce and traffic variables
    assert_raise(ROmniture::Exceptions::OmnitureReportException) do
      response = @client.request("Report.QueueTrended", {
        "reportDescription" => {
#          "reportSuiteID" => @config["report_suite_id"],
          "dateFrom" => "2011-01-01",
          "dateTo" => "2011-01-11",
          "metrics" => [{"id" => "pageviews"}, {"id" => "event11"}],
          "elements" => [{"id" => "siteSection"}]
        }
      })
    end
  end
  
end
