import pandas as pd

episodes = pd.read_csv("urgency_Episodes.csv",sep=';')
exams = pd.read_csv("urgency_exams.csv", sep=';')
procedures = pd.read_csv("urgency_procedures.csv",sep=';')
prescriptions = pd.read_csv("urgency_prescriptions.csv",sep=';')

episodesID = episodes['URG_EPISODE'].tolist()
examsID = exams['URG_EPISODE'].tolist()
proceduresID = procedures['URG_EPISODE'].tolist()
prescriptionsID = prescriptions['URG_EPISODE'].tolist()

l1 = list(set(episodesID) - set(examsID))

for i in l1:
    insert = pd.DataFrame({"URG_EPISODE" : [i],"NUM_EXAM" : ["Sem Exame"], "DESC_EXAM" : ["Sem Exame"]})
    exams = pd.concat([exams, insert], ignore_index=True)

exams = exams.iloc[:,::-1]
exams.to_csv("urgency_exams_2.csv", index = False,sep=';')

l2 = list(set(episodesID) - set(proceduresID))

for i in l2:
    insert = pd.DataFrame({ "URG_EPISODE" : [i], "ID_PROFESSIONAL" : [-1], "DT_PRESCRIPTION" : ["1111/11/11 00:00:00"],
                         "ID_PRESCRIPTION" : [-1], "DT_BEGIN" : ["1111/11/11 00:00:00"], "DT_CANCEL" : [0],
                         "ID_PROFESSIONAL_CANCEL" : [-1], "ID_INTERVENTION" : [-1], "DESC_INTERVENTION" : ["Sem Intervenção"]})
    procedures = pd.concat([procedures, insert],ignore_index=True)

procedures = procedures.iloc[:,::-1]
procedures.to_csv("urgency_procedures_2.csv", index = False,sep=';')

l3 = list(set(episodesID) - set(prescriptionsID))

for i in l3:
    insert = pd.DataFrame({ "URG_EPISODE" : [i], "COD_PRESCRIPTION" : [-1], "ID_PROF_PRESCRIPTION" : ["-1"],
                         "DT_PRESCRIPTION" : ["1111/11/11 00:00:00"], "COD_DRUG" : [-1], "QT" : [0],
                         "DESC_DRUG" : ["Sem Medicação"]})
    prescriptions = pd.concat([prescriptions, insert],ignore_index=True)

prescriptions = prescriptions.iloc[:,::-1]
prescriptions.to_csv("urgency_prescriptions_2.csv", index = False,sep=';')
