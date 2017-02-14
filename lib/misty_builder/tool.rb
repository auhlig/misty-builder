#!/usr/bin/env ruby
require 'misty_builder'
require 'misty_builder/parser'
require 'pp'
require 'pry-byebug'

include MistyBuilder::Parser

def init(params)
  @command = nil
  @base = 'fetched/'
  file, url = nil, nil
  constant = nil
  selected_components = []

  # Commands
  case params[0]
  when "fetch"
    @command = :fetch
    params.shift
  when "diff"
    @command = :diff
    params.shift
  else
    usage & exit
  end

  # Options
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
    when '-c', '--copy'
      @copy = true
      params.shift
    when '-h', '--help'
      usage & exit
    end
  end
  @services = unless selected_components.empty?
    MistyBuilder::SERVICES.select { |service| selected_components.include?(service.name) }
  else
    MistyBuilder::SERVICES.dup
  end
end

def usage
  puts "#{__FILE__}\n  Usage: fetch | diff  [ -c <module name> | -t <target file> ]"
end

def fetch(service)
  return if service.url.empty?
  constant = (service.name[0].upcase + service.name[1..-1]).to_sym
  puts "#{constant}/#{service.version}"
  html_source = fetch_source(service.url)
  api = self.send(service.parser, html_source)
  target = @base + "#{service.name}/#{service.version}/#{service.version}.rb"
  Dir.mkdir(@base + "#{service.name}") unless Dir.exist?(@base + "#{service.name}")
  Dir.mkdir(@base + "#{service.name}/#{service.version}") unless Dir.exist?(@base + "#{service.name}/#{service.version}")
  generate(api, target, constant, service.version)
end

def diff(service)
  target = @base + "#{service.name}/#{service.version}/#{service.version}.rb"
  res = %x{diff #{target} ../misty/lib/misty/openstack/#{service.name}/#{service.version}/#{service.version}.rb}
  if $?.exitstatus && !res.empty?
    puts "----------------- #{service.name} / #{service.version} -----------------"
    puts res
    puts "---------------------------------------------------------------------------"
    puts
  end
end

init(ARGV)
@services.each do |service|
  self.send(@command, service)
end
