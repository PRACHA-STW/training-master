export const config = {
    mapObjects: [
      {
        value: 'ServiceAppointment',
        latField: 'Latitude',
        longField: 'Longitude',
        stdTextKeyField: 'FSM_StandardTextKey__c',
        titleField: 'AppointmentNumber',
        firstDetailField: 'Subject',
        secondDetailField: 'Status',
        //thirdDetailField: 'DurationInMinutes',
        thirdDetailField: 'Duration',
        standardTextKey: ["2BCEL1","2BLOC1","2BLOR1","2BLOS1","2BLOT1","12BLPF1","2EXFR1","2MAIBL1","2MRBL1","2PDASR","12TBCE1","12TBLC1",
        "12TBLR1","12TBLS1","12TBLT1","12TEHP1","12TGUL1","12TMAI1","12TMAR1","12TPRF1","SSBLOS1","SSBLOT1","SSMRBL1","2OOHCB"],
        statusField:'Status',
        dueDateField:'DueDate'
      },
      {
        value: 'ServiceResource',
        latField: 'LastKnownLatitude',
        longField: 'LastKnownLongitude',
        titleField: 'Name',
        firstDetailField: 'ResourceType',
        secondDetailField: 'IsActive',
        thirdDetailField: 'Description',
        stdTextKeyField: 'FSM_TravelRestriction__c',
        standardTextKey: null
      }
    ],
    distanceUnit: 'km', // Preferred distance unit: km or mi
  };