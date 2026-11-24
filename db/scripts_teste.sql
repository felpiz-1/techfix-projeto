-- TechFix — DDL oficial
-- SQLite 3.37+ (STRICT tables)
-- Valores monetários armazenados como inteiros em centavos.
-- Execute em uma base vazia. Registros de catálogo devem ser criados antes dos cadastros dependentes.

PRAGMA foreign_keys = ON;

CREATE TABLE cargo (
    id INTEGER PRIMARY KEY,
    nome_cargo TEXT NOT NULL COLLATE NOCASE UNIQUE,
    status INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1))
) STRICT;

CREATE TABLE funcionario (
    id INTEGER PRIMARY KEY,
    nome_funcionario TEXT NOT NULL COLLATE NOCASE,
    id_cargo INTEGER NOT NULL,
    status INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1)),
    data_cadastro TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (id_cargo) REFERENCES cargo(id) ON UPDATE CASCADE ON DELETE RESTRICT
) STRICT;

CREATE TABLE cliente (
    id INTEGER PRIMARY KEY,
    nome_cliente TEXT NOT NULL COLLATE NOCASE,
    email TEXT NOT NULL COLLATE NOCASE UNIQUE,
    telefone TEXT,
    status INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1)),
    data_cadastro TEXT NOT NULL DEFAULT (datetime('now')),
    id_funcionario_cadastro INTEGER NOT NULL,
    FOREIGN KEY (id_funcionario_cadastro) REFERENCES funcionario(id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE marca (
    id INTEGER PRIMARY KEY,
    nome_marca TEXT NOT NULL COLLATE NOCASE UNIQUE,
    status INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1))
) STRICT;

CREATE TABLE modelo (
    id INTEGER PRIMARY KEY,
    nome_modelo TEXT NOT NULL COLLATE NOCASE,
    id_marca INTEGER NOT NULL,
    status INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1)),
    UNIQUE (id_marca, nome_modelo),
    FOREIGN KEY (id_marca) REFERENCES marca(id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE tipo_equipamento (
    id INTEGER PRIMARY KEY,
    nome_tipo TEXT NOT NULL COLLATE NOCASE UNIQUE,
    status INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1))
) STRICT;

CREATE TABLE equipamento (
    id INTEGER PRIMARY KEY,
    id_cliente INTEGER NOT NULL,
    id_modelo INTEGER NOT NULL,
    id_tipo_equipamento INTEGER NOT NULL,
    numero_serie TEXT COLLATE NOCASE UNIQUE,
    imei TEXT COLLATE NOCASE UNIQUE,
    status INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1)),
    data_cadastro TEXT NOT NULL DEFAULT (datetime('now')),
    id_funcionario_cadastro INTEGER NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_modelo) REFERENCES modelo(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_tipo_equipamento) REFERENCES tipo_equipamento(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_funcionario_cadastro) REFERENCES funcionario(id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE categoria_servico (
    id INTEGER PRIMARY KEY,
    nome_categoria TEXT NOT NULL COLLATE NOCASE UNIQUE,
    status INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1)),
    data_cadastro TEXT NOT NULL DEFAULT (datetime('now')),
    id_funcionario_cadastro INTEGER NOT NULL,
    FOREIGN KEY (id_funcionario_cadastro) REFERENCES funcionario(id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE servico (
    id INTEGER PRIMARY KEY,
    nome_servico TEXT NOT NULL COLLATE NOCASE UNIQUE,
    id_categoria_servico INTEGER NOT NULL,
    preco_base_centavos INTEGER NOT NULL CHECK (preco_base_centavos >= 0),
    horas_trabalho REAL NOT NULL CHECK (horas_trabalho > 0),
    status INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1)),
    data_cadastro TEXT NOT NULL DEFAULT (datetime('now')),
    id_funcionario_cadastro INTEGER NOT NULL,
    FOREIGN KEY (id_categoria_servico) REFERENCES categoria_servico(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_funcionario_cadastro) REFERENCES funcionario(id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE status_os (
    id INTEGER PRIMARY KEY,
    nome_status TEXT NOT NULL COLLATE NOCASE UNIQUE
) STRICT;

CREATE TABLE forma_pagamento (
    id INTEGER PRIMARY KEY,
    nome_forma_pagamento TEXT NOT NULL COLLATE NOCASE UNIQUE,
    status INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1))
) STRICT;

CREATE TABLE ordem (
    id INTEGER PRIMARY KEY,
    id_equipamento INTEGER NOT NULL,
    id_funcionario_abertura INTEGER NOT NULL,
    id_tecnico INTEGER NOT NULL,
    id_status_os INTEGER NOT NULL,
    id_forma_pagamento INTEGER,
    data_abertura TEXT NOT NULL DEFAULT (datetime('now')),
    data_fechamento TEXT,
    descricao_defeito TEXT NOT NULL,
    defeito_constatado TEXT,
    valor_total_centavos INTEGER NOT NULL DEFAULT 0 CHECK (valor_total_centavos >= 0),
    CHECK ((data_fechamento IS NULL AND id_forma_pagamento IS NULL) OR
           (data_fechamento IS NOT NULL AND id_forma_pagamento IS NOT NULL)),
    FOREIGN KEY (id_equipamento) REFERENCES equipamento(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_funcionario_abertura) REFERENCES funcionario(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_tecnico) REFERENCES funcionario(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_status_os) REFERENCES status_os(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_forma_pagamento) REFERENCES forma_pagamento(id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE historico_status_os (
    id INTEGER PRIMARY KEY,
    id_ordem INTEGER NOT NULL,
    id_status_os INTEGER NOT NULL,
    data_hora TEXT NOT NULL DEFAULT (datetime('now')),
    id_funcionario INTEGER NOT NULL,
    FOREIGN KEY (id_ordem) REFERENCES ordem(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_status_os) REFERENCES status_os(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_funcionario) REFERENCES funcionario(id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE ordem_servico_item (
    id INTEGER PRIMARY KEY,
    id_ordem INTEGER NOT NULL,
    id_servico INTEGER NOT NULL,
    valor_unitario_centavos INTEGER NOT NULL CHECK (valor_unitario_centavos >= 0),
    quantidade INTEGER NOT NULL DEFAULT 1 CHECK (quantidade > 0),
    data_execucao TEXT NOT NULL DEFAULT (datetime('now')),
    UNIQUE (id_ordem, id_servico),
    FOREIGN KEY (id_ordem) REFERENCES ordem(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_servico) REFERENCES servico(id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE categoria_peca (
    id INTEGER PRIMARY KEY,
    nome_categoria TEXT NOT NULL COLLATE NOCASE UNIQUE,
    status INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1)),
    data_cadastro TEXT NOT NULL DEFAULT (datetime('now')),
    id_funcionario_cadastro INTEGER NOT NULL,
    FOREIGN KEY (id_funcionario_cadastro) REFERENCES funcionario(id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE peca (
    id INTEGER PRIMARY KEY,
    nome_peca TEXT NOT NULL COLLATE NOCASE UNIQUE,
    id_categoria_peca INTEGER NOT NULL,
    preco_venda_centavos INTEGER NOT NULL DEFAULT 0 CHECK (preco_venda_centavos >= 0),
    estoque_atual INTEGER NOT NULL DEFAULT 0 CHECK (estoque_atual >= 0),
    status INTEGER NOT NULL DEFAULT 1 CHECK (status IN (0, 1)),
    data_cadastro TEXT NOT NULL DEFAULT (datetime('now')),
    id_funcionario_cadastro INTEGER NOT NULL,
    FOREIGN KEY (id_categoria_peca) REFERENCES categoria_peca(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_funcionario_cadastro) REFERENCES funcionario(id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE lote_entrada (
    id INTEGER PRIMARY KEY,
    numero_lote TEXT NOT NULL COLLATE NOCASE UNIQUE,
    data_entrada TEXT NOT NULL DEFAULT (datetime('now')),
    id_gerente INTEGER NOT NULL,
    FOREIGN KEY (id_gerente) REFERENCES funcionario(id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE lote_entrada_item (
    id INTEGER PRIMARY KEY,
    id_lote_entrada INTEGER NOT NULL,
    id_peca INTEGER NOT NULL,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    custo_unitario_centavos INTEGER NOT NULL CHECK (custo_unitario_centavos >= 0),
    preco_sugerido_centavos INTEGER NOT NULL CHECK (preco_sugerido_centavos >= 0),
    UNIQUE (id_lote_entrada, id_peca),
    FOREIGN KEY (id_lote_entrada) REFERENCES lote_entrada(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_peca) REFERENCES peca(id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE ordem_peca (
    id INTEGER PRIMARY KEY,
    id_ordem INTEGER NOT NULL,
    id_peca INTEGER NOT NULL,
    id_tecnico INTEGER NOT NULL,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    valor_unitario_centavos INTEGER NOT NULL CHECK (valor_unitario_centavos >= 0),
    data_saida TEXT NOT NULL DEFAULT (datetime('now')),
    FOREIGN KEY (id_ordem) REFERENCES ordem(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_peca) REFERENCES peca(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_tecnico) REFERENCES funcionario(id) ON DELETE RESTRICT
) STRICT;

CREATE TABLE saida_peca (
    id INTEGER PRIMARY KEY,
    id_peca INTEGER NOT NULL,
    id_tecnico INTEGER NOT NULL,
    quantidade INTEGER NOT NULL CHECK (quantidade > 0),
    valor_referencia_centavos INTEGER NOT NULL CHECK (valor_referencia_centavos >= 0),
    data_saida TEXT NOT NULL DEFAULT (datetime('now')),
    motivo TEXT NOT NULL DEFAULT 'Descarte por defeito/avaria'
        CHECK (motivo = 'Descarte por defeito/avaria'),
    observacao TEXT,
    FOREIGN KEY (id_peca) REFERENCES peca(id) ON DELETE RESTRICT,
    FOREIGN KEY (id_tecnico) REFERENCES funcionario(id) ON DELETE RESTRICT
) STRICT;

CREATE INDEX idx_equipamento_cliente ON equipamento(id_cliente);
CREATE INDEX idx_ordem_equipamento ON ordem(id_equipamento);
CREATE INDEX idx_ordem_tecnico ON ordem(id_tecnico);
CREATE INDEX idx_historico_status_ordem ON historico_status_os(id_ordem, data_hora);
CREATE INDEX idx_ordem_item_ordem ON ordem_servico_item(id_ordem);
CREATE INDEX idx_ordem_peca_ordem ON ordem_peca(id_ordem);
CREATE INDEX idx_movimento_peca ON lote_entrada_item(id_peca);

-- Dados fixos de domínio. IDs explícitos deixam a carga reproduzível, sem usá-los
-- como regra de autorização; as triggers consultam o nome do cargo/status.
INSERT INTO cargo (id, nome_cargo) VALUES
    (1, 'Gerente'), (2, 'Atendente'), (3, 'Técnico');

INSERT INTO status_os (id, nome_status) VALUES
    (1, 'Aberto'), (2, 'Em Diagnóstico'), (3, 'Orçamento Aprovado'),
    (4, 'Em Reparo'), (5, 'Pronto'), (6, 'Entregue'), (7, 'Cancelado');

INSERT INTO forma_pagamento (id, nome_forma_pagamento) VALUES
    (1, 'Dinheiro'), (2, 'PIX'), (3, 'Cartão de Crédito'),
    (4, 'Cartão de Débito'), (5, 'Transferência Bancária');

-- Valida papéis sem depender de IDs de cargo fixos.
CREATE TRIGGER trg_cliente_cadastro_papel
BEFORE INSERT ON cliente
WHEN NOT EXISTS (
    SELECT 1 FROM funcionario f JOIN cargo c ON c.id = f.id_cargo
    WHERE f.id = NEW.id_funcionario_cadastro
      AND c.nome_cargo IN ('Atendente', 'Gerente') AND f.status = 1
)
BEGIN SELECT RAISE(ABORT, 'Cadastro de cliente exige atendente ou gerente ativo'); END;

CREATE TRIGGER trg_equipamento_cadastro_papel
BEFORE INSERT ON equipamento
WHEN NOT EXISTS (
    SELECT 1 FROM funcionario f JOIN cargo c ON c.id = f.id_cargo
    WHERE f.id = NEW.id_funcionario_cadastro
      AND c.nome_cargo IN ('Atendente', 'Gerente') AND f.status = 1
)
BEGIN SELECT RAISE(ABORT, 'Cadastro de equipamento exige atendente ou gerente ativo'); END;

CREATE TRIGGER trg_categoria_servico_cadastro_gerente
BEFORE INSERT ON categoria_servico
WHEN NOT EXISTS (
    SELECT 1 FROM funcionario f JOIN cargo c ON c.id = f.id_cargo
    WHERE f.id = NEW.id_funcionario_cadastro AND c.nome_cargo = 'Gerente' AND f.status = 1
)
BEGIN SELECT RAISE(ABORT, 'Categoria de serviço exige gerente ativo'); END;

CREATE TRIGGER trg_servico_cadastro_gerente
BEFORE INSERT ON servico
WHEN NOT EXISTS (
    SELECT 1 FROM funcionario f JOIN cargo c ON c.id = f.id_cargo
    WHERE f.id = NEW.id_funcionario_cadastro AND c.nome_cargo = 'Gerente' AND f.status = 1
)
BEGIN SELECT RAISE(ABORT, 'Cadastro de serviço exige gerente ativo'); END;

CREATE TRIGGER trg_categoria_peca_cadastro_gerente
BEFORE INSERT ON categoria_peca
WHEN NOT EXISTS (
    SELECT 1 FROM funcionario f JOIN cargo c ON c.id = f.id_cargo
    WHERE f.id = NEW.id_funcionario_cadastro AND c.nome_cargo = 'Gerente' AND f.status = 1
)
BEGIN SELECT RAISE(ABORT, 'Categoria de peça exige gerente ativo'); END;

CREATE TRIGGER trg_peca_cadastro_gerente
BEFORE INSERT ON peca
WHEN NOT EXISTS (
    SELECT 1 FROM funcionario f JOIN cargo c ON c.id = f.id_cargo
    WHERE f.id = NEW.id_funcionario_cadastro AND c.nome_cargo = 'Gerente' AND f.status = 1
)
BEGIN SELECT RAISE(ABORT, 'Cadastro de peça exige gerente ativo'); END;

CREATE TRIGGER trg_lote_entrada_gerente
BEFORE INSERT ON lote_entrada
WHEN NOT EXISTS (
    SELECT 1 FROM funcionario f JOIN cargo c ON c.id = f.id_cargo
    WHERE f.id = NEW.id_gerente AND c.nome_cargo = 'Gerente' AND f.status = 1
)
BEGIN SELECT RAISE(ABORT, 'Entrada de peças exige gerente ativo'); END;

CREATE TRIGGER trg_ordem_papeis
BEFORE INSERT ON ordem
WHEN NOT EXISTS (
    SELECT 1 FROM funcionario f JOIN cargo c ON c.id = f.id_cargo
    WHERE f.id = NEW.id_funcionario_abertura
      AND c.nome_cargo IN ('Atendente', 'Gerente') AND f.status = 1
) OR NOT EXISTS (
    SELECT 1 FROM funcionario f JOIN cargo c ON c.id = f.id_cargo
    WHERE f.id = NEW.id_tecnico AND c.nome_cargo = 'Técnico' AND f.status = 1
) OR NOT EXISTS (
    SELECT 1 FROM status_os s WHERE s.id = NEW.id_status_os AND s.nome_status = 'Aberto'
)
BEGIN SELECT RAISE(ABORT, 'OS exige abertura por atendente/gerente, técnico ativo e status Aberto'); END;

CREATE TRIGGER trg_historico_status_responsavel
BEFORE INSERT ON historico_status_os
WHEN NOT EXISTS (
    SELECT 1 FROM funcionario f JOIN cargo c ON c.id = f.id_cargo
    WHERE f.id = NEW.id_funcionario AND f.status = 1
      AND c.nome_cargo IN ('Técnico', 'Atendente', 'Gerente')
)
BEGIN SELECT RAISE(ABORT, 'Mudança de status exige técnico, atendente ou gerente ativo'); END;

CREATE TRIGGER trg_ordem_registra_status_inicial
AFTER INSERT ON ordem
BEGIN
    INSERT INTO historico_status_os (id_ordem, id_status_os, id_funcionario)
    VALUES (NEW.id, NEW.id_status_os, NEW.id_funcionario_abertura);
END;

CREATE TRIGGER trg_historico_atualiza_status_ordem
AFTER INSERT ON historico_status_os
BEGIN
    UPDATE ordem SET id_status_os = NEW.id_status_os WHERE id = NEW.id_ordem;
END;

CREATE TRIGGER trg_ordem_status_somente_historico
BEFORE UPDATE OF id_status_os ON ordem
WHEN NEW.id_status_os <> OLD.id_status_os
 AND NEW.id_status_os <> COALESCE(
    (SELECT h.id_status_os FROM historico_status_os h
     WHERE h.id_ordem = OLD.id ORDER BY h.data_hora DESC, h.id DESC LIMIT 1),
    OLD.id_status_os
 )
BEGIN SELECT RAISE(ABORT, 'Altere status inserindo registro no historico_status_os'); END;

CREATE TRIGGER trg_ordem_total_coerente
BEFORE UPDATE OF valor_total_centavos ON ordem
WHEN NEW.valor_total_centavos <>
    COALESCE((SELECT SUM(i.quantidade * i.valor_unitario_centavos)
              FROM ordem_servico_item i WHERE i.id_ordem = OLD.id), 0) +
    COALESCE((SELECT SUM(p.quantidade * p.valor_unitario_centavos)
              FROM ordem_peca p WHERE p.id_ordem = OLD.id), 0)
BEGIN SELECT RAISE(ABORT, 'Total da OS deve corresponder aos itens registrados'); END;

CREATE TRIGGER trg_lote_item_atualiza_estoque
AFTER INSERT ON lote_entrada_item
BEGIN
    UPDATE peca
       SET estoque_atual = estoque_atual + NEW.quantidade,
           preco_venda_centavos = NEW.preco_sugerido_centavos
     WHERE id = NEW.id_peca;
END;

CREATE TRIGGER trg_lote_item_sem_edicao
BEFORE UPDATE ON lote_entrada_item
BEGIN SELECT RAISE(ABORT, 'Itens de lote registrados são imutáveis'); END;

CREATE TRIGGER trg_lote_item_sem_exclusao
BEFORE DELETE ON lote_entrada_item
BEGIN SELECT RAISE(ABORT, 'Itens de lote registrados são imutáveis'); END;

-- Serviço congelado na OS e total atualizado em inserção, alteração ou remoção.
CREATE TRIGGER trg_ordem_servico_item_aberta_insert
BEFORE INSERT ON ordem_servico_item
WHEN EXISTS (SELECT 1 FROM ordem o WHERE o.id = NEW.id_ordem AND o.data_fechamento IS NOT NULL)
BEGIN SELECT RAISE(ABORT, 'OS fechada não aceita novos serviços'); END;

CREATE TRIGGER trg_ordem_servico_item_total_insert
AFTER INSERT ON ordem_servico_item
BEGIN
    UPDATE ordem SET valor_total_centavos =
        COALESCE((SELECT SUM(i.quantidade * i.valor_unitario_centavos)
                  FROM ordem_servico_item i WHERE i.id_ordem = NEW.id_ordem), 0) +
        COALESCE((SELECT SUM(p.quantidade * p.valor_unitario_centavos)
                  FROM ordem_peca p WHERE p.id_ordem = NEW.id_ordem), 0)
    WHERE id = NEW.id_ordem;
END;

CREATE TRIGGER trg_ordem_servico_item_aberta_update
BEFORE UPDATE ON ordem_servico_item
WHEN EXISTS (SELECT 1 FROM ordem o WHERE o.id = OLD.id_ordem AND o.data_fechamento IS NOT NULL)
  OR EXISTS (SELECT 1 FROM ordem o WHERE o.id = NEW.id_ordem AND o.data_fechamento IS NOT NULL)
BEGIN SELECT RAISE(ABORT, 'OS fechada não aceita alteração de serviços'); END;

CREATE TRIGGER trg_ordem_servico_item_total_update
AFTER UPDATE ON ordem_servico_item
BEGIN
    UPDATE ordem SET valor_total_centavos =
        COALESCE((SELECT SUM(i.quantidade * i.valor_unitario_centavos)
                  FROM ordem_servico_item i WHERE i.id_ordem = OLD.id_ordem), 0) +
        COALESCE((SELECT SUM(p.quantidade * p.valor_unitario_centavos)
                  FROM ordem_peca p WHERE p.id_ordem = OLD.id_ordem), 0)
    WHERE id = OLD.id_ordem;
    UPDATE ordem SET valor_total_centavos =
        COALESCE((SELECT SUM(i.quantidade * i.valor_unitario_centavos)
                  FROM ordem_servico_item i WHERE i.id_ordem = NEW.id_ordem), 0) +
        COALESCE((SELECT SUM(p.quantidade * p.valor_unitario_centavos)
                  FROM ordem_peca p WHERE p.id_ordem = NEW.id_ordem), 0)
    WHERE id = NEW.id_ordem AND NEW.id_ordem <> OLD.id_ordem;
END;

CREATE TRIGGER trg_ordem_servico_item_aberta_delete
BEFORE DELETE ON ordem_servico_item
WHEN EXISTS (SELECT 1 FROM ordem o WHERE o.id = OLD.id_ordem AND o.data_fechamento IS NOT NULL)
BEGIN SELECT RAISE(ABORT, 'OS fechada não aceita remoção de serviços'); END;

CREATE TRIGGER trg_ordem_servico_item_total_delete
AFTER DELETE ON ordem_servico_item
BEGIN
    UPDATE ordem SET valor_total_centavos =
        COALESCE((SELECT SUM(i.quantidade * i.valor_unitario_centavos)
                  FROM ordem_servico_item i WHERE i.id_ordem = OLD.id_ordem), 0) +
        COALESCE((SELECT SUM(p.quantidade * p.valor_unitario_centavos)
                  FROM ordem_peca p WHERE p.id_ordem = OLD.id_ordem), 0)
    WHERE id = OLD.id_ordem;
END;

-- Uso de peças em OS: somente status aprovado/em reparo, técnico designado e saldo suficiente.
CREATE TRIGGER trg_ordem_peca_validacao_insert
BEFORE INSERT ON ordem_peca
WHEN NOT EXISTS (
    SELECT 1 FROM ordem o JOIN status_os s ON s.id = o.id_status_os
    JOIN funcionario f ON f.id = NEW.id_tecnico JOIN cargo c ON c.id = f.id_cargo
    WHERE o.id = NEW.id_ordem AND s.nome_status IN ('Orçamento Aprovado', 'Em Reparo')
      AND o.id_tecnico = NEW.id_tecnico AND c.nome_cargo = 'Técnico' AND f.status = 1
) OR NOT EXISTS (
    SELECT 1 FROM peca p WHERE p.id = NEW.id_peca AND p.estoque_atual >= NEW.quantidade
) OR EXISTS (
    SELECT 1 FROM ordem o WHERE o.id = NEW.id_ordem AND o.data_fechamento IS NOT NULL
)
BEGIN SELECT RAISE(ABORT, 'Uso de peça exige OS elegível, técnico designado e estoque suficiente'); END;

CREATE TRIGGER trg_ordem_peca_baixa_insert
AFTER INSERT ON ordem_peca
BEGIN
    UPDATE peca SET estoque_atual = estoque_atual - NEW.quantidade WHERE id = NEW.id_peca;
    UPDATE ordem SET valor_total_centavos =
        COALESCE((SELECT SUM(i.quantidade * i.valor_unitario_centavos)
                  FROM ordem_servico_item i WHERE i.id_ordem = NEW.id_ordem), 0) +
        COALESCE((SELECT SUM(p.quantidade * p.valor_unitario_centavos)
                  FROM ordem_peca p WHERE p.id_ordem = NEW.id_ordem), 0)
    WHERE id = NEW.id_ordem;
END;

CREATE TRIGGER trg_ordem_peca_validacao_update
BEFORE UPDATE ON ordem_peca
WHEN EXISTS (SELECT 1 FROM ordem o WHERE o.id = OLD.id_ordem AND o.data_fechamento IS NOT NULL)
 OR EXISTS (SELECT 1 FROM ordem o WHERE o.id = NEW.id_ordem AND o.data_fechamento IS NOT NULL)
 OR NOT EXISTS (
    SELECT 1 FROM ordem o JOIN status_os s ON s.id = o.id_status_os
    JOIN funcionario f ON f.id = NEW.id_tecnico JOIN cargo c ON c.id = f.id_cargo
    WHERE o.id = NEW.id_ordem AND s.nome_status IN ('Orçamento Aprovado', 'Em Reparo')
      AND o.id_tecnico = NEW.id_tecnico AND c.nome_cargo = 'Técnico' AND f.status = 1
 )
 OR NOT EXISTS (
    SELECT 1 FROM peca p WHERE p.id = NEW.id_peca AND
      p.estoque_atual + CASE WHEN NEW.id_peca = OLD.id_peca THEN OLD.quantidade ELSE 0 END >= NEW.quantidade
 )
BEGIN SELECT RAISE(ABORT, 'Alteração de peça inválida para OS, técnico ou estoque'); END;

CREATE TRIGGER trg_ordem_peca_baixa_update
AFTER UPDATE ON ordem_peca
BEGIN
    UPDATE peca SET estoque_atual = estoque_atual + OLD.quantidade WHERE id = OLD.id_peca;
    UPDATE peca SET estoque_atual = estoque_atual - NEW.quantidade WHERE id = NEW.id_peca;
    UPDATE ordem SET valor_total_centavos =
        COALESCE((SELECT SUM(i.quantidade * i.valor_unitario_centavos)
                  FROM ordem_servico_item i WHERE i.id_ordem = OLD.id_ordem), 0) +
        COALESCE((SELECT SUM(p.quantidade * p.valor_unitario_centavos)
                  FROM ordem_peca p WHERE p.id_ordem = OLD.id_ordem), 0)
    WHERE id = OLD.id_ordem;
    UPDATE ordem SET valor_total_centavos =
        COALESCE((SELECT SUM(i.quantidade * i.valor_unitario_centavos)
                  FROM ordem_servico_item i WHERE i.id_ordem = NEW.id_ordem), 0) +
        COALESCE((SELECT SUM(p.quantidade * p.valor_unitario_centavos)
                  FROM ordem_peca p WHERE p.id_ordem = NEW.id_ordem), 0)
    WHERE id = NEW.id_ordem AND NEW.id_ordem <> OLD.id_ordem;
END;

CREATE TRIGGER trg_ordem_peca_baixa_delete
AFTER DELETE ON ordem_peca
BEGIN
    UPDATE peca SET estoque_atual = estoque_atual + OLD.quantidade WHERE id = OLD.id_peca;
    UPDATE ordem SET valor_total_centavos =
        COALESCE((SELECT SUM(i.quantidade * i.valor_unitario_centavos)
                  FROM ordem_servico_item i WHERE i.id_ordem = OLD.id_ordem), 0) +
        COALESCE((SELECT SUM(p.quantidade * p.valor_unitario_centavos)
                  FROM ordem_peca p WHERE p.id_ordem = OLD.id_ordem), 0)
    WHERE id = OLD.id_ordem;
END;

CREATE TRIGGER trg_saida_peca_validacao
BEFORE INSERT ON saida_peca
WHEN NOT EXISTS (
    SELECT 1 FROM peca p WHERE p.id = NEW.id_peca AND p.estoque_atual >= NEW.quantidade
) OR NOT EXISTS (
    SELECT 1 FROM funcionario f JOIN cargo c ON c.id = f.id_cargo
    WHERE f.id = NEW.id_tecnico AND c.nome_cargo = 'Técnico' AND f.status = 1
)
BEGIN SELECT RAISE(ABORT, 'Descarte exige técnico ativo e estoque suficiente'); END;

CREATE TRIGGER trg_saida_peca_baixa
AFTER INSERT ON saida_peca
BEGIN
    UPDATE peca SET estoque_atual = estoque_atual - NEW.quantidade WHERE id = NEW.id_peca;
END;

CREATE TRIGGER trg_saida_peca_sem_edicao
BEFORE UPDATE ON saida_peca
BEGIN SELECT RAISE(ABORT, 'Saída registrada é imutável; faça ajuste auditado'); END;

CREATE TRIGGER trg_saida_peca_sem_exclusao
BEFORE DELETE ON saida_peca
BEGIN SELECT RAISE(ABORT, 'Saída registrada é imutável; faça ajuste auditado'); END;
