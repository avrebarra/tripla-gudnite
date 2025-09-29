# Setup RSpec Rails

**User:** Avrê Barra (avrebarra@gmail.com)  
**Created:** 9/29/2025 5:19:13  
**Updated:** 9/29/2025 5:20:11  
**Exported:** 9/29/2025 5:20:26  
**Link:** [https://chatgpt.com/c/68d9b444-4ecc-8322-991a-5e45c85cc2b6](https://chatgpt.com/c/68d9b444-4ecc-8322-991a-5e45c85cc2b6)  

## Prompt:
how to setup rspec rails that has all basic batteries included: test sqlite database with teardowns mock and stuffs

## Response:
Got it 👍 You want a **Rails + RSpec setup that’s fully loaded** with the usual testing batteries:

*   RSpec core & rails integration
*   SQLite test database with clean state between tests
*   Fixtures/factories
*   Mocking/stubbing tools
*   Easy-to-run setup

Here’s a clean recipe:

* * *

### 1\. Add gems to your `Gemfile`

Put these in the `:development, :test` group:

```ruby
group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

group :test do
  gem "database_cleaner-active_record"
  gem "shoulda-matchers"
end
```

Then install:

```bash
bundle install
```

* * *

### 2\. Install RSpec

```bash
rails generate rspec:install
```

This will create:

*   `.rspec` → config for running RSpec
*   `spec/spec_helper.rb`
*   `spec/rails_helper.rb`

Update `.rspec` to include:

```
--require spec_helper
--format documentation
```

* * *

### 3\. Configure Database

Use SQLite for testing in `config/database.yml`:

```yaml
test:
  adapter: sqlite3
  database: db/test.sqlite3
  pool: 5
  timeout: 5000
```

Reset db before running tests:

```bash
rails db:test:prepare
```

* * *

### 4\. Configure RSpec helpers

Edit `spec/rails_helper.rb` and add:

```ruby
RSpec.configure do |config|
  # Use FactoryBot methods directly
  config.include FactoryBot::Syntax::Methods

  # DatabaseCleaner setup
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Infer spec type from file location (controller, model, etc.)
  config.infer_spec_type_from_file_location!
end
```

* * *

### 5\. Setup Shoulda Matchers

In `spec/rails_helper.rb`:

```ruby
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
```

* * *

### 6\. Example usage

**Factory** (`spec/factories/users.rb`):

```ruby
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "password123" }
  end
end
```

**Model spec** (`spec/models/user_spec.rb`):

```ruby
require "rails_helper"

RSpec.describe User, type: :model do
  it { should validate_presence_of(:email) }

  it "creates a valid user" do
    user = create(:user)
    expect(user).to be_valid
  end

  it "can be mocked" do
    mock_user = double("User", name: "Testy")
    expect(mock_user.name).to eq("Testy")
  end
end
```

* * *

Now you have:  
✅ RSpec base  
✅ SQLite test DB with clean state (DatabaseCleaner)  
✅ FactoryBot + Faker  
✅ Shoulda-matchers (validations/associations)  
✅ Built-in mocks (`double`, `allow`, `expect`)

* * *

Do you want me to also include **API request specs setup** (with helpers for JSON requests and parsing responses), or just keep it at the basic model/controller testing level?

## Prompt:
how do i execute rspec?

## Response:
Super simple 👌

Once you’ve set up `rspec-rails`, you can run tests with:

```bash
bundle exec rspec
```

That will run **all specs** in the `spec/` folder.

* * *

### Common ways to run:

*   Run **everything**:
    ```bash
    bundle exec rspec
    ```
*   Run specs in a **specific file**:
    ```bash
    bundle exec rspec spec/models/user_spec.rb
    ```
*   Run a **single example** (using line number):
    ```bash
    bundle exec rspec spec/models/user_spec.rb:12
    ```
*   Run with **detailed output** (if not set in `.rspec` already):
    ```bash
    bundle exec rspec --format documentation
    ```

* * *

💡 Tip: If you’re in VS Code or a good terminal, you can add a shortcut like:

```bash
rspec
```

instead of `bundle exec rspec` by adding this to your shell config:

```bash
alias rspec="bundle exec rspec"
```

* * *

Do you want me to also show you how to **auto-run specs on file changes** (using something like `guard-rspec`), so you don’t have to type the command each time?
