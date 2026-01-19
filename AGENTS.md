# AGENTS.md - Banco Olmeca Rails Application

This file contains essential information for agentic coding agents working on this Ruby on Rails banking simulation application.

## Project Overview
- **Application**: Banco Olmeca - Small bank simulation
- **Ruby Version**: 3.2.1
- **Rails Version**: 7.0.4
- **Database**: PostgreSQL with SQLite support for development
- **Testing**: Rails MiniTest with Factory Bot
- **Linting**: RuboCop

## Development Commands

### Setup
```bash
# Install Ruby dependencies
bundle install

# Setup database
bundle exec rails db:create
bundle exec rails db:migrate

# Start development server
./bin/dev
# or
bundle exec rails server
```

### Testing Commands
```bash
# Run all tests
bundle exec rails test

# Run all tests including system tests
bundle exec rails test:all

# Run system tests only
bundle exec rails test:system

# Run specific test file
bundle exec rails test test/models/account_test.rb

# Run specific test within a file (line-based)
bundle exec rails test test/models/account_test.rb:15

# Run tests with database reset
bundle exec rails test:db
```

### Linting & Code Quality
```bash
# Run RuboCop linting
bundle exec rubocop

# Run RuboCop with auto-correction
bundle exec rubocop -a

# Run only lint cops (faster)
bundle exec rubocop -l

# Check specific file
bundle exec rubocop app/models/account.rb
```

### Database Commands
```bash
# Create database
bundle exec rails db:create

# Run migrations
bundle exec rails db:migrate

# Rollback migration
bundle exec rails db:rollback

# Reset database
bundle exec rails db:reset

# Seed database
bundle exec rails db:seed
```

## Code Style Guidelines

### Ruby/Rails Conventions
- Use standard Ruby 2-space indentation
- Follow RuboCop style guide (Rails-specific cops enabled)
- Use snake_case for variables and methods
- Use CamelCase for classes and modules
- Use SCREAMING_SNAKE_CASE for constants

### Models
- Inherit from `ApplicationRecord`
- Use `has_secure_password` for authentication
- Place validations after associations
- Use callbacks at the bottom of the class
- Use class methods for complex queries
- Always define `as_json` overrides to exclude sensitive fields like `password_digest`

Example model structure:
```ruby
class Account < ApplicationRecord
  has_secure_password
  has_many :cards, -> { order(:id) }
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  
  before_create :assign_defaults
  
  class << self
    def for_operation(query)
      where('email = ? OR id = ?', query, query.to_i).first
    end
  end
  
  def as_json(options = {})
    options[:except] ||= [:password_digest]
    super(options)
  end
  
  private
  
  def assign_defaults
    # implementation
  end
end
```

### Controllers
- Inherit from `ApplicationController` or appropriate base class
- Use `before_action` for authentication and other cross-cutting concerns
- Keep actions simple and delegate business logic to service objects
- Use strong parameters
- Return proper HTTP status codes

Example controller structure:
```ruby
class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_account, only: [:show, :update]
  
  def index
    @accounts = Account.all
    render json: @accounts
  end
  
  private
  
  def set_account
    @account = Account.find(params[:id])
  end
  
  def account_params
    params.require(:account).permit(:name, :email, :phone)
  end
end
```

### Service Objects
- Inherit from `ApplicationService`
- Use `.call` class method as the main interface
- Return standardized results: `SUCCESS`, `FAILURE`, `PARTIAL_SUCCESS`
- Keep business logic isolated from controllers and models

Example service structure:
```ruby
class AccountTransferService < ApplicationService
  def initialize(source_account, target_account, amount)
    @source = source_account
    @target = target_account
    @amount = amount
  end
  
  def call
    return FAILURE unless valid_transfer?
    
    ActiveRecord::Base.transaction do
      # transfer logic
    end
    
    SUCCESS
  rescue StandardError => e
    FAILURE
  end
  
  private
  
  def valid_transfer?
    # validation logic
  end
end
```

### Testing
- Use MiniTest framework (Rails default)
- Use Factory Bot for test data
- Use descriptive test names that explain what is being tested
- Test happy paths, edge cases, and error conditions
- Use fixtures sparingly; prefer factories

Example test structure:
```ruby
require "test_helper"

class AccountTest < ActiveSupport::TestCase
  test "creates account with valid attributes" do
    account = build(:account, name: "Test User")
    assert account.valid?
  end
  
  test "rejects invalid email format" do
    account = build(:account, email: "invalid-email")
    assert_not account.valid?
    assert_includes account.errors[:email], "is invalid"
  end
end
```

### Error Handling
- Use Rails validation errors for model-level validation
- Raise custom exceptions for business rule violations
- Use proper HTTP status codes in API responses
- Log errors appropriately in production

### Security
- Never expose `password_digest` in JSON responses
- Use strong parameters to prevent mass assignment
- Implement proper authentication and authorization
- Validate user inputs thoroughly
- Use `has_secure_password` for password handling

### Database
- Use PostgreSQL for production, SQLite acceptable for development
- Write database-agnostic code when possible
- Use Rails migrations for schema changes
- Add proper indexes for frequently queried columns
- Use foreign key constraints where appropriate

### File Organization
- Models: `app/models/`
- Controllers: `app/controllers/` and `app/controllers/api/`
- Services: `app/services/`
- Tests: `test/models/`, `test/controllers/`, `test/controllers/api/`
- Factories: `test/factories/`

## Notes
- This application simulates banking operations (transfer, deposit, withdrawal)
- Uses session-based authentication with `Account` model
- Has both web UI and API endpoints
- Uses Tailwind CSS for styling
- Uses Redis for caching (production)
- API documentation with Apipie-rails