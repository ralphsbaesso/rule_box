# RuleBox
___

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

## Atenção
A nova versão da gem é focada em cado de uso.
Com o objetivo de desacoplar as entidades mas manter a robustez da execução das regras de negócios.

As versões anteriores não serão mais compatíveis.

## Utilização

Para começar a usar regras de negócios dentro de seu **model** com RuleBox, eles devem possuir uma lista de regras de negócios.

#### 1. Criando caso de uso (UseCase)

Crie um arquivo chamado *use_case.rb*.

Nesta classe, ele deve herdar da classe RuleBox::UseCase.

Mapeie os attributos que o caso de uso irá utilizar.

Mapeie as regras de negócios que o caso de uso irá passar.

```ruby
require 'rule_box/use_case'

class UseCase < RuleBox::UseCase
  attributes :name, :email

  rules CheckName,
        CheckEmail,
        Create
end
```

Os attributos podem ser acessado pelo o método attributos ou por alias attr

```ruby

use_case =  UseCase.new
use_case.attributes.name
# ou
use_case.attr.name
```

Pode obrigar injeção de dependência no seu caso de uso
```ruby

class UseCase < RuleBox::UseCase
  add_dependency :user do |value|
    'Must be an "User"' unless value.is_a? User
  end
end

# irá lançar um exceção
use_case = UseCase.new # => 'Must be an "User"'

# deve passar a dependência na criação do objeto
user = User.new
use_case = UseCase.new user: user

# pode acessar a dependência com o método "dependencies"
use_case.dependencies.user # => User(clone)
# ou
use_case.dep.user # => User(clone)
```


#### 2. Criando regra de negócio (Strategy).

Crie um arquivo chamado *check_name.rb*.

Nesta classe, ele deve herdar da classe Strategy e substituir seu método **perform**.

Então, dentro desse método, insira sua lógica de regra de negócios.

```ruby
require 'rule_box/strategy'

class CheckName < RuleBox::Strategy
  def perform(use_case, last_result)
    # sua lógica aqui
  end
end
```

Existem alguns *helpers* na classe *Strategy* que irão ajudá-lo.

```ruby
stop # para o cyclo de strategy 
stop! # para o cyclo de strategy e a execução do código 
```

O método perform pode ser implementado com 3 assinaturas
1. Com 2 parâmetros
```ruby
def perform(use_case, last_result)
  use_case # => o caso de uso
  last_result # => o resultado da Strategy anterior
end
```

2. Com 1 parâmetros
```ruby
def perform(use_case)
  use_case # => o caso de uso
end
```

3. Sem parâmetros
```ruby
def perform
  # nenhum parâmetro
end
```

Exemplos de **strategies**:

```ruby
require 'rule_box/strategy'

class CheckName < Strategy
  def perform(use_case)
    name = use_case.attr.name

    use_case.errors << "Name can't be empty!" if name.nil? || name.to_s.empty?
  end
end

class CheckEmail < Strategy
  def perform(use_case)
    email = use_case.attr.email

    use_case.errors << 'Invalid email!' unless email =~ URI::MailTo::EMAIL_REGEXP
  end
end

class Create < Strategy
  def perform(use_case)
    return RuleBox::Result::Error.new(errors: use_case.errors) unless use_case.errors.empty?

    user = User.new
    user.name = use_case.attr.name
    user.email = use_case.attr.email
    RepositoryUser.save(user)

    RuleBox::Result::Success.new(data: user)
  end
end
```

#### Retorno do Strategy
Quando é executado um UseCase, o resultado setá o retorno da última Strategy

Esta gem fornece classes para tratar resultados, mas não é obrigatório utiliza-las.
Nos exemplos serão utilizadas as classes que herdam de RuleBox::Result

### RuleBox::Result
São classes especiais para tratar os resultados
```ruby
error_result = RuleBox::Result::Error.new(errors: ['any error'])
error_result.status # => "error"
error_result.data # => nil
error_result.meta # => nil
error_result.errors # => ["any error"]

success_result = RuleBox::Result::Success.new(data: { value: 134}, meta: { time: '0.1 s' })
success_result.status # => "ok"
success_result.data # => { value: 134 }
success_result.meta # => { time: "0.1 s" }
success_result.errors # => nil
```


#### 3. Invocar o Caso de Uso

Deve invocar o caso de uso com o métod *exec*. Irá retornar um objeto do tipo RuleBox::Result
```ruby
use_case = UseCase.new
result = use_case.exec(name: 'Raulzito', email: 'raulzito@maluco.beleza')

result.class.name # => RuleBox::Result::Error
```

Exemplos:

```ruby
class UseCase < RuleBox::UseCase
  attributes :name, :email

  rules CheckName,
        CheckEmail,
        Create
  
  def errors
    @errors ||= []
  end
end

use_case = UseCase.new
result = use_case.exec

result.class.name # => RuleBox::Result::Error
result.status # => 'error'
result.errors # => ["Name can't be empty!", "Invalid email!"]

use_case = UseCase.new
result = use_case.exec name: 'my_name', email: '_invalid_email_'

result.status # => 'error'
result.errors # => ["Invalid email!"]

use_case = UseCase.new
result = use_case.exec name: 'Raulzito', email: 'raulzito@maluco.beleza'
result.class.name # => RuleBox::Result::Success
result.status # => 'ok'

user = result.data
user.class.name # => User
```

____
 
## Hooks

Existem alguns hooks que podem auxiliar na chamadas das regras de negócio

| Hook             | Descrição                        |
|------------------|----------------------------------|
| after_rule       | depois de cada regra             |
| after_rules      | depois de todas as regras        |
| around_rule      | na execução de cada regra        |
| around_rules     | na execução de todas as regras   |
| before_rule      | antes de cada regra              |
| before_rules     | antes de todas as regras         |
| rescue_from      | captura uma exeção               |

Exemplos:
```ruby

class UserCase < RuleBox::UseCase
  before_rules { puts 'before all' }
  before_rule do |use_case|
    puts 'before'
    puts use_case.facade.steps.last
  end
  after_rule do |use_case|
    puts use_case.facade.steps.last
    puts 'after'
  end
  before_rules { puts 'after all' }
end

use_case = UseCase.new
use_case.exec name: 'José', email: 'jose@uouou.com.br'

# Saída do Log
# before all
# before
# [2020-07-29T08:09:00.212-03:00] executing of rule: Rules::CheckName.
# [2020-07-29T08:09:00.212-03:00] executing of rule: Rules::CheckName.
# after
# before
# [2020-07-29T08:09:00.212-03:00] executing of rule: Rules::CheckAge.
# [2020-07-29T08:09:00.212-03:00] executing of rule: Rules::CheckAge.
# after
# before
# [2020-07-29T08:09:00.212-03:00] executing of rule: Rules::SaveModel.
# [2020-07-29T08:09:00.212-03:00] executing of rule: Rules::SaveModel.
# after
# after all
```

### Capturando uma exceção com rescue_from

Com o método hook **rescue_from** é possível capturar exeções.
Este método pode ser chamado pela classe RuleBox::UseCase e quem herdar dela.
Também pode ser invocado pelo o módulo RuleBox.


#### UseCase
Quando configurado no UseCase, a exceção será tratado apenas na própria classe.

```ruby

class UserCase < RuleBox::UseCase
  # tratando com um block
  rescue_from FirstException, FirstException, FirstException do |use_case|
    # sua lógica aqui
  end
  
  # or
  
  # tratando com um método, quando ocorrer uma exceção irá invocar o method da instância do UseCase
  rescue_from StandardError, with: :handle_error
  
  def handle_error
    # sua lógica aqui
  end
end

```

#### RuleBox
Quando configurado no módulo RuleBox, todos as exceções serão tratadas no módulo.

Para projeto Rails, crie um arquivo */config/initializers/rule_box.rb*
```ruby

# no módulo só é possível tratar com block
RuleBox.rescue_from AnyException, StandardError do |use_case|
    # sua lógica aqui
end
```

### Exemplos
Mais exemplos em [examples](spec/examples)


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).