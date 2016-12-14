#!/usr/bin/env ruby
require 'pp'
require 'misty/openstack/api'
require 'misty/openstack/api/keystone'
require 'misty/openstack/api/neutron'

Openstack::ServiceFUL_VERBS = [
  :GET, :PUT, :POST, :DELETE, :HEAD, :OPTION, :PATCH,
  :get, :put, :post, :delete, :head, :option, :patch
]

def check_path(path)
  raise SyntaxError, "Path: #{path}: A String expected" unless path.class == String
  raise SyntaxError, "Malformed Path #{path}" unless true
end

def check_request(requests)
  raise SyntaxError, "The requests must be in a Hash: #{requests}" unless requests.class == Hash
end

def check_verb(verb)
  raise SyntaxError, "A Openstack::Serviceful verb must be a Symbol: #{verb}" unless verb.class == Symbol
  unless Openstack::ServiceFUL_VERBS.include?(verb)
    raise SyntaxError, "Unexpected '#{verb}' verb"
  end
end

def check_names(names)
  raise SyntaxError, "The list of Method must be an Array: #{names}" unless names.class == Array
end

def check_name(name)
  raise SyntaxError, "A Method name must be a Symbol: #{name}" unless name.class == Symbol
end

def validate(var)
  var.each do |path, requests|
    check_path(path)
    check_request(requests)
    requests.each do |verb, names|
      check_verb(verb)
      check_names(names)
      names.each do |name|
        check_name(name)
      end
    end
  end
end

Misty::Openstack::SUPPORTED.each do |component|
  validate(Object.const_get("Misty::Openstack::#{component}"))
end
