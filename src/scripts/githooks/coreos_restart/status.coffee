#=================================================================================
# Huxley Cluster Githook - Deployment Status Monitoring
#=================================================================================
# This file contains helper functions meant to access the main cluster, parse
# output from fleetctl and deliver status information to the Huxley API server.

{async, shell, sleep} = require "fairmont"
api = require "./api"


get_status = async (cluster) ->
  # Query the cluster's fleetctl tool for information about services.
  command = "/usr/bin/ssh -A -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null " +
            "-p #{cluster.port} #{cluster.address} " +
            "/usr/bin/fleetctl list-units"
  {stdout} = yield shell command

  # Parse the output for structured data.
  data = stdout.split("\n")[1..]

  status = {}
  for line in data
    continue if line == ""
    line = line.split "\t"
    status[line[0][..-9]] = line[2]

  return status

# Monitor the services as they spin-up.
monitor = async (context, services) ->
  {cluster} = context
  while true
    # Read the status of all services.
    status = yield get_status cluster

    # Check for success. All services must be "active" to pass, but a single failure fails the whole thing.
    pass = true
    for service of services
      pass = false if status[service] != "active"
      return false if status[service] == "failed"

    # Return success or wait another 10 seconds.
    if pass then return true else yield sleep 10000

module.exports = {monitor}
