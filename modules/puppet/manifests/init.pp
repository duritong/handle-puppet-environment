class puppet {
  augeas{'runinterval_and_environment':
    context => "/files/etc/puppet/puppet.conf/agent",
    changes => [
      "set environment ${environment}",
      "set runinterval 1800",
    ],
  }
}
