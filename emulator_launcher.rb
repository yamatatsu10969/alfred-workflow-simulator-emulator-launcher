# frozen_string_literal: true

require_relative 'device_history'
require 'optparse'

def main
  # Get the device ID from the command line argument
  device_id = ARGV[0]

  # Add debug log
  log_file = '/tmp/alfred_emulator_launcher.log'
  File.write(log_file, "Launching emulator with device ID: #{device_id}\n")

  # Parse the emulator path
  emulator_path = nil
  OptionParser.new do |opts|
    opts.on('-p', '--path PATH', 'Path to use') do |path|
      emulator_path = path
    end
  end.parse!

  File.write(log_file, "Using emulator path: #{emulator_path}\n", mode: 'a')

  # Update history
  DeviceHistory.update_device(device_id, 'emulator')

  # Verify history was updated
  history = DeviceHistory.load_history
  File.write(log_file, "Updated history: #{history.inspect}\n", mode: 'a')

  # Launch the emulator
  system("nohup #{emulator_path} -avd #{device_id} > /dev/null 2>&1 &")

  # Return the device ID for Alfred
  puts device_id
end

main
