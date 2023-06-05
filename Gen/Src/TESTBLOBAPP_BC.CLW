  MEMBER('TestBlobApp.clw')

  PRAGMA('define(init_priority=>3)')

  MAP
    MODULE('TestBlobApp_BC0.CLW')
TestBlobApp_BC0:DctInit             PROCEDURE()
TestBlobApp_BC0:DctKill             PROCEDURE()
TestBlobApp_BC0:FilesInit           PROCEDURE()
    END
  END

DctInit PROCEDURE()
  CODE
  TestBlobApp_BC0:DctInit
  TestBlobApp_BC0:FilesInit


DctKill PROCEDURE()
  CODE
  TestBlobApp_BC0:DctKill

