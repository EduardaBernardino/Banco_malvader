Contribuição: Eduarda de Oliveira Bernardino, Pedro Henrique Fernandes, Matheus Martins Rios e Thiago Litiery Campelo Moreira


### 🏦 Banco Malvader

Sistema completo de gerenciamento bancário — Back-end, Front-end e Banco de Dados

## 📌 1) Descrição do Projeto

O Banco Malvader é um sistema bancário completo, desenvolvido com foco em arquitetura organizada, boas práticas de programação e modelagem profissional de banco de dados.
O projeto foi dividido entre Back-end, Front-end e Modelagem de Banco, resultando em uma solução funcional, robusta e realista.

## 🔧 O sistema permite:

Cadastro e gestão de usuários, clientes e funcionários

Cadastro de agências e endereços

Abertura, auditoria, acompanhamento e encerramento de contas

Movimentações como depósitos, saques, transferências, taxas e rendimentos

Relatórios internos e dashboards de indicadores

Registro automático de ações por auditoria e histórico

Automação de lógica de negócio via procedures, triggers, views e functions

Armazenamento seguro e estruturado em MySQL

O objetivo central é demonstrar um sistema bancário completo, integrando regras de negócio, modelagem ER e programação aplicada.

## 🚀 2) Tecnologias Utilizadas
🔹 2.1 Back-End

Java

Spring Boot

MySQL Connector

🔹 2.2 Front-End

HTML / CSS

Thymeleaf

Arquitetura baseada em Controllers + Views

🔹 2.3 Banco de Dados

MySQL Workbench

Modelagem ER completa

Stored Procedures

Views

Triggers

🔹 2.4 Ferramentas Complementares

Git e GitHub

## 📦 3) Pré-requisitos

Para executar o sistema, é necessário:

Java instalado

MySQL Server e MySQL Workbench

Banco de dados criado previamente utilizando o script fornecido

## 🗄 4) Configuração do Banco de Dados

O script SQL do projeto foi desenvolvido com foco em integridade, segurança e automação de regras internas.

🔹 4.1 Integridade Referencial

Primary Keys e Foreign Keys estruturadas

Políticas de ON UPDATE/DELETE restritivas

Índices otimizados para pesquisa

🔹 4.2 Triggers de Regras de Negócio

Alguns exemplos implementados:

Limite de depósito diário

Atualização automática de saldo

Auditoria na abertura de conta

Proibição de alteração direta de senha sem procedure

Limite máximo de funcionários por agência

🔹 4.3 Stored Procedures

Alteração de senha com validação

Cálculo de score de crédito

Encerramento de conta com regras automáticas

Aplicação de taxas por saques excessivos

🔹 4.4 Funções Internas

Algoritmo de Luhn (geração de números válidos)

Gerador de conta bancária

🔹 4.5 Views

Resumo de contas por cliente

Movimentações dos últimos 90 dias

## 🧩 5) Funcionalidades do Sistema
🔹 5.1 Autenticação

Login de clientes e funcionários

Senhas armazenadas com hash MD5

Validação via stored procedure

🔹 5.2 Usuários e Funcionários

Cadastro e atualização

Associação a agências específicas

Hierarquia com supervisores e subordinados

🔹 5.3 Clientes

Score gerado automaticamente

Relação com contas

Endereços vinculados

🔹 5.4 Contas Bancárias

Tipos suportados:

Corrente

Poupança

Investimento

Funcionalidades:

Número gerado automaticamente

Status: ativa, bloqueada, encerrada

🔹 5.5 Movimentações Bancárias

Depósito

Saque

Transferência

Rendimentos

Taxas automáticas

Regras garantidas por triggers:

Limite de depósito diário

Consistência origem/destino

Atualização automática do saldo

🔹 5.6 Relatórios Internos

Movimentações dos últimos 90 dias

Resumo de contas

Auditoria de abertura

Histórico de encerramento

🔹 5.7 Dashboard

Indicadores do banco

Dados agregados

Visão estratégica para gerentes

🔹 5.8 Interface Gráfica (Front-end)

Tela de Login

Dashboard inicial

Página de Clientes

Página de Funcionários

Transações

Relatórios

Configurações

## 🏁 Conclusão

O Banco Malvader é um sistema bancário completo, construído com:

Arquitetura robusta e modular

Banco de dados profissional e seguro

Modelagem ER estruturada

Regras de negócio implementadas diretamente no MySQL

Integração entre Back-end, Front-end e Banco de Dados
