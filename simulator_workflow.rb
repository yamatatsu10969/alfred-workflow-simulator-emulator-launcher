# frozen_string_literal: true

require 'json'
require_relative 'simulator'

# iOS Simulator Workflow
class SimulatorWorkflow
  def self.device_list
    cmd_output = `xcrun simctl list -j devices`
    json = JSON.parse(cmd_output, { symbolize_names: true })
    json[:devices]
  end

  def self.create_script_filter_items(devices)
    ios_simulator_keys = devices.keys.select { |key| key.to_s.include?('iOS') }
    ios_simulators = []
    ios_simulator_keys.reverse_each do |key|
      devices[key].each do |device|
        next unless device[:isAvailable] == true

        ios_version = key.to_s.split('iOS')[1]
        device[:name] = device[:name] + " (iOS #{ios_version})"
        ios_simulators << Simulator.new(device).to_script_filter_item
      end
    end
    ios_simulators
  end

  def self.show_simulators
    export_json = {
      'items' => create_script_filter_items(device_list)
    }.to_json
    puts export_json
  end
end
