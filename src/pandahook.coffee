#===============================================================================
# PandaHook - The Ultimate Githook Script Management Tool.
#===============================================================================

#====================
# Modules
#====================
{exec} = require "shelljs"                # Access to commandline

builder = require "./build/build"         # Githook Script Generator


#===============================
# PandaHook Definition
#===============================
module.exports =
  # For now, we rely on small, easily maintainable Bash scripts for shell calls.
  # This is to deal with the ugliness of issuing shell commands inside an SSH command.


  # This method automates the process of writing githook scripts.
  # It's body is maintained in the "build" directory.
  build: (config, options) ->
    builder.main config, options

  # This method clones a bare repo on the hook-server.
  create: (config, options) ->
    exec "bash #{__dirname}/scripts/create #{config.hook_server.address} #{options.repo_name}"

  # This method deletes the specified repo from the hook-server.
  destroy: (config, options) ->
    exec "bash #{__dirname}/scripts/destroy #{config.hook_server.address} #{options.repo_name}"

  # This method places a githook script into a remote repo.
  push: (config, options) ->
    exec "bash #{__dirname}/scripts/push #{config.hook_server.address} #{options.repo_name} #{options.hook_name}",
      async:false,
      (code, output) ->
        if code == 1
          # The "push" Bash script cannot add a githook if the repo does not exist.
          # Create it now, then try to push again.
          exec "bash #{__dirname}/scripts/create #{config.hook_server.address} #{options.repo_name}"
          exec "bash #{__dirname}/scripts/push #{config.hook_server.address} #{options.repo_name} #{options.hook_name}"

  # This method deletes a githook script from a remote repo.
  rm: (config, options) ->
    exec "bash #{__dirname}/scripts/rm #{config.hook_server.address} #{options.repo_name} #{options.hook_name}",
      async:false,
      (code, output) ->
        if code == 1
          # If the requested repo does not exist, warn the user.
          process.stdout.write "\nWARNING: The repository \"#{options.repo_name}\" does not exist.\n\n"
