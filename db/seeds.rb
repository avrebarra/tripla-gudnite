# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

# Sample users for development/testing
users = [
  { name: 'Alice', email: 'alice@example.com', password: 'password123' },
  { name: 'Bob', email: 'bob@example.com', password: 'password123' },
  { name: 'Charlie', email: 'charlie@example.com', password: 'password123' }
]

users.each do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |user|
    user.name = attrs[:name]
    user.password = attrs[:password]
  end
end

# Sample follow relationships: Alice follows Bob and Charlie, Bob follows Alice
alice = User.find_by(email: 'alice@example.com')
bob = User.find_by(email: 'bob@example.com')
charlie = User.find_by(email: 'charlie@example.com')

Following.find_or_create_by!(follower: alice, followed: bob)
Following.find_or_create_by!(follower: alice, followed: charlie)
Following.find_or_create_by!(follower: bob, followed: alice)

# Sample sleep records for each user (last week)
now = Time.current
1.upto(3) do |i|
  [ alice, bob, charlie ].each do |user|
    # Variable duration: 6 to 9 hours
    duration_hours = 6 + rand(4) # 6, 7, 8, or 9
    clock_in = now - i.days - duration_hours.hours
    clock_out = now - i.days
    SleepRecord.find_or_create_by!(user: user, clock_in: clock_in) do |sr|
      sr.clock_out = clock_out
      sr.duration = (clock_out - clock_in).to_i
    end
  end
end
