

   MEMBER('TestBlobApp.clw')                               ! This is a MEMBER module

                     MAP
                       INCLUDE('TESTBLOB.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Source
!!! Test Blob
!!! </summary>
TestBlob             PROCEDURE                             ! Declare Procedure
!
BlobData CSTRING(512)
BlobSize LONG
DataSize LONG
blobRef &Blob

BlobTestTableHub       FILE,DRIVER('MSSQL'),OWNER(glo:ConnectString),NAME('dbo.BlobTestTableHub'),PRE(BT),CREATE 
PK                     KEY(BT:C1_Long),NOCASE,PRIMARY                         
C2_Blob                     BLOB                                                
Record                   RECORD,PRE()
C1_Long                     LONG 
C3_Long                     LONG                                               
                         END
                     END  
UpdateAction    Byte


ClarionSqlConn       FILE,DRIVER('MSSQL'),OWNER(glo:ConnectString),NAME('dbo.ClarionSqlConn'),PRE(CSC),CREATE 
PK                     KEY(CSC:int1),NOCASE,PRIMARY                         
Record                   RECORD,PRE()
int1                     LONG 
                         END
                     END 
                     
Util       CLASS
OpenTable        PROCEDURE(*File pFile)
UpdateTable      PROCEDURE()
FetchFirstRecord PROCEDURE()
ExecSql          PROCEDURE(STRING pSqlText, BYTE pMute=0)
LogError         PROCEDURE() 
AddDebugLog      PROCEDURE(STRING pStr) 
FileExists       PROCEDURE(),BYTE
            End                     
                     

  CODE
!
      Glo:ConnectString = 'server,db,usr,pwd'
      
      Clear(DisplayLog)      
      
      Util.OpenTable(BlobTestTableHub)
      Util.FetchFirstRecord()
      
      
            

                                                                           Util.AddDebugLog('blobRef &= BlobTestTableHub.C2_Blob')
      blobRef &= BlobTestTableHub.C2_Blob
                                                                           Util.AddDebugLog('BlobTestTableHub{{PROP:Value, -1}: '& BlobTestTableHub{PROP:Value, -1})  ! "a" : current sql value
                                                                           Util.AddDebugLog('BlobTestTableHub{{PROP:Text, -1}: '& BlobTestTableHub{PROP:Text, -1})    ! "a" : current sql value
                                                                           Util.AddDebugLog('blobRef{{PROP:Size}): '& blobRef{PROP:Size})                    ! 1
                                                                           Util.AddDebugLog('blobRef{{PROP:Binary}: '& blobRef{PROP:Binary})                 ! <blank>
      BlobData = 'bb'& All('0', 64) &'cc'
                                                                           Util.AddDebugLog('BlobData: '& BlobData)                                          ! bb
      DataSize = LEN(CLIP(BlobData))
                                                                           Util.AddDebugLog('DataSize: '& DataSize )                              ! DataSize (2)
                                                                           Util.AddDebugLog('Len(Clip(BlobData)): '&LEN(CLIP(BlobData)))          ! Len(Clip(BlobData)) (2)
                                                                           Util.AddDebugLog('Set blobRef{{prop:size} = 0')
      blobRef{PROP:Size} = 0
                                                                           Util.AddDebugLog('Blob size after set to 0: '& blobRef{PROP:Size})     ! 0
      blobRef{PROP:Size} = DataSize
                                                                           Util.AddDebugLog('Set Blob Size to: '& DataSize)                       ! 2

                                                                           Util.AddDebugLog('BlobData[1:DataSize]: '& BlobData[1:DataSize]) 
!                                                                          Util.AddDebugLog('SUB(BlobData, 1 ,DataSize): '& SUB(BlobData, 1 ,DataSize)) 
      blobRef[0:DataSize-1] = BlobData[1:DataSize] 
!     blobRef[0:DataSize-1] = SUB(BlobData, 1 ,DataSize)

      BlobSize = blobRef{PROP:Size}
                                                                           Util.AddDebugLog('BlobSize: '& BlobSize)                               ! 2
                                                                           Util.AddDebugLog('DataSize: '& DataSize)                               ! 2
                                                                           Util.AddDebugLog('blobRef[0:BlobSize-1]: '& blobRef[0:BlobSize-1])     ! bb
      
      
      Util.UpdateTable()    
      
      
                                                                           Util.AddDebugLog('Close Tables')       
      CLOSE (BlobTestTableHub)
      CLOSE (BlobTestTableHub)
      CLOSE (ClarionSqlConn)



Util.OpenTable      PROCEDURE (*File pFile)
  CODE
                                                                           Util.AddDebugLog('Open '&pFile{PROP:Name}&'')
  LOOP 2 TIMES                                                             ! Crude, but it works - especially if the Sql table is deleted - Clarion OPEN statement does not report an error. 
      CLOSE(pFile)
      IF NOT Util.FileExists() 
                                                                           Util.AddDebugLog('Create: '&pFile{PROP:Name}&'')
         CREATE(pFile) 
      END      
      OPEN(pFile, ReadWrite+DenyNone)
  END

Util.FetchFirstRecord  PROCEDURE()
  CODE
                                                                           Util.AddDebugLog('Get Record Nr 1')
  BT:C1_Long = 1
  GET(BlobTestTableHub, BT:PK)
  IF ERRORCODE() = 35
                                                                           Util.AddDebugLog('Record Not Found - UpdateAction set to ADD')
    UpdateAction = 1 !- ADD
    CLEAR(BlobTestTableHub.Record)
    BlobTestTableHub.C1_Long = 1
    
  ELSE
                                                                           Util.AddDebugLog('Record Found - UpdateAction set to PUT')
    UpdateAction = 2 !- PUT
    
  END   
  
      
Util.UpdateTable    PROCEDURE
  CODE
  
      CASE UpdateAction
      OF 1
          CASE UpdateType
          OF 'Clarion'
                                                                           Util.AddDebugLog('ADD')
              ADD(BlobTestTableHub)
              Util.LogError()
          OF 'Sql'
                                                                           Util.AddDebugLog('INSERT')
              Util.ExecSql('Insert Into BlobTestTableHub (C1_Long, C3_Long, C2_Blob) values (1, 1, '''& CLIP(BlobData) &''')')    ! This is working
          END  
          
      OF 2
          CASE UpdateType
          OF 'Clarion'
                                                                           Util.AddDebugLog('PUT')                                 ! This is working 
              PUT(BlobTestTableHub)
              Util.LogError()
          OF 'Sql'
                                                                           Util.AddDebugLog('UPDATE')                              ! This is working 
              Util.ExecSql('Update BlobTestTableHub Set C2_Blob = '''& CLIP(BlobData) &'''')
          END
          
      END  

Util.FileExists PROCEDURE()
   CODE                                                                         
   
   SELF.ExecSql('SELECT OBJECT_ID(''BlobTestTableHub'')', 0)
   NEXT(ClarionSqlConn)
                                                                           Util.AddDebugLog('Ojbect Id: '& ClarionSqlConn.int1)
   IF ClarionSqlConn.int1 > 0
      RETURN 1
   ELSE
      RETURN 0
   END   
   

Util.ExecSql       PROCEDURE(STRING pSqlText, BYTE pMute)
   CODE   
   
   CREATE(ClarionSqlConn)   
   OPEN(ClarionSqlConn)     
   ClarionSqlConn{PROP:SQL} = pSqlText
   IF ERRORCODE() AND NOT pMute
                                                                          Util.AddDebugLog('Sql Exec Error: '& ERROR())  
                                                                          Util.AddDebugLog('Sql Exec Error: '& FILEERROR())
   END
  !CLOSE(ClarionSqlConn)
Util.LogError  PROCEDURE ()
   CODE

   IF ERRORCODE() 
       MESSAGE(|
               'ERRORCODE():| '& ERRORCODE() &'||'&|             ! 90
               'ERROR():| '& ERROR() &'||'&|                     ! File System Error
               'FILEERRORCODE():| '& FILEERRORCODE() &'||'&|     ! Access Violation
               'FILEERROR():| '& FILEERROR()|                    ! 5C541515  00CFEED8  0001:00080515 ClaRUN.dll   
               |                                                 ! 6163A851  00CFF048  0001:00029851   
               ,'Blob',ICON:Exclamation,,,MSGMODE:CANCOPY |      
       )
                                                                        Util.AddDebugLog('ERRORCODE(): '& ERRORCODE())
                                                                        Util.AddDebugLog('ERROR(): '& ERROR())
                                                                        Util.AddDebugLog('FILEERRORCODE(): '& FILEERRORCODE())
                                                                        Util.AddDebugLog('FILEERROR(): '& FILEERROR())
   END

Util.AddDebugLog PROCEDURE(string pStr)              ! Declare Procedure
logMsg         cString(len(pStr)+512)
  CODE
  
  logMsg = '[TestBlob] - '& Clip(pStr)
  testsOutputDebugString(logMsg)
  DisplayLog = CLIP(DisplayLog) &'<13,10>'& CLIP(logMsg)
  


   
