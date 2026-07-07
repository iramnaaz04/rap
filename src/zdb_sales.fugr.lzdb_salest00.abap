*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDB_SALES.......................................*
DATA:  BEGIN OF STATUS_ZDB_SALES                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDB_SALES                     .
CONTROLS: TCTRL_ZDB_SALES
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZDB_SALES                     .
TABLES: ZDB_SALES                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
