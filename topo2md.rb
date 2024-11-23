# frozen_string_literal: true

require 'json'
require 'erb'
require 'optparse'
require 'netomox'

# functions
def render(template_file, locals = {})
  template = File.read(template_file)
  ERB.new(template, trim_mode: '-').result_with_hash(locals)
end

def parse_file_path(path)
  match = path.match(%r{/topologies/([^/]+)/([^/]+)/})
  if match
    [match[1], match[2]] # [<network>, <snapshot>]
  else
    ['', '']
  end
end

def render_recursive(key, value, depth = 0)
  indent = '  ' * depth

  # skip '_diff_state_' key
  return '' if key == '_diff_state_'

  case value
  when Hash
    result = "#{indent}- **#{key}**:\n" if key
    value.each do |k, v|
      result = (result || '') + render_recursive(k, v, depth + 1)
    end
    result
  when Array
    result = "#{indent}- **#{key}**:\n" if key
    if value.empty?
      result = (result || '') + "#{indent}  - (empty)\n"
    else
      value.each do |v|
        result = (result || '') + render_recursive(nil, v, depth + 1)
      end
    end
    result
  else
    if key
      "#{indent}- **#{key}**: #{value}\n"
    else
      "#{indent}- #{value}\n"
    end
  end
end

def main
  # parse options
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: ruby #{$PROGRAM_NAME} [options]"

    opts.on('-t TOPOLOGY_JSON', '--topology TOPOLOGY_JSON', 'Input JSON file (topology data)') do |topo_file|
      options[:topo_file] = topo_file
    end
  end.parse!

  # check required options
  if options[:topo_file].nil?
    puts 'Error: JSON file must be specified with -t option.'
    exit 1
  end

  # read topology file and convert to Netomox::Topology object
  begin
    topo_data = JSON.parse(File.read(options[:topo_file]))
  rescue Errno::ENOENT
    puts "Error: File not found - #{options[:topo_file]}"
    exit 1
  rescue JSON::ParserError
    puts "Error: Failed to parse JSON in #{options[:topo_file]}"
    exit 1
  end
  topology = Netomox::Topology::Networks.new(topo_data)

  # main template
  template = <<~ERB
    <%= render('templates/networks.erb', options:, topology: ) %>
  ERB

  # apply template
  renderer = ERB.new(template, trim_mode: '-')
  markdown_output = renderer.result(binding)

  # output
  puts markdown_output
end

main
