class puppet::enforce_environment {
  augeas{'enforce_environment':
    context => "/files/etc/puppet/puppet.conf/agent",
    changes => [
      "set environment ${environment}",
      "set runinterval 1",
    ],
    notify => Exec['reparse_config'];
  }
  exec{'reparse_config':
    command => '/bin/kill -SIGHUP `/bin/cat /var/run/puppet/agent.pid`',
    refreshonly => true,
  }
}
