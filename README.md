Cidade Democrática
==================

Serviços:

  * Apache2 + Passenger
  * Memcached
  * Redis
  * Postfix
  * MySQL (5.1 em staging, Percona 5.5 em produção)
  * Monit

Deploy:

  * em staging: `cap deploy`
  * em produção: `cap production deploy`
  * resque workers:
    `start resque ID=0`
    `stop resque ID=0`
  * assets
    `bundle exec rake assets:precompile RAILS_ENV=production`

Variáveis de ambiente:

  ENV['SECRET_TOKEN']
  ENV['RESQUE_ADMIN_PASSWORD']

Desenvolvimento:

  * rvm install ree
  * rvm ree
  * bundle
  * (copiar e editar config/database.example.yml)
  * rake db:create
  * rake db:migrate
  * instalar o plugin editorconfig.org no seu editor

Resque:

  * QUEUES=* bundle exec rake resque:work

Arquivos de configuração:

  `cp doc/monit /etc/monit/monitrc`
  `cp doc/mysql /etc/mysql/my.cnf`
  `cp doc/upstart /etc/init/resque.conf`

Backup do banco de dados (production):

  ssh root@<ip da maquina>
    mysqldump --socket /var/run/mysqld/mysqld.sock -u<user> -p<password> --single-transaction --routines --triggers cidadedemocrat > <filename>.sql
    tar cvfz <filename>.tgz <filename>.sql

  scp root@<ip da maquina>:<filename>.tgz .
