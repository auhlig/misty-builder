#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
require 'pp'

require 'misty_builder/services'

def init(params)
  @base = 'fetched/'
  file, url = nil, nil
  constant = nil
  selected_components = []

  until params.empty?
    case params[0]
    when '-t', '--target='
      @base=params[1]
      params.shift(2)
    when '-m', '--module='
      selected_components << params[1]
      params.shift(2)
    when '-d', '--debug'
      $DEBUG = true
      params.shift
    when '-h', '--help'
      usage & exit
    end
  end
  @mservices = unless selected_components.empty?
    Tools::Services::SERVICES.select { |k,v| selected_components.include?(k) }
  else
    Tools::Services::SERVICES.dup
  end
end

def fetch_source(url)
  raise Error, "No URL source" if url.empty?
  return Nokogiri::HTML(open(url))
end

def generate(api, target, name, api_version)
  File.open(target, "w") do |f|
    f << "module Misty::Openstack::#{name}\n"
    f << "  def #{api_version}\n"
    PP.pp(api, f)
    f << "  end\n"
    f << "end\n"
  end
end

def parse(page)
  api = {}
  group = page.css("div.detail-control").select
  group.each do |e|
    verb = e.css("div.operation").css("span.label")[0].text.to_sym
    cont = e.css("div.endpoint-container").css("div.row").select
    details = []
    cont.each do |e|
      details << e.text
    end

    name = e["id"].gsub(/-/, '_').to_sym
    request = { verb => [ name ]}
    path = details[0]

    if api.has_key?(path)
      if api[path].has_key?(verb)
        api[path][verb] << name
      else
        api[path].merge!(request)
      end
    else
      api[path] = request
    end
  end
  api
end

def usage
  puts "#{__FILE__}\n  Usage: [ -c <module name> | -t <target file> ]"
end

def process(service_name, api_version, url)
  return if url.empty?
  constant = (service_name[0].upcase + service_name[1..-1]).to_sym
  puts "#{constant}/#{api_version}"
  api = parse(fetch_source(url))
  target = @base + "#{service_name}/#{api_version}/#{api_version}.rb"
  Dir.mkdir(@base + "#{service_name}") unless Dir.exist?(@base + "#{service_name}")
  Dir.mkdir(@base + "#{service_name}/#{api_version}") unless Dir.exist?(@base + "#{service_name}/#{api_version}")
  generate(api, target, constant, api_version)
end

init(ARGV)
@mservices.each do |service_name, apis|
  apis.each do |api, url|
    process(service_name, api, url)
  end
end
