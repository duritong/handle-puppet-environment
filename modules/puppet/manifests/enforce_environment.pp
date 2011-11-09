class puppet::enforce_environment {
  augeas{'enforce_environment':
    context => "/files/etc/puppet/puppet.conf/agent",
    changes => [
      "set envifornment ${environament}",
      "set runinterval 1",
    ],
  }
}
