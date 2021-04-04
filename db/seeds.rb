# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Campaign.create!([
  {
    adwords_id: '868628106',
    name: 'Test Campaign with #PAC inside',
    status: 'ENABLED',
    serving_status: 'SUSPENDED',
    start_date: 2.years.ago,
    end_date: 2.years.ago + 1.day,
  },
  {
    adwords_id: '443327848',
    name: '1.07 - Géotext Cp - Garage - Marques',
    status: 'ENABLED',
    serving_status: 'SUSPENDED',
    start_date: 2.days.ago,
    end_date: 2.days.ago + 1.day,
  },
  {
    adwords_id: '443332168',
    name: '7.03 - Cyclomoteurs - Géotext Ville - Garage',
    status: 'PAUSED',
    serving_status: 'SUSPENDED',
    start_date: 4.years.ago,
    end_date: 4.years.ago + 1.day,
  },
  {
    adwords_id: '443331208',
    name: '6.02 - Elements Autres - Carrosserie - Voiture',
    status: 'ENABLED',
    serving_status: 'SUSPENDED',
    start_date: 2.years.ago,
    end_date: 2.years.ago + 1.day,
  },
])

AdGroup.create!([
  {
    campaign_id: Campaign.find_by(adwords_id: '443331208').id,
    adwords_id: '32939048008',
    name: 'Volvo - peinture',
    status: 'ENABLED',
  },
  {
    campaign_id: Campaign.find_by(adwords_id: '443327848').id,
    adwords_id: '32939048008',
    name: 'BMW - vidange',
    status: 'ENABLED',
  },
  {
    campaign_id: Campaign.find_by(adwords_id: '443332168').id,
    adwords_id: '32939048008',
    name: 'Ssangyong - CP',
    status: 'ENABLED',
  },
  {
    campaign_id: Campaign.find_by(adwords_id: '443331208').id,
    adwords_id: '32939048008',
    name: 'VVolkswagen - carrosserie',
    status: 'ENABLED',
  },
])