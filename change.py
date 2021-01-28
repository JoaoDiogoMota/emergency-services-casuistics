import pandas as pd

#FIX URGECY EPISODES, datas estavam mal
uE = pd.read_csv("urgency_Episodes.csv")

for index,row in uE.iterrows():
    if ( int(uE.iloc[index]['DATE_OF_BIRTH'][0:4]) >= 2018 ) :
        size = len(uE.iloc[index]['DATE_OF_BIRTH'])
        newString = '19' + uE.iloc[index]['DATE_OF_BIRTH'][2:size]
        uE.at[index,'DATE_OF_BIRTH'] = newString

uE.to_csv("urgency_Episodes.csv", index = False,sep=';')

#FIX URGENCY PROCEDURES, algumas descrições estavam mal
uProcedures = pd.read_csv("urgency_procedures.csv",sep=';')

uProcedures['DESC_INTERVENTION'] = uProcedures['DESC_INTERVENTION'].replace(['Endovenoso'], 'Terapêutica Intravenosa')
uProcedures['DESC_INTERVENTION'] = uProcedures['DESC_INTERVENTION'].replace(['Subcutânea'], 'Terapêutica Subcutânea')

uProcedures.to_csv("urgency_procedures.csv", index = False,sep=';')

#FIX URGENCY EXAMS, algumas descrições estavam vazias
exams = pd.read_csv("urgency_exams.csv", sep=';')
exams['DESC_EXAM'] = exams['DESC_EXAM'].fillna('Sem descrição')
exams.to_csv("urgency_exams.csv", index = False,sep=';')
