# frozen_string_literal: true

require 'json'
require_relative 'simulator'

class SimulatorWorkflow
  def self.show_simulators
    cmd_output = `xcrun simctl list -j devices`

    json = JSON.parse(cmd_output, { symbolize_names: true })
    devices = json[:devices]

    ios_simulator_keys = devices.keys.select { |key| key.to_s.include?('iOS') }

    ios_simulators = []
    ios_simulator_keys.reverse_each do |key|
      devices[key].each do |device|
        next unless device[:isAvailable] == true

        ios_version = key.to_s.split('iOS')[1]
        device[:name] = device[:name] + " (iOS #{ios_version})"
        ios_simulators << Simulator.new(device)
      end
    end

    export_json = {
      'items' => ios_simulators
    }.to_json

    puts export_json
  end
end

SimulatorWorkflow.show_simulators
