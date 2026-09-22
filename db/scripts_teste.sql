--Ativa as Chaves estrangeiras do Sqlite
PRAGMA foreign_keys;

CREATE TABLE cargo(
id INTEGER PRIMARY KEY AUTOINCREMENT,
nome_cargo TEXT NOT NULL COLLATE NOCASE UNIQUE,
status INTEGER NOT NULL DEFAULT 1) 
STRICT;

CREATE TABLE funcionario(
id INTEGER PRIMARY KEY AUTOINCREMENT, nome_funcionario TEXT NOT NULL COLLATE NOCASE, 
id_cargo INTEGER NOT NULL,
status INTEGER NOT NULL DEFAULT 1, 
data_cadastro TEXT NOT NULL DEFAULT(DATETIME ('now', 'localtime' )), 
FOREIGN KEY(id_cargo) REFERENCES cargo(id) ON UPDATE CASCADE ON DELETE CASCADE,
UNIQUE (id, id_cargo)) STRICT;

INSERT INTO cargo (nome_cargo) VALUES ('Gerente'), ('Atendente'), ('Técnico');

INSERT INTO funcionario (nome_funcionario, id_cargo) VALUES 
  ('Carlos Silva', 3),
  ('Mariana Souza', 3),
  ('Roberto Alves', 3),
  ('Fernanda Lima', 2),
  ('Lucas Mendes', 2),
  ('Patricia Costa', 1);

CREATE TABLE cliente (
	id INTEGER PRIMARY KEY AUTOINCREMENT, nome_funcionario TEXT NOT NULL COLLATE NOCASE, 
	nome_cliente TEXT NOT NULL COLLATE NOCASE,
	email TEXT NOT NULL COLLATE NOCASE UNIQUE,
	status INTEGER NOT NULL DEFAULT 1,
	id_funcionario INTEGER NOT NULL,
	id_funcionario_cargo INTEGER NOT NULL,
	data_cadastro TEXT NOT NULL DEFAULT (DATETIME('now', 'localtime')),
	FOREIGN KEY (id_funcionario, id_funcionario_cargo) REFERENCES funcionario(id, id_cargo)
)STRICT;

INSERT INTO cliente (
    nome_funcionario, 
    nome_cliente, 
    email, 
    id_funcionario, 
    id_funcionario_cargo
) VALUES (
    'Carlos Silva', 
    'João Pereira', 
    'joao.pereira@email.com', 
    1, 
    3
);


