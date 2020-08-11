# RuleBox

Gerenciador de regra de negócios
Gem construida baseando-se nos padrões de projetos (Design Pattern):
* Facade - Tem escopo **estrutural**. Abstraí a complexidade da chamada das regras de negócio.
* Strategy - tem escopo **comportamento**. Organiza as regras de negócio em classes.

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

Para utilizar regras de negócio no seu **Model** com RFacade ele deve ter uma lista de regra de négocio.

#### 1. Criando regra de negócio (Strategy).

Por exemplo, crie um arquivo *check_name.rb*.

Nesta classe deve herdar da class Strategy e sobrescrecer seu método *process*.

Dentro deste método vai sua lógica de regra de negócio.

```ruby
require 'rule_box/strategy'

class CheckName < RuleBox::Strategy
  def process
    # qualquer lógica aqui
  end
end
```

Na classe *Strategy* existe alguns *helpers* para auxiliar-lhe.
```ruby
strategy.model # retorna o "Model"
strategy.set_status # seta o semáfora: [:red, :yellow, :green]
strategy.add_error # Adiciona uma mensagem de erro
```

refatorando o arquivo *check_name.rb*.
```ruby
require 'rule_box/strategy'

class CheckName < RuleBox::Strategy
  def process
    user = model
    if user.name.nil?
      add_error 'Nome não pode ficar em branco.'
      set_status :red
    elsif user.name.size < 4
      add_error 'Nome deve conter pelo menos 4 caracteres'
      set_status :red
    end
  end
end
```

#### 2. Mapear as regras de negócio no Model
```ruby
require 'rule_box/mapper'
require_relative 'validate_name'

class User
  include RuleBox::Mapper
  attr_accessor :name

  # lista de regras de negócio
  rules_of_insert Rules::CheckName

end
```

#### 3. Chamar RFacade
```ruby
require 'rule_box/facade'

user = User.new
facade = Rulebox::Facade.new
facade.insert user
puts facade.status # :red
puts facade.errors # ["Nome não pode ficar em branco."]

user = User.new
user.name = 'Lia'
facade =  Rulebox::Facade.new
facade.insert user
puts facade.status # :red
puts facade.errors  # ["Nome deve conter pelo menos 4 caracteres"]

user = User.new
user.name = 'Alex'
facade =  Rulebox::Facade.new
facade.insert user
puts facade.status # :green
puts facade.errors # []

```

#### Aplicando multiplos regras de negócio

```ruby
class CheckName < RuleBox::Strategy
  def process
    user = model

    if user.name.nil?
      add_error 'Nome não pode ficar em branco.'
      set_status :red
    elsif user.name.size < 4
      add_error 'Nome deve conter pelo menos 4 caracteres'
      set_status :red
    end
  end
end

class CheckAge < RuleBox::Strategy
  def process
    user = model

    if !user.age.is_a? Integer
      add_error '"age must be an Integer"'
      set_status :red
    elsif user.age < 18
      add_error 'must be over 18 years old'
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

# Classe com multiplas regras de negócio
class User
  include RuleBox::Mapper
  attr_accessor :name, :age

  rules_of_insert Rules::CheckName, Rules::CheckAge, Rules::SaveModel

end

```

 
## Development

Em desesolvimento pode mostrar os passos (steps) ocorrido no Facade

```ruby
user = User.new
user.name = 'Beltrano'
user.age = 19

facade = RuleBox::Facade.new
facade.show_steps = true
facade.insert user

# Saída do Log
# [2020-07-29T08:09:00.212-03:00] { method: insert, model: User, args: {} }
# [2020-07-29T08:09:00.212-03:00] amount of rules 3
# [2020-07-29T08:09:00.212-03:00] executing of rule: Rules::CheckName.
# [2020-07-29T08:09:00.212-03:00] executing of rule: Rules::CheckAge.
# [2020-07-29T08:09:00.212-03:00] executing of rule: Rules::SaveModel.
# [2020-07-29T08:09:00.212-03:00] finalized the process on the facade.
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).