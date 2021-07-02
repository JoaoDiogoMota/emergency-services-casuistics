# Emergency Services Casuistics of a National Hospital - Computer Applications in Biomedicine

In this project, we intend to develop a **data warehousing** system, as well as a **business ingelligence** system to support clinical decisions ([Technical report](https://github.com/13caroline/emergency-services-casuistics/blob/main/Relatorio.pdf)).

Analysis, planning and implementation work was carried out based on the dataset provided. Subsequently, an initial settlement system was develop, as well as the necessary structures to update it in an incremental and differential way. Finally, the business intelligence system was developed on the [Tableau Desktop Platform](https://www.tableau.com/).

## Datasets

* Urgency_Episodes: Urgency episodes data
* Urgency_Prescriptions: Prescriptions made for each emergency episode
* Urgency_Exams: Exams performed during an emergency episode
* ICD-9_Hierarchy: Diagnostic codes and their descriptions, according to the ICD-9 nomenclature system

## Aditional information

```
New schema for import -> dados
```

| File             | Info                                                                           | 
| ---------------------|--------------------------------------------------------------------------------------|
| change.py            | Correction of birth dates                                                    |
| noNullID.py          | Correction of null values in csv files|
| Povoamento.sql       | Initial population of the data warehouse                                                |
| retencao.sql         | Schema creation for the retention area and its relationships |
| queries_retencao.sql | Data processing and insertion in the retention area                                  |
| toCSV.sql            | Data migration from retention area to csv files                           |
| retencaoToDW.sql     | Updating the data warehouse with data from the retention area                       | 
| updateDW.sql         | Script for updating the data warehouse and deleting data from the retention area |

## Collaborators

| Name            	|
|-----------------	|
| [Carolina Cunha](https://github.com/13caroline)  	|
| [Hugo Faria](https://github.com/KHiro13)      	|
| [João Diogo Mota](https://github.com/JoaoDiogoMota) 	|
| [Rodolfo Silva](https://github.com/Th0l)   	|

> <img src="https://seeklogo.com/images/U/Universidade_do_Minho-logo-CB2F98451C-seeklogo.com.png" align="left" height="48" width="48" > University of Minho, Software Engineering (4th Year).
