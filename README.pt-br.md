# RuleBox

Esta gem tem como objetivo fornecer uma maneira forte e concreta de gerenciar suas regras de negócios, combinando o melhor dos dois mundos em Facade e Strategy, trazendo a você uma maneira simplificada de aplicar esses _Design Patterns_ em seu projeto.

#### O que é Facade?

Facade nada mais é do que um objeto que funciona como uma interface frontal, abstraindo código estrutural ou subjacente mais complexo.
Benefícios:

  - Melhora a sua legibilidade e usabilidade.
  - Ele fornece uma interface específica de contexto para uma funcionalidade mais genérica.
  - Ele oculta as complexidades do sistema maior e fornece uma interface mais simples para o cliente.

#### O que é Strategy?

Strategy é um padrão de design comportamental que permite definir uma família de algoritmos, colocar cada um deles em uma classe separada e tornar seus objetos reutilizáveis.

Em vez de o objeto ter todas as regras de negócio dentro do model, elas serão alocadas em classes separadas, que serão consideradas agora como _strategies_. Essas classes também podem ser usadas dentro de outros objetos.

## Instalação

Adicione esta linha ao Gemfile do seu aplicativo:

```ruby
gem 'rule_box'
```

Então execute:

    $ bundle install

Ou instale você mesmo:

    $ gem install rule_box

## Utilização

Para começar a usar regras de negócios dentro de seu **model** com RuleBox, eles devem possuir uma lista de regras de negócios.

#### 1. Criando regra de negócio (Strategy).

Crie um arquivo chamado *check_name.rb*.

Nesta classe, ele deve herdar da classe Strategy e substituir seu método *process*.

Então, dentro desse método, insira sua lógica de regra de negócios.

```ruby
require 'rule_box/strategy'

class CheckName < RuleBox::Strategy
  def process
    # sua lógica aqui
  end
end
```

Existem alguns *helpers* na classe *Strategy* que irão ajudá-lo.

```ruby
strategy.model # Retorna o "Model"
strategy.set_status # Seta o valor semáforo: [:red, :yellow, :green] 
strategy.add_error # Adiciona uma mensagem de erro
```

Então, seu arquivo *check_name.rb* deverá ficar assim:

```ruby
require 'rule_box/strategy'

class CheckName < RuleBox::Strategy
  def process
    user = model
    if user.name.nil?
      add_error 'Nome não pode ficar em branco'
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

#### 3. Chamar RuleBox
```ruby
require 'rule_box/facade'

user = User.new
facade = Rulebox::Facade.new
facade.insert user
puts facade.status # :red
puts facade.errors # ["Nome não pode ficar em branco"]

user = User.new
user.name = 'Ana'
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
      add_error 'Nome não pode ficar em branco'
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
      add_error 'Idade precisa ser um número inteiro'
      set_status :red
    elsif user.age < 18
      add_error 'Deve ser maior que 18'
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

# Exemplo de classe com múltiplas regras de negócio
class User
  include RuleBox::Mapper
  attr_accessor :name, :age

  rules_of_insert Rules::CheckName, Rules::CheckAge, Rules::SaveModel

end

```

 
## Desenvolvimento

Uma vez no modo de desenvolvimento, ele pode exibir as etapas (steps) que ocorreram no Facade.

```ruby
user = User.new
user.name = 'Carlos'
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