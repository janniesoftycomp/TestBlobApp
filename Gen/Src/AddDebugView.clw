

   MEMBER('TestBlobApp.clw')                               ! This is a MEMBER module

                     MAP
                       INCLUDE('ADDDEBUGVIEW.INC'),ONCE        !Local module procedure declarations
                     END


!!! <summary>
!!! Generated from procedure template - Source
!!! Add Debug View
!!! </summary>
AddDebugView         PROCEDURE  (string pStr)              ! Declare Procedure
szMsg         cString(len(pStr)+512)

  CODE
  szMsg = '[TestBlob] - '& Clip(pStr)
  testsOutputDebugString(szMsg)
