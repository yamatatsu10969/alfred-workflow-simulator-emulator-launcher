# frozen_string_literal: true

require_relative 'device_history'
require 'optparse'

# Simple script to run an emulator and update history
# Usage: ruby emulator_run.rb <device_name> -p <emulator_path>

# Create log file
log_file = '/tmp/alfred_emulator_run.log'
File.write(log_file, "==== Emulator Run Started: #{Time.now} ====\n")
File.write(log_file, "Arguments: #{ARGV.inspect}\n", mode: 'a')

# Get device name from arguments
if ARGV.empty?
  puts "Error: Please provide an emulator name"
  File.write(log_file, "Error: No device name provided\n", mode: 'a')
  exit 1
end

device_name = ARGV[0]
File.write(log_file, "Device name: #{device_name}\n", mode: 'a')

# Parse emulator path
emulator_path = nil
begin
  OptionParser.new do |opts|
    opts.on('-p', '--path PATH', 'Path to use') do |path|
      emulator_path = path
    end
  end.parse!(ARGV)

  File.write(log_file, "Emulator path: #{emulator_path}\n", mode: 'a')

  if emulator_path.nil? || emulator_path.empty?
    puts "Error: Please provide an emulator path"
    File.write(log_file, "Error: No emulator path provided\n", mode: 'a')
    exit 1
  end
rescue => e
  File.write(log_file, "Error parsing options: #{e.message}\n", mode: 'a')
  puts "Error parsing options: #{e.message}"
  exit 1
end

# Update history
begin
  File.write(log_file, "Updating history...\n", mode: 'a')
  result = DeviceHistory.update_device(device_name, 'emulator')
  File.write(log_file, "History update result: #{result}\n", mode: 'a')
rescue => e
  File.write(log_file, "Error updating history: #{e.message}\n", mode: 'a')
  File.write(log_file, "#{e.backtrace.join("\n")}\n", mode: 'a')
end

# Launch the emulator
begin
  File.write(log_file, "Launching emulator...\n", mode: 'a')
  launch_cmd = "nohup #{emulator_path} -avd #{device_name} > /dev/null 2>&1 &"
  File.write(log_file, "Running command: #{launch_cmd}\n", mode: 'a')
  launch_result = system(launch_cmd)
  File.write(log_file, "Launch result: #{launch_result}\n", mode: 'a')

  puts "Emulator launched successfully: #{device_name}"
  File.write(log_file, "Emulator launched successfully\n", mode: 'a')
rescue => e
  puts "Error launching emulator: #{e.message}"
  File.write(log_file, "Error launching emulator: #{e.message}\n", mode: 'a')
  File.write(log_file, "#{e.backtrace.join("\n")}\n", mode: 'a')
end
