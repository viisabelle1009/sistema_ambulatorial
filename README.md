# Sistema Ambulatorial

## Descrição

Este projeto consiste no desenvolvimento de um sistema ambulatorial com foco na gestão de atendimentos médicos, incluindo controle de pacientes, agendamentos, consultas e exames.

O sistema tem como objetivo organizar o fluxo operacional de atendimento, garantindo consistência dos dados, integridade referencial e suporte à tomada de decisão orientada por dados.

---

## Arquitetura do Projeto

O sistema está estruturado em três camadas principais:

- Banco de Dados (MySQL) → responsável pela persistência e integridade dos dados  
- API (Python com FastAPI) → responsável pelas regras de negócio e validações  
- Frontend (HTML, CSS e Bootstrap) → interface de interação com o usuário  

---

## Tecnologias Utilizadas

- MySQL  
- SQL  
- Python (FastAPI) *(em desenvolvimento)*  
- Power BI *(futuro uso para análise de dados)*  

---

## Estrutura do Banco de Dados

O banco foi modelado com foco em:

- Integridade referencial (chaves estrangeiras)  
- Constraints para controle de dados  
- Índices para otimização de consultas  
- Padronização de nomenclatura  

### Principais entidades:

- Pacientes  
- Médicos  
- Especialidades  
- Usuários  
- Perfis  
- Agenda Médica  
- Agendamentos  
- Consultas  
- Exames  
- Tipos de Exame  
- Histórico de Faltas  
- Alertas  
- Log de Ações  

---

## Regras de Negócio

As regras de negócio são implementadas na API (Python com FastAPI), garantindo flexibilidade e controle das validações.

Principais regras:

- O primeiro agendamento do paciente deve ser do tipo consulta  
- Se tipo = consulta → id_medico obrigatório  
- Se tipo = exame → id_tipo_exame obrigatório  
- Controle de faltas com bloqueio após 3 ocorrências consecutivas  
- Cancelamento com antecedência mínima de 24 horas  
- Registro de auditoria das ações realizadas  

---

## Status do Projeto

- Banco de dados: concluído  
- DER: concluído  
- Povoamento e testes: concluído  
- API: em desenvolvimento  
- Frontend: planejado  

---

## Objetivo do Projeto

Além da funcionalidade operacional, o projeto serve como base prática de aprendizado em tecnologia, sendo desenvolvido de forma autodidata com foco na consolidação de conhecimentos e evolução profissional.

---

## Próximos Passos

- Desenvolvimento da API com FastAPI  
- Implementação das regras de negócio  
- Criação de endpoints  
- Integração com frontend  
- Análise de dados com Power BI  

---

## Autor

Vitória Isabelle da Silva Barbosa
