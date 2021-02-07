# AIBM-Urgencias

Projeto sobre a Casuística do Serviço de Urgência de um hospital nacional, para a Unidade Curricular de Aplicações Informáticas na Biomedicina.

## Datasets utilizados

* Urgency_Episodes - Dados sobre os episódios de Urgência 
* Urgency_Prescriptions - Prescrições realizadas para cada episódio de Urgência
* Urgency_Exams - Exames realizados durante um episódio de Urgência
* ICD-9_Hierarchy - Códigos de Diagnóstico e respetivas descrições, segundo o sistema de nomenclatura ICD-9

### Notas adicionais

```
Novo schema criado para import -> dados

| Ficheiro             | Informação                                                                           | 
| ---------------------|:------------------------------------------------------------------------------------:|
| change.py            | Correção das datas de nascimento                                                     |
| noNullID.py          | Correção dos valores nulos dos ficheiros csv                                         |
| Povoamento.sql       | Povoamento inicial do Data Warehouse                                                 |
| retencao.sql         | Criação do schema para a área de retenção e respetivas relações                      |
| queries_retencao.sql | Tratamento dos dados e inserção na área de retenção                                  |
| toCSV.sql            | Migração dos dados da área de retenção para ficheiros csv                            |
| retencaoToDW.sql     | Atualização do Data Warehouse com os dados da área de retenção                       | 
| updateDW.sql         | Script para atualização do Data Warehouse e eliminação dos dados da área de retenção |

```

## Entrega do Projeto

7 de janeiro de 2021
