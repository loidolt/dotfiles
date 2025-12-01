# User Configuration
#
# This file contains user-specific values that should be customized per-user.
# Copy this file and modify it for your own setup.
#
# To use different values without modifying this file, you can override
# via command line: --override-input or by creating a local override file.

{
  # Primary username (used for macOS and WSL)
  username = "chrisloidolt";

  # Username for VMs (NixOS desktop/headless configurations)
  # Often different from primary username for VM isolation
  vmUsername = "loidolt";

  # Git configuration
  git = {
    name = "Chris Loidolt";
    email = "477898+loidolt@users.noreply.github.com";
  };

  # Timezone (used across all systems)
  # See: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  timezone = "America/Denver";

  # Locale settings
  locale = "en_US.UTF-8";
}
