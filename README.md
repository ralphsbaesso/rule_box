# 🧰 RuleBox 

This gem mixes the best of both worlds in Facade and Strategy, bringing you a simplified way to apply these _Design Patterns_ into your project.

#### What is Facade?

Facade is nothing more than an object that serves as a front-facing interface, abstracting more complex underlying or structural code.
Benefits:

 - It improves your readability and usability.
 - It provides a context-specific interface to more generic functionality.
 - It hides the complexities of the larger system and provides a simpler interface to the client.

#### What is Strategy?

Strategy is a behavioral design pattern that lets you define a family of algorithms, put each of them into a separate class, and make their objects reusable.

Instead of the object having all the business rules inside the model, they will be alocated in separate classes, which will be considered now as _strategies_. These classes could be used inside other objects as well.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rule_box'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rule_box

## Usage

To get started using business rules inside your **model** eith RFacade, they must have a business rules list.

#### 1. Creating the business rules (Strategy).

Create a file named *check_name.rb*.

In this class, it should inherit from Strategy class and overwrite its method *process*.

Then, inside this method, it goes your business rule logic.


```ruby
require 'rulebox/strategy'

class CheckName < RuleBox::Strategy
  def process
    # your code here
  end
end
```

There are some *helpers* in the class *Strategy* that will help you out.

```ruby
strategy.model # returns "Model"
strategy.set_status # sets the light: [:red, :yellow, :green]
strategy.add_error # adds an error message
```

So, your file *check_name.rb* should look like this:

```ruby
require 'rulebox/strategy'

class CheckName < RuleBox::Strategy
  def process
    user = model
    if user.name.nil?
      add_error 'Name cannot be empty' 
      set_status :red
    elsif user.name.size < 4
      add_error 'Name must contain at least 4 characters'
      set_status :red
    end
  end
end
```

#### 2. Mapping the business rules in the Model
```ruby
require 'rule_box/mapper'
require_relative 'validate_name'

class User
  include RFacade::Mapper
  attr_accessor :name

  # list of business rules
  rules_of_insert Rules::CheckName

end
```

#### 3. Call RFacade

```ruby
require 'rule_box/facade'

user = User.new
facade = RuleBox::Facade.new
facade.insert user
puts facade.status # :red
puts facade.errors # ["Name cannot be empty."]

user = User.new
user.name = 'Lia'
facade = RuleBox::Facade.new
facade.insert user
puts facade.status # :red
puts facade.errors  # ["Name must contain at least 4 characters"]

user = User.new
user.name = 'Alex'
facade = RuleBox::Facade.new
facade.insert user
puts facade.status # :green
puts facade.errors # []

```

#### Applying multiple business rules

```ruby
class CheckName < RuleBox::Strategy
  def process
    user = model

    if user.name.nil?
      add_error 'Name cannot be empty.'
      set_status :red
    elsif user.name.size < 4
      add_error 'Name must contain at least 4 characters'
      set_status :red
    end
  end
end

class CheckAge < RuleBox::Strategy
  def process
    user = model

    if !user.age.is_a? Integer
      add_error '"Age must be an integer"'
      set_status :red
    elsif user.age < 18
      add_error 'Age cannot be under 18'
      set_status :red
    end
  end
end

class SaveModel < RuleBox::Strategy
  def process
    if status == :green
      # DAO.persist_model(model)
    end
  end
end

# Class example with multiple business rules
class User
  include RFacade::Mapper
  attr_accessor :name, :age

  rules_of_insert Rules::CheckName, Rules::CheckAge, Rules::SaveModel

end

```

 
## Development

Once in development mode, it can display the steps that took place in Facade.

```ruby
user = User.new
user.name = 'John Wick'
user.age = 19

facade = RuleBox::Facade.new
facade.show_steps = true
facade.insert user

# Log Output
# [2020-07-29T08:09:00.212-03:00] { method: insert, model: User, args: {} }
# [2020-07-29T08:09:00.212-03:00] amount of rules 3
# [2020-07-29T08:09:00.212-03:00] executing of rule: Rules::CheckName.
# [2020-07-29T08:09:00.212-03:00] executing of rule: Rules::CheckAge.
# [2020-07-29T08:09:00.212-03:00] executing of rule: Rules::SaveModel.
# [2020-07-29T08:09:00.212-03:00] finalized the process on the facade.
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).