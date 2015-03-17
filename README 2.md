# Edools

## Dependências

Uma dependência (que deve ser instalado em **PRODUÇÃO e em desenvolvimento**)
para a geração de certificados é
[wkhtmltopdf](https://code.google.com/p/wkhtmltopdf), mais especificamente a
[versão 0.9.9](https://code.google.com/p/wkhtmltopdf/down
loads/detail?name=wkhtmltopdf-0.9.9-static-amd64.tar.bz2). Ele deve ser
instalado na pasta */usr/bin* do servidor.

O script para instalar o wkhmltopdf pode ser assim:

```bash
wget https://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.9.9-static-amd64.tar.bz2
sudo tar xfvj wkhtmltopdf-0.9.9-static-amd64.tar.bz2 -C /usr/bin
sudo mv /usr/bin/wkhtmltopdf-amd64 /usr/bin/wkhtmltopdf
```

## Desenvolvimento

### Práticas

* Antes de commitar, rode todos os testes!
* Os commits sempre devem ser feitos apenas para o branch develop. Commits para
  o branch master são feitos apenas quando for colocar uma versão em produção.
* Ao fazer mudanças no banco de dados, sempre criar novos migrations e
  considerar os registros existentes, fazendo um tratamento com rotinas dentro
  da própria migration.
* Ao adicionar um item em um locale, sempre adicionar nos outros.
* O versionamento da versão de produção deve seguir o
  [Semantic Versioning](http://semver.org). Além disso, quando fizer o bump da
  nova versão, deve-se [criar uma tag no git](http://git-scm.com/book/en/Git-Basics-Tagging)
* Utilize o zeus, ele vai melhorar sua produtividade.
* Sempre utilize aspas simples em código ruby, a não ser que tenha que fazer
  interpolação.

### Setup

- [Instalar o PhantomJS](https://github.com/jonleighton/poltergeist#installing-phantomjs)
- Instalar o zeus: `gem install zeus --no-rdoc --no-ri`
- `cp config/database.dev.yml.example config/database.dev.yml` #modifique para suas configurações locais
- `rake db:create:all db:migrate db:test:prepare parallel:create parallel:prepare`
