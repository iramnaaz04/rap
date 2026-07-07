*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDB_SALES_ITM...................................*
DATA:  BEGIN OF STATUS_ZDB_SALES_ITM                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDB_SALES_ITM                 .
CONTROLS: TCTRL_ZDB_SALES_ITM
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDB_SALES_ITM                 .
TABLES: ZDB_SALES_ITM                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
