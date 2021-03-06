#=================================================================================
# Huxley Cluster Githook - Helpers
#=================================================================================
# This file contains helper functions for the main githook.
{join} = require "path"
{async, stat, readdir, collect, stream, lines, times} = require "fairmont"
Configurator = require "panda-config"
key_forge = require "key-forge"

module.exports =
  # Print fancy output to user during "git push" command.
  print_banner: (text) ->
    console.log "\n"
    console.log "==============================================================="
    console.log "#{text}"
    console.log "==============================================================="

  # This creates a random authorization token, 16 bytes long and using characters safe for URLs.
  make_key: () -> key_forge.randomKey 16, "base64url"

  # Generic data reading from panda-config.
  pull_configuration: async (spec) ->
    configurator = Configurator.make
      extension: ".yaml"
      format: "yaml"
      paths: [ spec.path ]

    config = configurator.make name: spec.name
    yield config.load()
    return config.data

  # Handy function to retrieve the name of every sub-directory within a directory.  Returns an array.
  get_dirs: async (path) ->
    file for file in (collect yield readdir path) when (yield stat join path, file).isDirectory()
