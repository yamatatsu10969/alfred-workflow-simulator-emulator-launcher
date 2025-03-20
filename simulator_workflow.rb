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
    # Create debug log
    log_file = '/tmp/alfred_simulator_workflow.log'
    File.write(log_file, "==== Simulator Workflow Started: #{Time.now} ====\n")
    File.write(log_file, "Current directory: #{Dir.pwd}\n", mode: 'a')

    ios_simulator_keys = devices.keys.select { |key| key.to_s.include?('iOS') }
    File.write(log_file, "Found iOS keys: #{ios_simulator_keys.inspect}\n", mode: 'a')

    ios_simulators = []
    iphone_simulators = []
    ipad_simulators = []

    ios_simulator_keys.each do |key|
      devices[key].reverse_each do |device|
        next unless device[:isAvailable] == true

        ios_version = key.to_s.split('iOS')[1]
        device[:name] = device[:name] + " (iOS #{ios_version})"

        simulator_item = Simulator.new(device).to_script_filter_item
        File.write(log_file, "Created item: #{simulator_item.inspect}, udid: #{device[:udid]}\n", mode: 'a')

        if device[:name].include?('iPad')
          ipad_simulators << simulator_item
        else
          iphone_simulators << simulator_item
        end
      end
    end

    File.write(log_file, "Total iPhone simulators: #{iphone_simulators.size}\n", mode: 'a')
    File.write(log_file, "Total iPad simulators: #{ipad_simulators.size}\n", mode: 'a')

    all_simulators = iphone_simulators + ipad_simulators

    # Log unsorted simulators
    File.write(log_file, "==== UNSORTED SIMULATORS ====\n", mode: 'a')
    all_simulators.each_with_index do |sim, index|
      File.write(log_file, "[#{index}] #{sim.title} (#{sim.arg})\n", mode: 'a')
    end

    begin
      # Load history for debugging
      history = DeviceHistory.load_history
      File.write(log_file, "==== HISTORY DATA ====\n", mode: 'a')
      history.each do |key, value|
        File.write(log_file, "#{key}: #{value.inspect}\n", mode: 'a')
      end

      # Sort by history using DeviceHistory class
      File.write(log_file, "Sorting by history...\n", mode: 'a')
      sorted_simulators = DeviceHistory.sort_by_history(all_simulators, 'simulator')
      File.write(log_file, "Sorting complete. Simulators count: #{sorted_simulators.size}\n", mode: 'a')

      # Log sorted simulators
      File.write(log_file, "==== SORTED SIMULATORS ====\n", mode: 'a')
      sorted_simulators.each_with_index do |sim, index|
        File.write(log_file, "[#{index}] #{sim.title} (#{sim.arg})\n", mode: 'a')
      end

      sorted_simulators
    rescue => e
      # Log error and return unsorted simulators as fallback
      File.write(log_file, "ERROR during sorting: #{e.class}: #{e.message}\n", mode: 'a')
      File.write(log_file, "Backtrace: #{e.backtrace.join("\n")}\n", mode: 'a')
      File.write(log_file, "Returning unsorted simulators\n", mode: 'a')
      all_simulators
    end
  end

  def self.show_simulators
    begin
      # Create debug log
      log_file = '/tmp/alfred_simulator_workflow.log'
      File.write(log_file, "Getting device list...\n", mode: 'a')

      items = create_script_filter_items(device_list)
      File.write(log_file, "Converting to hashes...\n", mode: 'a')

      # Convert ScriptFilterItem objects to hashes
      item_hashes = items.map(&:to_h)
      File.write(log_file, "Created #{item_hashes.size} item hashes\n", mode: 'a')

      # Log JSON item order
      File.write(log_file, "==== FINAL JSON ITEMS ORDER ====\n", mode: 'a')
      item_hashes.each_with_index do |item, index|
        File.write(log_file, "[#{index}] #{item[:title]} (#{item[:arg]})\n", mode: 'a')
      end

      export_json = {
        'items' => item_hashes
      }.to_json

      File.write(log_file, "Exporting JSON with #{item_hashes.size} items\n", mode: 'a')
      puts export_json
      File.write(log_file, "Workflow completed successfully\n", mode: 'a')
    rescue => e
      # Log error and return empty list as fallback
      File.write(log_file, "ERROR: #{e.class}: #{e.message}\n", mode: 'a')
      File.write(log_file, "Backtrace: #{e.backtrace.join("\n")}\n", mode: 'a')
      puts '{"items": []}'
    end
  end
end
