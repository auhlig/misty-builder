#!/usr/bin/env ruby

require 'misty_builder/services'

def init(params)
  @base = 'fetched/'
  @copy = false
  selected_modules = []

  until params.empty?
    case params[0]
    when '-m', '--module='
      selected_modules << params[1]
      params.shift(2)
    when '-d', '--debug'
      $DEBUG = true
      params.shift
    when '-c', '--copy'
      @copy = true
      params.shift
    when '-h', '--help'
      usage & exit
    end
  end
  @services = unless selected_modules.empty?
    Tools::Services::SERVICES.select { |k,v| selected_modules.include?(k) }
  else
    Tools::Services::SERVICES.dup
  end
end

def fetch_source(url)
  raise Error, "No URL source" if url.empty?
  return Nokogiri::HTML(open(url))
end

def usage
  puts "#{__FILE__}\n  Usage: [ -m ] <module name>"
end

def process(service_name, api_version)
  target = @base + "#{service_name}/#{api_version}/#{api_version}.rb"
  puts "------ Diff -----"
  system("diff #{target} ../misty/lib/misty/openstack/#{service_name}/#{api_version}/#{api_version}.rb")
  puts "-----------------"
  if @copy
    cmd  = "cp #{target} ../misty/lib/misty/openstack/#{service_name}/#{api_version}/#{api_version}.rb"
    puts cmd
    system(cmd)
  end
end

init(ARGV)

@services.each do |service_name, apis|
  apis.each do |api_version, _url|
    puts "#{service_name}/#{api_version}"
    process(service_name, api_version)
    puts
  end
end
