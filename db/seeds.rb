# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.new(fname: 'FirstName', lname: 'LastName', dob: '1980-01-01',
                phone: '5555550001', password: 'Abcde_12345',
                email: 'user1@email.com')
user.generate_token
user.save!
# Log user token for quicker testing
p user.token
