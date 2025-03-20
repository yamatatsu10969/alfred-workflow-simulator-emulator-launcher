# frozen_string_literal: true

require 'json'
require_relative 'simulator'
require_relative 'device_history'

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
    iphone_simulators = []
    ipad_simulators = []

    ios_simulator_keys.each do |key|
      devices[key].reverse_each do |device|
        next unless device[:isAvailable] == true

        ios_version = key.to_s.split('iOS')[1]
        device[:name] = device[:name] + " (iOS #{ios_version})"

        simulator_item = Simulator.new(device).to_script_filter_item

        if device[:name].include?('iPad')
          ipad_simulators << simulator_item
        else
          iphone_simulators << simulator_item
        end
      end
    end

    all_simulators = iphone_simulators + ipad_simulators

    begin
      # Sort by history using DeviceHistory class
      DeviceHistory.sort_by_history(all_simulators, 'simulator')
    rescue => e
      # Return unsorted simulators as fallback
      all_simulators
    end
  end

  def self.show_simulators
    begin
      items = create_script_filter_items(device_list)

      # Convert ScriptFilterItem objects to hashes
      item_hashes = items.map(&:to_h)

      export_json = {
        'items' => item_hashes
      }.to_json

      puts export_json
    rescue => e
      puts '{"items": []}'
    end
  end
end
