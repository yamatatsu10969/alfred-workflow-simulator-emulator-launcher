# frozen_string_literal: true

require_relative 'device_history'

# Simple script to run a simulator and update history
# Usage: ruby simulator_run.rb <udid>

# Create log file
log_file = '/tmp/alfred_simulator_run.log'
File.write(log_file, "==== Simulator Run Started: #{Time.now} ====\n")

# Get device ID from arguments
if ARGV.empty?
  puts "Error: Please provide a simulator UDID"
  File.write(log_file, "Error: No UDID provided\n", mode: 'a')
  exit 1
end

device_id = ARGV[0]
File.write(log_file, "Device ID: #{device_id}\n", mode: 'a')

# Update history
begin
  File.write(log_file, "Updating history...\n", mode: 'a')
  result = DeviceHistory.update_device(device_id, 'simulator')
  File.write(log_file, "History update result: #{result}\n", mode: 'a')
rescue => e
  File.write(log_file, "Error updating history: #{e.message}\n", mode: 'a')
  File.write(log_file, "#{e.backtrace.join("\n")}\n", mode: 'a')
end

# Launch the simulator
begin
  File.write(log_file, "Booting simulator...\n", mode: 'a')
  boot_cmd = "xcrun simctl boot #{device_id}"
  File.write(log_file, "Running command: #{boot_cmd}\n", mode: 'a')
  boot_result = system(boot_cmd)
  File.write(log_file, "Boot result: #{boot_result}\n", mode: 'a')

  File.write(log_file, "Opening Simulator.app...\n", mode: 'a')
  open_cmd = "open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/"
  File.write(log_file, "Running command: #{open_cmd}\n", mode: 'a')
  open_result = system(open_cmd)
  File.write(log_file, "Open result: #{open_result}\n", mode: 'a')

  puts "Simulator launched successfully: #{device_id}"
  File.write(log_file, "Simulator launched successfully\n", mode: 'a')
rescue => e
  puts "Error launching simulator: #{e.message}"
  File.write(log_file, "Error launching simulator: #{e.message}\n", mode: 'a')
  File.write(log_file, "#{e.backtrace.join("\n")}\n", mode: 'a')
end
