# frozen_string_literal: true

require 'json'
require 'optparse'
require_relative 'emulator'
require_relative 'device_history'

# Android Emulator Workflow
class EmulatorWorkflow
  def self.device_list
    OptionParser.new do |opts|
      opts.on('-p', '--path PATH', 'Path to use') do |path|
        @path = path
      end
    end.parse!
    cmd_output = `#{@path} -list-avds`
    cmd_output.split("\n")
  end

  def self.create_script_filter_items(devices)
    items = devices.map do |name|
      Emulator.new({ name: name }).to_script_filter_item
    end

    begin
      # Sort by history using DeviceHistory class
      DeviceHistory.sort_by_history(items, 'emulator')
    rescue => e
      # Return unsorted items as fallback
      items
    end
  end

  def self.show_emulators
    items = create_script_filter_items(device_list)

    # Convert ScriptFilterItem objects to JSON objects
    item_hashes = items.map { |item| JSON.parse(item.to_json) }

    export_json = {
      'items' => item_hashes
    }.to_json

    puts export_json
  end

  def self.run
    show_emulators
  end
end
