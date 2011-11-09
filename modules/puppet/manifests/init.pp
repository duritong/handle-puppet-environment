class puppet {
  augeas{'run_interval':
    context => "/files/etc/puppet/puppet.conf/agent",
    changes => [
      "set environment ${environment}",
      "set runinterval 1800",
    ],
  }
}
