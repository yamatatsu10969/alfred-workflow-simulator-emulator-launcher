# frozen_string_literal: true

require 'json'
require 'optparse'
require_relative 'emulator'
require_relative 'device_history'

# Android Emulator Workflow
class EmulatorWorkflow
  def self.device_list
    # Create debug log
    log_file = '/tmp/alfred_emulator_workflow.log'
    File.write(log_file, "==== Emulator Workflow Started: #{Time.now} ====\n")
    File.write(log_file, "Current directory: #{Dir.pwd}\n", mode: 'a')

    # Parse emulator path
    OptionParser.new do |opts|
      opts.on('-p', '--path PATH', 'Path to use') do |path|
        @path = path
        File.write(log_file, "Using emulator path: #{@path}\n", mode: 'a')
      end
    end.parse!

    if @path.nil? || @path.empty?
      File.write(log_file, "WARNING: Emulator path is empty\n", mode: 'a')
    end

    # Get emulator list
    begin
      cmd_output = `#{@path} -list-avds`
      devices = cmd_output.split("\n")
      File.write(log_file, "Found #{devices.size} emulators\n", mode: 'a')
      devices.each do |device|
        File.write(log_file, "  - #{device}\n", mode: 'a')
      end
      devices
    rescue => e
      File.write(log_file, "ERROR listing emulators: #{e.message}\n", mode: 'a')
      []
    end
  end

  def self.create_script_filter_items(devices)
    # Create debug log
    log_file = '/tmp/alfred_emulator_workflow.log'

    begin
      # Create emulator objects
      File.write(log_file, "Creating ScriptFilterItems for #{devices.size} emulators\n", mode: 'a')
      items = devices.map do |name|
        emulator_item = Emulator.new({ name: name }).to_script_filter_item
        File.write(log_file, "Created item for #{name}: #{emulator_item.inspect}\n", mode: 'a')
        emulator_item
      end

      # Sort by history
      File.write(log_file, "Sorting by history...\n", mode: 'a')
      sorted_items = DeviceHistory.sort_by_history(items, 'emulator')
      File.write(log_file, "Sorting complete. Emulators count: #{sorted_items.size}\n", mode: 'a')
      sorted_items
    rescue => e
      File.write(log_file, "ERROR creating script filter items: #{e.message}\n", mode: 'a')
      File.write(log_file, "Backtrace: #{e.backtrace.join("\n")}\n", mode: 'a')
      []
    end
  end

  def self.show_emulators
    begin
      # Create debug log
      log_file = '/tmp/alfred_emulator_workflow.log'
      File.write(log_file, "Getting device list...\n", mode: 'a')

      items = create_script_filter_items(device_list)
      File.write(log_file, "Got #{items.size} items, converting to hashes...\n", mode: 'a')

      # Convert ScriptFilterItem objects to hashes
      item_hashes = items.map(&:to_h)
      File.write(log_file, "Created #{item_hashes.size} item hashes\n", mode: 'a')

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

  def self.run
    show_emulators
  end
end
