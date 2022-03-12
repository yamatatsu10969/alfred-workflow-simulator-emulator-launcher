# frozen_string_literal: true

require 'json'
require 'optparse'
require_relative 'emulator'

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
    devices.map do |name|
      Emulator.new({ name: name }).to_script_filter_item
    end
  end

  def self.show_emulators
    export_json = {
      'items' => create_script_filter_items(device_list)
    }.to_json
    puts export_json
  end

  def self.run
    show_emulators
  end
end
