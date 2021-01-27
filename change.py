import pandas as pd

uE = pd.read_csv("urgency_Episodes.csv")

for index,row in uE.iterrows():
    if ( int(uE.iloc[index]['DATE_OF_BIRTH'][0:4]) >= 2018 ) :
        size = len(uE.iloc[index]['DATE_OF_BIRTH'])
        newString = '19' + uE.iloc[index]['DATE_OF_BIRTH'][2:size]
        #print(uE.at[index,'DATE_OF_BIRTH'])
        uE.at[index,'DATE_OF_BIRTH'] = newString
        #print(newString)

uE.to_csv("urgency_Episodes.csv", index = False,sep=';')

uProcedures = pd.read_csv("urgency_procedures.csv",sep=';')

uProcedures['DESC_INTERVENTION'] = uProcedures['DESC_INTERVENTION'].replace(['Endovenoso'], 'Terapêutica Endovenoso')
uProcedures['DESC_INTERVENTION'] = uProcedures['DESC_INTERVENTION'].replace(['Subcutânea'], 'Terapêutica Subcutânea')

uProcedures.to_csv("urgency_procedures.csv", index = False,sep=';')
