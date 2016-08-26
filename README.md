Cidade Democrática
==================

O Instituto Cidade Democrática nasceu em novembro de 2008 e hoje se consolida como um Think and Do Tank brasileiro de participação social. Levanta e analisa dados, produz e compartilha conhecimento para alavancar o poder da sociedade civil. Faz essa transformação acontecer com  ferramentas de mapeamento e análise de redes e tecnologia social de Concurso de Ideias. Acredita que a influência do cidadão comum na tomada de decisão sobre questões públicas é pilar fundamental para o fortalecimento da democracia no país.

O cidade democrática é um software de inovação aberta para questões e políticas públicas nas cidades. Existe desde 2008, é escrito em Ruby on Rails e foi refatorado uma vez em 2013/2014.

Na lógica do software, as pessoas se registram apontando suas cidades e/ou bairros, a partir daí conseguem visualizar propostas e problemas públicos nesses territórios. Pode criar uma nova proposta ou problema e fazer campanha nas redes pela sua causa. Porém, a principal lógica do cidade são os concursos de inovação aberta. O concurso é formado por diversas fases (propostas, aplauso, união e anúncio) e a principal diferença é que, em cada fase, diferentes ações (criar proposta, comentar, editar, apoiar, seguir) estão ativas ou inativas. Isso acontece para criar uma dinâmica mais gamificada e aumentar o engajamento nos contextos e territórios onde ocorrem os concursos. Na página inicial do aplicativo estão listados os últimos concursos que foram realizados. A interface admin do software permite que os concursos sejam criados e parametrizados.

O software passou por uma refatoração e atualização do rails em 2013 e 2014 e desde então está com o desenvolvimento inativo, ainda que esteja sendo utilizado com certa atividade para novos concursos de ideias a cada ano.

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
