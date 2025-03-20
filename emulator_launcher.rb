# frozen_string_literal: true

require_relative 'device_history'

def main
  # Get the emulator name from the command line argument
  emulator_name = ARGV[0]

  # Use environment variable or fall back to a path relative to HOME
  emulator_path = ENV['emulator_path'] || "#{ENV['HOME']}/Library/Android/sdk/emulator/emulator"

  begin
    # Update history
    DeviceHistory.update_device(emulator_name, 'emulator')

    # Launch the emulator using system command with background execution
    system("nohup #{emulator_path} -avd \"#{emulator_name}\" > /dev/null 2>&1 &")

    # Return the emulator name for Alfred
    puts emulator_name
  rescue => e
    # Still try to return the emulator name for Alfred
    puts emulator_name
  end
end

main
