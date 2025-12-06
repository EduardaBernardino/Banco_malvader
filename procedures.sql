
-- 0) Database
CREATE DATABASE IF NOT EXISTS banco_malvader
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;
USE banco_malvader;

-- 1) Tabelas (ordem de criação respeitando FKs)

-- 1.1 usuario
CREATE TABLE IF NOT EXISTS usuario (
  id_usuario INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  cpf VARCHAR(11) NOT NULL UNIQUE,
  data_nascimento DATE NOT NULL,
  telefone VARCHAR(15) NOT NULL,
  tipo_usuario ENUM('FUNCIONARIO','CLIENTE') NOT NULL,
  senha_hash CHAR(32) NOT NULL
);

-- 1.2 endereco_usuario (endereço de usuário)
CREATE TABLE IF NOT EXISTS endereco_usuario (
  id_endereco INT PRIMARY KEY AUTO_INCREMENT,
  id_usuario INT NOT NULL,
  cep VARCHAR(10) NOT NULL,
  local VARCHAR(100) NOT NULL,
  numero_casa INT NOT NULL,
  bairro VARCHAR(50) NOT NULL,
  cidade VARCHAR(50) NOT NULL,
  estado CHAR(2) NOT NULL,
  complemento VARCHAR(50),
  CONSTRAINT fk_endereco_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
  INDEX (cep)
);

-- 1.3 endereco_agencia (endereço de agência)
CREATE TABLE IF NOT EXISTS endereco_agencia (
  id_endereco_agencia INT PRIMARY KEY AUTO_INCREMENT,
  cep VARCHAR(10) NOT NULL,
  local VARCHAR(100) NOT NULL,
  numero INT NOT NULL,
  bairro VARCHAR(50) NOT NULL,
  cidade VARCHAR(50) NOT NULL,
  estado CHAR(2) NOT NULL,
  complemento VARCHAR(50)
);

-- 1.4 agencia
CREATE TABLE IF NOT EXISTS agencia (
  id_agencia INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(50) NOT NULL,
  codigo_agencia VARCHAR(10) NOT NULL UNIQUE,
  endereco_id INT NOT NULL,
  CONSTRAINT fk_agencia_endereco FOREIGN KEY (endereco_id) REFERENCES endereco_agencia(id_endereco_agencia)
);

-- 1.5 funcionario
CREATE TABLE IF NOT EXISTS funcionario (
  id_funcionario INT PRIMARY KEY AUTO_INCREMENT,
  id_usuario INT NOT NULL,
  id_agencia INT NOT NULL,
  codigo_funcionario VARCHAR(20) NOT NULL UNIQUE,
  cargo ENUM('ESTAGIARIO','ATENDENTE','GERENTE') NOT NULL,
  id_supervisor INT NULL,
  CONSTRAINT fk_funcionario_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
  CONSTRAINT fk_funcionario_agencia FOREIGN KEY (id_agencia) REFERENCES agencia(id_agencia),
  CONSTRAINT fk_funcionario_supervisor FOREIGN KEY (id_supervisor) REFERENCES funcionario(id_funcionario)
);

-- 1.6 cliente
CREATE TABLE IF NOT EXISTS cliente (
  id_cliente INT PRIMARY KEY AUTO_INCREMENT,
  id_usuario INT NOT NULL,
  score_credito DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  CONSTRAINT fk_cliente_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

-- 1.7 conta
CREATE TABLE IF NOT EXISTS conta (
  id_conta INT PRIMARY KEY AUTO_INCREMENT,
  numero_conta VARCHAR(20) NOT NULL UNIQUE,  -- com dígito verificador
  id_agencia INT NOT NULL,
  saldo DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  tipo_conta ENUM('POUPANCA','CORRENTE','INVESTIMENTO') NOT NULL,
  id_cliente INT NOT NULL,
  data_abertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status ENUM('ATIVA','ENCERRADA','BLOQUEADA') NOT NULL DEFAULT 'ATIVA',
  CONSTRAINT fk_conta_agencia FOREIGN KEY (id_agencia) REFERENCES agencia(id_agencia),
  CONSTRAINT fk_conta_cliente FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
  INDEX idx_conta_numero (numero_conta)
);

-- 1.8 conta_poupanca
CREATE TABLE IF NOT EXISTS conta_poupanca (
  id_conta_poupanca INT PRIMARY KEY AUTO_INCREMENT,
  id_conta INT NOT NULL UNIQUE,
  taxa_rendimento DECIMAL(5,2) NOT NULL,
  ultimo_rendimento DATETIME NULL,
  CONSTRAINT fk_cp_conta FOREIGN KEY (id_conta) REFERENCES conta(id_conta)
);

-- 1.9 conta_corrente
CREATE TABLE IF NOT EXISTS conta_corrente (
  id_conta_corrente INT PRIMARY KEY AUTO_INCREMENT,
  id_conta INT NOT NULL UNIQUE,
  limite DECIMAL(15,2) NOT NULL DEFAULT 0.00,
  data_vencimento DATE NOT NULL,
  taxa_manutencao DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  CONSTRAINT fk_cc_conta FOREIGN KEY (id_conta) REFERENCES conta(id_conta)
);

-- 1.10 conta_investimento
CREATE TABLE IF NOT EXISTS conta_investimento (
  id_conta_investimento INT PRIMARY KEY AUTO_INCREMENT,
  id_conta INT NOT NULL UNIQUE,
  perfil_risco ENUM('BAIXO','MEDIO','ALTO') NOT NULL,
  valor_minimo DECIMAL(15,2) NOT NULL,
  taxa_rendimento_base DECIMAL(5,2) NOT NULL,
  CONSTRAINT fk_ci_conta FOREIGN KEY (id_conta) REFERENCES conta(id_conta)
);

-- 1.11 transacao
-- Para DEPOSITO: origem NULL, destino obrigatório
-- Para SAQUE: origem obrigatório, destino NULL
-- Para TRANSFERENCIA: origem e destino obrigatórios
-- Para TAXA: origem obrigatório
-- Para RENDIMENTO: destino obrigatório
CREATE TABLE IF NOT EXISTS transacao (
  id_transacao INT PRIMARY KEY AUTO_INCREMENT,
  id_conta_origem INT NULL,
  id_conta_destino INT NULL,
  tipo_transacao ENUM('DEPOSITO','SAQUE','TRANSFERENCIA','TAXA','RENDIMENTO') NOT NULL,
  valor DECIMAL(15,2) NOT NULL,
  data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  descricao VARCHAR(100),
  CONSTRAINT fk_tx_origem FOREIGN KEY (id_conta_origem) REFERENCES conta(id_conta),
  CONSTRAINT fk_tx_destino FOREIGN KEY (id_conta_destino) REFERENCES conta(id_conta),
  INDEX idx_tx_data (data_hora)
);

-- 1.12 relatorio
CREATE TABLE IF NOT EXISTS relatorio (
  id_relatorio INT PRIMARY KEY AUTO_INCREMENT,
  id_funcionario INT NOT NULL,
  tipo_relatorio VARCHAR(50) NOT NULL,
  data_geracao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  conteudo JSON NOT NULL,
  CONSTRAINT fk_rel_funcionario FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario)
);



--Tabelas de auditoria e histórico 
CREATE TABLE auditoria_abertura_conta (
  id_auditoria INT PRIMARY KEY AUTO_INCREMENT,
  id_conta INT NOT NULL,
  id_funcionario INT NULL,
  data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  observacao VARCHAR(200),
  CONSTRAINT fk_aud_conta FOREIGN KEY (id_conta) REFERENCES conta(id_conta),
  CONSTRAINT fk_aud_func FOREIGN KEY (id_funcionario) REFERENCES funcionario(id_funcionario)
);

CREATE TABLE historico_encerramento (
  id_hist INT PRIMARY KEY AUTO_INCREMENT,
  id_conta INT NOT NULL,
  motivo VARCHAR(200) NOT NULL,
  data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_hist_conta FOREIGN KEY (id_conta) REFERENCES conta(id_conta)
);


--2. Função para dígito verificador e geração do número da conta
CREATE FUNCTION luhn_check_digit(num_base VARCHAR(19))
RETURNS CHAR(1)
DETERMINISTIC
BEGIN
  DECLARE i INT DEFAULT 1;
  DECLARE soma INT DEFAULT 0;
  DECLARE c CHAR(1);
  DECLARE n INT;
  DECLARE len INT;

  SET len = CHAR_LENGTH(num_base);
  WHILE i <= len DO
    SET c = SUBSTRING(num_base, len - i + 1, 1);
    SET n = CAST(c AS UNSIGNED);
    IF MOD(i, 2) = 1 THEN
      SET soma = soma + n;
    ELSE
      SET n = n * 2;
      IF n > 9 THEN SET n = n - 9; END IF;
      SET soma = soma + n;
    END IF;
    SET i = i + 1;
  END WHILE;
  RETURN CHAR((10 - (soma MOD 10)) MOD 10 + 48);
END$$


--Função para gerar número da conta com dígito:
CREATE FUNCTION gerar_numero_conta(idAg INT, idCli INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
  DECLARE base VARCHAR(19);
  DECLARE dv CHAR(1);
  -- Exemplo de base: AAA CCC NNNN, onde A é agência, C é cliente, N é sequência por AUTO_INCREMENT da conta
  -- Para simplificar, combinamos agência, cliente e UNIX_TIMESTAMP parcial
  SET base = LPAD(idAg, 3, '0') || LPAD(idCli, 5, '0') || DATE_FORMAT(NOW(), '%y%m%d%H%i');
  SET dv = luhn_check_digit(base);
  RETURN CONCAT(base, dv);
END$$

DELIMITER ;

--Gatilho que preenche numero_conta se vier vazio:
DELIMITER $$

CREATE TRIGGER conta_before_insert
BEFORE INSERT ON conta
FOR EACH ROW
BEGIN
  IF NEW.numero_conta IS NULL OR NEW.numero_conta = '' THEN
    SET NEW.numero_conta = gerar_numero_conta(NEW.id_agencia, NEW.id_cliente);
  END IF;
END$$

DELIMITER ;



---4.	Política de senha sem bloquear atualizações legítimas
DELIMITER $$

CREATE PROCEDURE alterar_senha_usuario(IN p_id_usuario INT, IN p_senha_clara VARCHAR(255))
BEGIN
  DECLARE v_maiuscula TINYINT DEFAULT 0;
  DECLARE v_digito TINYINT DEFAULT 0;
  DECLARE v_especial TINYINT DEFAULT 0;
  DECLARE i INT DEFAULT 1;
  DECLARE ch CHAR(1);
  DECLARE len INT;

  SET len = CHAR_LENGTH(p_senha_clara);
  IF len < 8 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Senha muito curta, mínimo de 8 caracteres';
  END IF;

  WHILE i <= len DO
    SET ch = SUBSTRING(p_senha_clara, i, 1);
    IF ch REGEXP '[A-Z]' THEN SET v_maiuscula = 1; END IF;
    IF ch REGEXP '[0-9]' THEN SET v_digito = 1; END IF;
    IF ch REGEXP '[^a-zA-Z0-9]' THEN SET v_especial = 1; END IF;
    SET i = i + 1;
  END WHILE;

  IF v_maiuscula = 0 OR v_digito = 0 OR v_especial = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Senha fraca, inclua maiúscula, dígito e caractere especial';
  END IF;

  SET @allow_password_update = 1;
  UPDATE usuario
     SET senha_hash = MD5(p_senha_clara)
   WHERE id_usuario = p_id_usuario;
  SET @allow_password_update = NULL;
END$$

DELIMITER ;


---Trigger para bloquear updates diretos de senha_hash:
DELIMITER $$

CREATE TRIGGER usuario_before_update
BEFORE UPDATE ON usuario
FOR EACH ROW
BEGIN
  IF NEW.senha_hash <> OLD.senha_hash THEN
    IF @allow_password_update IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Atualize a senha via procedure alterar_senha_usuario';
    END IF;
  END IF;
END$$

DELIMITER ;




--5.	Regras de transação e atualização de saldo:
DELIMITER $$

CREATE TRIGGER atualizar_saldo_after_insert
AFTER INSERT ON transacao
FOR EACH ROW
BEGIN
  CASE NEW.tipo_transacao
    WHEN 'DEPOSITO' THEN
      IF NEW.id_conta_destino IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Depósito exige conta destino';
      END IF;
      UPDATE conta SET saldo = saldo + NEW.valor WHERE id_conta = NEW.id_conta_destino;
    WHEN 'SAQUE' THEN
      IF NEW.id_conta_origem IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saque exige conta origem';
      END IF;
      UPDATE conta SET saldo = saldo - NEW.valor WHERE id_conta = NEW.id_conta_origem;
    WHEN 'TRANSFERENCIA' THEN
      IF NEW.id_conta_origem IS NULL OR NEW.id_conta_destino IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transferência exige contas de origem e destino';
      END IF;
      UPDATE conta SET saldo = saldo - NEW.valor WHERE id_conta = NEW.id_conta_origem;
      UPDATE conta SET saldo = saldo + NEW.valor WHERE id_conta = NEW.id_conta_destino;
    WHEN 'TAXA' THEN
      IF NEW.id_conta_origem IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Taxa exige conta origem';
      END IF;
      UPDATE conta SET saldo = saldo - NEW.valor WHERE id_conta = NEW.id_conta_origem;
    WHEN 'RENDIMENTO' THEN
      IF NEW.id_conta_destino IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rendimento exige conta destino';
      END IF;
      UPDATE conta SET saldo = saldo + NEW.valor WHERE id_conta = NEW.id_conta_destino;
  END CASE;
END$$

DELIMITER ;



--6 Limite diário de depósito por cliente:
DELIMITER $$

CREATE TRIGGER limite_deposito_before_insert
BEFORE INSERT ON transacao
FOR EACH ROW
BEGIN
  DECLARE v_id_cliente INT;
  DECLARE v_total_dia DECIMAL(15,2);

  IF NEW.tipo_transacao = 'DEPOSITO' THEN
    IF NEW.id_conta_destino IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Depósito exige conta destino';
    END IF;

    SELECT c.id_cliente
      INTO v_id_cliente
      FROM conta c
     WHERE c.id_conta = NEW.id_conta_destino;

    SELECT IFNULL(SUM(t.valor),0.00)
      INTO v_total_dia
      FROM transacao t
      JOIN conta cd ON cd.id_conta = t.id_conta_destino
     WHERE t.tipo_transacao = 'DEPOSITO'
       AND cd.id_cliente = v_id_cliente
       AND DATE(t.data_hora) = CURDATE();

    IF v_total_dia + NEW.valor > 10000.00 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Limite diário de depósito excedido';
    END IF;
  END IF;
END$$

DELIMITER ;



--7	Procedure de cálculo de score de crédito
DELIMITER $$

CREATE PROCEDURE calcular_score_credito(IN p_id_cliente INT)
BEGIN
  DECLARE v_total DECIMAL(15,2);
  DECLARE v_media DECIMAL(15,2);

  SELECT IFNULL(SUM(t.valor),0.00), IFNULL(AVG(t.valor),0.00)
    INTO v_total, v_media
    FROM transacao t
    JOIN conta c ON t.id_conta_origem = c.id_conta
   WHERE c.id_cliente = p_id_cliente
     AND t.tipo_transacao IN ('DEPOSITO','SAQUE');

  UPDATE cliente
     SET score_credito = LEAST(100.00, (v_total / 1000.00) + (v_media / 100.00))
   WHERE cliente.id_cliente = p_id_cliente;
END$$

DELIMITER ;


--8	Procedure de encerramento de conta com validações e histórico
DELIMITER $$

CREATE PROCEDURE encerrar_conta(IN p_id_conta INT, IN p_motivo VARCHAR(200))
BEGIN
  DECLARE v_saldo DECIMAL(15,2);
  DECLARE v_status ENUM('ATIVA','ENCERRADA','BLOQUEADA');

  SELECT saldo, status INTO v_saldo, v_status FROM conta WHERE id_conta = p_id_conta FOR UPDATE;

  IF v_status <> 'ATIVA' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Apenas contas ativas podem ser encerradas';
  END IF;

  IF v_saldo <> 0.00 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é possível encerrar conta com saldo diferente de zero';
  END IF;

  UPDATE conta SET status = 'ENCERRADA' WHERE id_conta = p_id_conta;

  INSERT INTO historico_encerramento(id_conta, motivo) VALUES (p_id_conta, p_motivo);
END$$

DELIMITER ;


--9.	Auditoria de abertura de conta
DELIMITER $$

CREATE TRIGGER auditoria_abertura_conta_after_insert
AFTER INSERT ON conta
FOR EACH ROW
BEGIN
  -- Se a aplicação definir @current_funcionario_id na sessão, registramos
  INSERT INTO auditoria_abertura_conta(id_conta, id_funcionario, observacao)
  VALUES (NEW.id_conta, @current_funcionario_id, 'Abertura de conta');
END$$

DELIMITER ;



---10 - Views
--Resumo de contas por cliente
CREATE OR REPLACE VIEW vw_resumo_contas AS
SELECT cl.id_cliente,
       u.nome,
       COUNT(co.id_conta) AS total_contas,
       SUM(co.saldo) AS saldo_total
  FROM cliente cl
  JOIN usuario u   ON cl.id_usuario = u.id_usuario
  JOIN conta  co   ON cl.id_cliente = co.id_cliente
 GROUP BY cl.id_cliente, u.nome;


 -- Movimentações recentes dos últimos 90 dias
 CREATE OR REPLACE VIEW vw_movimentacoes_recentes AS
SELECT t.id_transacao,
       t.tipo_transacao,
       t.valor,
       t.data_hora,
       co.numero_conta AS conta_origem,
       cd.numero_conta AS conta_destino,
       u.nome AS cliente_origem
  FROM transacao t
  LEFT JOIN conta co ON t.id_conta_origem = co.id_conta
  LEFT JOIN conta cd ON t.id_conta_destino = cd.id_conta
  LEFT JOIN cliente cl ON co.id_cliente = cl.id_cliente
  LEFT JOIN usuario u ON cl.id_usuario = u.id_usuario
 WHERE t.data_hora >= NOW() - INTERVAL 90 DAY;


 --11.	Índices recomendados
 CREATE INDEX idx_conta_cliente ON conta(id_cliente);
CREATE INDEX idx_tx_tipo_data ON transacao(tipo_transacao, data_hora);
CREATE INDEX idx_usuario_cpf ON usuario(cpf);
CREATE INDEX idx_funcionario_agencia ON funcionario(id_agencia);

 
--12.	Regras opcionais de integridade para tipos de transação
DELIMITER $$

CREATE TRIGGER transacao_rules_before_insert
BEFORE INSERT ON transacao
FOR EACH ROW
BEGIN
  CASE NEW.tipo_transacao
    WHEN 'DEPOSITO' THEN
      IF NEW.id_conta_destino IS NULL OR NEW.id_conta_origem IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Depósito exige apenas conta destino';
      END IF;
    WHEN 'SAQUE' THEN
      IF NEW.id_conta_origem IS NULL OR NEW.id_conta_destino IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Saque exige apenas conta origem';
      END IF;
    WHEN 'TRANSFERENCIA' THEN
      IF NEW.id_conta_origem IS NULL OR NEW.id_conta_destino IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transferência exige origem e destino';
      END IF;
    WHEN 'TAXA' THEN
      IF NEW.id_conta_origem IS NULL OR NEW.id_conta_destino IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Taxa exige apenas conta origem';
      END IF;
    WHEN 'RENDIMENTO' THEN
      IF NEW.id_conta_destino IS NULL OR NEW.id_conta_origem IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Rendimento exige apenas conta destino';
      END IF;
  END CASE;
END$$

DELIMITER ;




--1.Atualização de Saldo: Após cada transação (INSERT em transacao), atualizar o saldo da conta correspondente.--
DELIMITER $$
CREATE TRIGGER atualizar_saldo AFTER INSERT ON transacao
FOR EACH ROW
BEGIN
    IF NEW.tipo_transacao = 'DEPOSITO' THEN
        UPDATE conta SET saldo = saldo + NEW.valor WHERE id_conta = NEW.id_conta_origem;
    ELSEIF NEW.tipo_transacao IN ('SAQUE', 'TAXA') THEN
        UPDATE conta SET saldo = saldo - NEW.valor WHERE id_conta = NEW.id_conta_origem;
    ELSEIF NEW.tipo_transacao = 'TRANSFERENCIA' THEN
        UPDATE conta SET saldo = saldo - NEW.valor WHERE id_conta = NEW.id_conta_origem;
        UPDATE conta SET saldo = saldo + NEW.valor WHERE id_conta = NEW.id_conta_destino;
    END IF;
END $$
DELIMITER ;


--2.	Validação de Senha Forte: Antes de atualizar senha_hash em usuario, verificar se a senha tem pelo menos 8 caracteres, 1 letra maiúscula, 1 número e 1 caractere especial.
DELIMITER $$
CREATE TRIGGER validar_senha BEFORE UPDATE ON usuario
FOR EACH ROW
BEGIN
    IF NEW.senha_hash REGEXP '^[0-9a-f]{32}$' THEN -- Assume MD5
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Senha deve ser atualizada via procedure com validação';
    END IF;
END $$
DELIMITER ;


--3.	Limite de Depósito Diário: Bloquear depósitos acima de R$10.000 por dia por cliente.
DELIMITER $$
CREATE TRIGGER limite_deposito BEFORE INSERT ON transacao
FOR EACH ROW
BEGIN
    DECLARE total_dia DECIMAL(15,2);
    SELECT SUM(valor) INTO total_dia
    FROM transacao
    WHERE id_conta_origem = NEW.id_conta_origem
      AND tipo_transacao = 'DEPOSITO'
      AND DATE(data_hora) = DATE(NEW.data_hora);
    IF (total_dia + NEW.valor) > 10000 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Limite diário de depósito excedido';
    END IF;
END $$
DELIMITER ;


--Stored Procedures--
--1.	Calcular Score de Crédito: Atualiza o score do cliente com base no histórico de transações.--
DELIMITER $$
CREATE PROCEDURE calcular_score_credito(IN id_cliente INT)
BEGIN
    DECLARE total_trans DECIMAL(15,2);
    DECLARE media_trans DECIMAL(15,2);
    SELECT SUM(valor), AVG(valor) INTO total_trans, media_trans
    FROM transacao t
    JOIN conta c ON t.id_conta_origem = c.id_conta
    WHERE c.id_cliente = id_cliente AND t.tipo_transacao IN ('DEPOSITO', 'SAQUE');
    UPDATE cliente SET score_credito = LEAST(100, (total_trans / 1000) + (media_trans / 100))
    WHERE id_cliente = id_cliente;
END $$
DELIMITER ;
Visões (Views)


---1.	Resumo de Contas por Cliente:
CREATE VIEW vw_resumo_contas AS
SELECT c.id_cliente, u.nome, COUNT(co.id_conta) AS total_contas, SUM(co.saldo) AS saldo_total
FROM cliente c
JOIN usuario u ON c.id_usuario = u.id_usuario
JOIN conta co ON c.id_cliente = co.id_cliente
GROUP BY c.id_cliente, u.nome;


--2 - Movimentações Recentes:
CREATE VIEW vw_movimentacoes_recentes AS
SELECT t.*, c.numero_conta, u.nome AS cliente
FROM transacao t
JOIN conta c ON t.id_conta_origem = c.id_conta
JOIN cliente cl ON c.id_cliente = cl.id_cliente
JOIN usuario u ON cl.id_usuario = u.id_usuario
WHERE t.data_hora >= NOW() - INTERVAL 90 DAY;
