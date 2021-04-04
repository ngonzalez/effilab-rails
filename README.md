# effilab-rails

Adwords API integrated to Rails 6.1 application

Requirements:

* Ruby version
2.7.2

* System dependencies
PostgreSQL version 13.0

* Configuration
Edit `.env` file at the root of the application

* Database creation
`bundle exec rails db:create`

* Database initialization
`bundle exec rails db:seed`

* How to run the test suite
`bundle exec rspec spec/`

* Deployment instructions
Please see Ansible repository:
https://github.com/ngonzalez/ansible/tree/effilab

* Adwords API: Authenticate
`bundle exec rake adwords_api:setup`

* Adwords API: Import Campaigns, Ad Groups
`bundle exec rake adwords_api:import`

* Adwords API: Process data and log infos
`bundle exec rake adwords_api:process`
