# -*- mode: ruby -*-
$ABSFILE = File.absolute_path(__FILE__)
$ABSDIR = File.dirname($ABSFILE)
$COPS_DIR = ENV.fetch('LOCAL_COPS_ROOT',
                       File.join($ABSDIR, "local/corpusops.bootstrap"))
$VAGRANT = "#{$COPS_DIR}/hacking/vagrant/Vagrantfile_common.rb"
require $VAGRANT
cfg = cops_dance({:cwd => $ABSDIR, :cops_path => $COPS_DIR})
ansible_vars = { :raw_arguments => [] }
# playbooks than plays everywhere
cfg = cops_inject_playbooks \
    :cfg => cfg,
    :playbooks => [
        # install docker
        {"#{cfg['COPS_REL_PLAYBOOKS']}/provision/vagrant/docker.yml" => ansible_vars},
        # install nginx http server
        # install PHP-FPM
        # install a postgresql server, db & user
        # install django (fpm-pool && django setup)
        # install pureftpd
        {"local/setup.postgresql/.ansible/playbooks/site_vagrant.yml" => ansible_vars},
        {".ansible/playbooks/site_vagrant.yml" => ansible_vars},
        {".ansible/playbooks/ftp.yml" => ansible_vars},
    ]

debug cfg.to_yaml
# vim: set ft=ruby ts=4 et sts=4 tw=0 ai:
