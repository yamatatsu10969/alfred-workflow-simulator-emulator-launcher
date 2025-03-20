# frozen_string_literal: true

require_relative 'device_history'

def main
  # Create debug log
  log_file = '/tmp/alfred_simulator_launcher.log'
  File.write(log_file, "==== Simulator Launcher Started: #{Time.now} ====\n")

  # Get the device ID from the command line argument
  device_id = ARGV[0]
  File.write(log_file, "Device ID: #{device_id.inspect}\n", mode: 'a')
  File.write(log_file, "All arguments: #{ARGV.inspect}\n", mode: 'a')
  File.write(log_file, "Current directory: #{Dir.pwd}\n", mode: 'a')

  begin
    # Update history
    result = DeviceHistory.update_device(device_id, 'simulator')
    File.write(log_file, "History update result: #{result}\n", mode: 'a')

    # Launch the simulator
    File.write(log_file, "Launching simulator: xcrun simctl boot #{device_id}\n", mode: 'a')
    system("xcrun simctl boot #{device_id}")
    File.write(log_file, "Opening Simulator.app\n", mode: 'a')
    system("open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/")

    # Return the device ID for Alfred
    puts device_id
    File.write(log_file, "Simulator launch completed successfully\n", mode: 'a')
  rescue => e
    # Log any errors
    File.write(log_file, "ERROR: #{e.class}: #{e.message}\n", mode: 'a')
    File.write(log_file, "Backtrace: #{e.backtrace.join("\n")}\n", mode: 'a')
    # Still try to return the device ID for Alfred
    puts device_id
  end
end

main
