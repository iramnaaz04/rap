*&---------------------------------------------------------------------*
*& Report ZSTD_MAT_PRD2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSTD_MAT_PRD2.
*&---------------------------------------------------------------------*
*& Report ZSTD_MAT_PRD
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*


TABLES: MARA, MARC, MAKT, MAST, CRHD, AFPO, VBAP, PLAF.

TYPES: BEGIN OF STR_MARA,
         MATNR TYPE MARA-MATNR,
         MTART TYPE MARA-MTART,
         ERNAM TYPE MARA-ERNAM,
         LAEDA TYPE MARA-LAEDA,
*         MAKTG TYPE MARA-MAKTG,
       END OF STR_MARA.

TYPES: BEGIN OF STR_MARC,
         MATNR TYPE MARC-MATNR,
         WERKS TYPE MARC-WERKS,
       END OF STR_MARC.

TYPES: BEGIN OF STR_MAKT,
         MATNR TYPE MAKT-MATNR,
         MAKTX TYPE MAKT-MAKTX,
         MAKTG TYPE MAKT-MAKTG,
       END OF STR_MAKT.

TYPES: BEGIN OF STR_MAST,
         MATNR TYPE MAST-MATNR,
         WERKS TYPE MAST-WERKS,
       END OF STR_MAST.

TYPES: BEGIN OF STR_CRHD,
         WERKS TYPE CRHD-WERKS,
         ARBPL TYPE CRHD-ARBPL,
       END OF STR_CRHD.


TYPES: BEGIN OF STR_AFPO,
         MATNR TYPE AFPO-MATNR,
         AUFNR TYPE AFPO-AUFNR,
         VERID TYPE AFPO-VERID,
       END OF STR_AFPO.

TYPES: BEGIN OF STR_VBAP,
         MATNR TYPE VBAP-MATNR,
         NETWR TYPE VBAP-NETWR,
         VBELN TYPE VBap-VBELN,
       END OF STR_VBAP.

TYPES: BEGIN OF STR_PLAF,
         MATNR TYPE PLAF-MATNR,
         PLNUM TYPE PLAF-PLNUM,
       END OF STR_PLAF.

TYPES: BEGIN OF STR_FINAL,
         MATNR  TYPE MARA-MATNR,
         WERKS  TYPE MARC-WERKS,
         MTART  TYPE MARA-MTART,
         MAKTX  TYPE MAKT-MAKTX,
         MAT3   TYPE MAST-MATNR,
         ARBPL  TYPE CRHD-ARBPL,
         VERID  TYPE AFPO-VERID,
         VBELN  TYPE VBAP-VBELN,
         PLNUM  TYPE PLAF-PLNUM,
         AUFNR  TYPE AFPO-AUFNR,
         LAEDA  TYPE MARA-LAEDA,
         ERNAM  TYPE MARA-ERNAM,
         NETWR  TYPE VBAP-NETWR,

         WERKS1 TYPE MAST-WERKS,
         MAT1   TYPE MARC-MATNR,
         MAT2   TYPE MAKT-MATNR,
         MAKTG  TYPE MAKT-MAKTG,
         WERKS2 TYPE CRHD-WERKS,
         MAT4   TYPE AFPO-MATNR,
         MAT5   TYPE VBAP-MATNR,
         MAT6   TYPE PLAF-MATNR,

         CHECK  TYPE C LENGTH 1,
       END OF STR_FINAL.

TYPES: BEGIN OF STR_DOWNLOAD,




          MATNR TYPE CHAR40,
         WERKS TYPE CHAR20,
         MTART TYPE CHAR20,
         MAKTX TYPE CHAR100,
         MAT3  TYPE CHAR40,
         ARBPL TYPE CHAR40,
         VERID TYPE CHAR20,
         VBELN TYPE CHAR20,
         PLNUM TYPE CHAR20,
         AUFNR TYPE CHAR20,
         LAEDA TYPE CHAR20,
         ERNAM TYPE CHAR20,
         NETWR TYPE CHAR30,

       END OF STR_DOWNLOAD.


DATA: IT_MARA TYPE TABLE OF STR_MARA,
      WA_MARA TYPE STR_MARA.

DATA: IT_MARC TYPE TABLE OF STR_MARC,
      WA_MARC TYPE STR_MARC.

DATA: IT_MAKT TYPE TABLE OF STR_MAKT,
      WA_MAKT TYPE STR_MAKT.

DATA: IT_MAST TYPE TABLE OF STR_MAST,
      WA_MAST TYPE STR_MAST.

DATA: IT_CRHD TYPE TABLE OF STR_CRHD,
      WA_CRHD TYPE STR_CRHD.



DATA: IT_AFPO TYPE TABLE OF STR_AFPO,
      WA_AFPO TYPE STR_AFPO.

DATA: IT_VBAP TYPE TABLE OF STR_VBAP,
      WA_VBAP TYPE STR_VBAP.

DATA: IT_PLAF TYPE TABLE OF STR_PLAF,
      WA_PLAF TYPE STR_PLAF.

DATA: IT_FINAL TYPE TABLE OF STR_FINAL,
      WA_FINAL TYPE STR_FINAL.

DATA: IT_FCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_FCAT TYPE SLIS_FIELDCAT_ALV.

DATA: IT_SORT TYPE SLIS_T_SORTINFO_ALV,
      WA_SORT TYPE SLIS_SORTINFO_ALV.

DATA: WA_COLOR TYPE SLIS_SPECIALCOL_ALV.

DATA: WA_LAYOUT TYPE SLIS_LAYOUT_ALV.

DATA: IT_ZTABLE TYPE TABLE OF ZDB_STD_MAT_PRD,
      WA_ZTABLE TYPE ZDB_STD_MAT_PRD.

DATA:  wa_download TYPE STR_Download.

SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: S_MATNR FOR MARA-MATNR OBLIGATORY,
  S_WERKS FOR MARC-WERKS.
SELECTION-SCREEN: END OF BLOCK B1.

START-OF-SELECTION.

  SELECT
    MATNR
    MTART
    ERNAM
    LAEDA
    FROM MARA
    INTO TABLE IT_MARA
    WHERE MATNR IN S_MATNR.


  IF IT_MARA IS NOT INITIAL.

    SELECT
      MATNR
      WERKS
      FROM MARC
      INTO TABLE IT_MARC
      FOR ALL ENTRIES IN IT_MARA
      WHERE MATNR = IT_MARA-MATNR
      AND WERKS IN S_WERKS.

    SELECT
      MATNR
      MAKTX
      MAKTG
      FROM MAKT
      INTO TABLE IT_MAKT
      FOR ALL ENTRIES IN IT_MARA
      WHERE MATNR = IT_MARA-MATNR.

    SELECT
      MATNR
      WERKS
      FROM MAST
      INTO TABLE IT_MAST
      FOR ALL ENTRIES IN IT_MARA
      WHERE MATNR = IT_MARA-MATNR.

    SELECT
      WERKS
      ARBPL
      FROM CRHD
      INTO TABLE IT_CRHD
      FOR ALL ENTRIES IN IT_MARC
      WHERE WERKS = IT_MARC-WERKS.


    SELECT
      MATNR
      AUFNR
      VERID
      FROM AFPO
      INTO TABLE IT_AFPO
      FOR ALL ENTRIES IN IT_MARA
      WHERE MATNR = IT_MARA-MATNR.

    SELECT
      MATNR
      NETWR
      VBELN
      FROM VBAP
      INTO TABLE IT_VBAP
      FOR ALL ENTRIES IN IT_MARA
      WHERE MATNR = IT_MARA-MATNR.

    SELECT
      MATNR
      PLNUM
      FROM PLAF
      INTO TABLE IT_PLAF
      FOR ALL ENTRIES IN IT_MARA
      WHERE MATNR = IT_MARA-MATNR.
  ENDIF.


  LOOP AT IT_MARA INTO WA_MARA.

    CLEAR: WA_FINAL.
    DATA: LV_MATNR TYPE MARA-MATNR,
          LV_AUFNR TYPE AFPO-AUFNR,
          LV_VBELN TYPE VBAP-VBELN,
          LV_PLNUM TYPE PLAF-PLNUM.
    LV_MATNR = WA_MARA-MATNR.
    LV_VBELN = WA_VBAP-VBELN.
    LV_PLNUM = WA_PLAF-PLNUM.



    WA_FINAL-MATNR = |{ LV_MATNR ALPHA = OUT }|.

    WA_FINAL-MTART = WA_MARA-MTART.
    WA_FINAL-ERNAM = WA_MARA-ERNAM.
    WA_FINAL-LAEDA = WA_MARA-LAEDA.


    READ TABLE IT_MARC INTO WA_MARC
     WITH KEY MATNR = WA_MARA-MATNR.
    IF SY-SUBRC = 0.
      WA_FINAL-MAT1    = WA_MARC-MATNR.
      WA_FINAL-WERKS  = WA_MARC-WERKS.
    ENDIF.

    IF S_WERKS[] IS NOT INITIAL.
      IF WA_MARC-WERKS NOT IN S_WERKS.
        CONTINUE.
      ENDIF.
    ENDIF.

    READ TABLE IT_MAKT INTO WA_MAKT
    WITH KEY MATNR = WA_MARA-MATNR.
    IF SY-SUBRC = 0.
      WA_FINAL-MAT2 = WA_MAKT-MATNR.
      WA_FINAL-MAKTX = WA_MAKT-MAKTX.
      WA_FINAL-MAKTG = WA_MAKT-MAKTG.
    ENDIF.

    READ TABLE IT_MAST INTO WA_MAST
    WITH KEY MATNR = WA_MARA-MATNR.
    IF SY-SUBRC = 0.


      WA_FINAL-MAT3 = |{ LV_MATNR ALPHA = OUT }|.


      WA_FINAL-WERKS1 = WA_MAST-WERKS.
    ENDIF.

    READ TABLE IT_CRHD INTO WA_CRHD
    WITH KEY WERKS = WA_MARC-WERKS.
    IF SY-SUBRC = 0.
      WA_FINAL-WERKS = WA_CRHD-WERKS.
      WA_FINAL-ARBPL = WA_CRHD-ARBPL.
    ENDIF.

    READ TABLE IT_AFPO INTO WA_AFPO
    WITH KEY MATNR = WA_mara-MATNR.
    IF SY-SUBRC = 0.

      WA_FINAL-AUFNR = |{ WA_AFPO-AUFNR ALPHA = OUT }|.

    ENDIF.
    wa_Final-MAT4 = WA_AFPO-MATNR.

    WA_FINAL-VERID = WA_AFPO-VERID.


    READ TABLE IT_VBAP INTO WA_VBAP
    WITH KEY MATNR = WA_Mara-MATNR.
    IF SY-SUBRC = 0.


      WA_FINAL-VBELN = |{ LV_VBELN ALPHA = OUT }|.

      WA_FINAL-MAT5 = WA_VBAP-MATNR.
      WA_FINAL-NETWR = WA_VBAP-NETWR.
    ENDIF.

    READ TABLE IT_PLAF INTO WA_PLAF
    WITH KEY MATNR = WA_mara-MATNR.
    IF SY-SUBRC = 0.

      WA_FINAL-PLNUM = |{ LV_PLNUM ALPHA = OUT }|.


      wa_Final-MAT6 = WA_PLAF-MATNR.

    ENDIF.


    APPEND WA_FINAL TO IT_FINAL.
    CLEAR : WA_FINAL.
  ENDLOOP.



  PERFORM ADD_FIELDCATALOG USING 'CHECK' 'Select' '' .
  PERFORM ADD_FIELDCATALOG USING 'MATNR' 'Material Number' '' .
  PERFORM ADD_FIELDCATALOG USING 'WERKS' 'Plant' ''.
  PERFORM ADD_FIELDCATALOG USING 'MTART' 'Materia Type' ''.
  PERFORM ADD_FIELDCATALOG USING 'MAKTX' 'Material Description' ''.
  PERFORM ADD_FIELDCATALOG USING 'MAT3' 'BOM Component' ''.
  PERFORM ADD_FIELDCATALOG USING 'ARBPL' 'Work Centre ' ''.
  PERFORM ADD_FIELDCATALOG USING 'VERID' 'Prod. version' ''.
  PERFORM ADD_FIELDCATALOG USING 'VBELN' 'Sales Order' ''.
  PERFORM ADD_FIELDCATALOG USING 'PLNUM' 'Planned Order ' ''.
  PERFORM ADD_FIELDCATALOG USING 'AUFNR' 'Prod. Order' ''.
  PERFORM ADD_FIELDCATALOG USING 'LAEDA' 'Last change.' ''.
  PERFORM ADD_FIELDCATALOG USING 'ERNAM' 'Created by.' ''.
  PERFORM ADD_FIELDCATALOG USING 'NETWR' 'Net Value' 'X'.

  CLEAR: WA_SORT.
  WA_SORT-SPOS = 1.
  WA_SORT-FIELDNAME = 'MTART'.
  WA_SORT-UP = 'X'.
  WA_SORT-SUBTOT = 'X'.

  APPEND WA_SORT TO IT_SORT.

  SORT IT_FINAL BY MTART.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING

      I_CALLBACK_PROGRAM       = SY-CPROG
      I_CALLBACK_PF_STATUS_SET = 'SET_PF_STATUS'
      I_CALLBACK_USER_COMMAND  = 'U_COMM'

*     IS_LAYOUT                = WA_LAYOUT
      IT_FIELDCAT              = IT_FCAT

      IT_SORT                  = IT_SORT

    TABLES
      T_OUTTAB                 = IT_FINAL
 EXCEPTIONS
     PROGRAM_ERROR            = 1
     OTHERS                   = 2
    .
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.


FORM ADD_FIELDCATALOG USING P_FIELD P_TEXT P_SUM.

  CLEAR: WA_FCAT.
  WA_FCAT-FIELDNAME = P_FIELD.
  WA_FCAT-SELTEXT_L = P_TEXT.
  WA_FCAT-DO_SUM    = P_SUM.
  IF P_FIELD = 'CHECK'.
    Wa_fcat-CHECKBOX = 'X'.
    WA_FCAT-EDIT = 'X'.

  ENDIF.

  APPEND WA_FCAT TO IT_FCAT.

ENDFORM.

FORM SET_PF_STATUS USING RT_EXTAB TYPE SLIS_T_EXTAB.
  SET PF-STATUS 'STANDARD'.
ENDFORM.

FORM U_COMM USING R_UCOMM LIKE SY-UCOMM
                   RS_Selfield TYPE SLIS_SELFIELD.
  CASE R_UCOMM.
    WHEN 'SELECT'.
      LOOP AT IT_FINAL INTO WA_FINAL.
        WA_FINAL-CHECK = 'X'.
        MODIFY IT_FINAL FROM wa_Final.
      ENDLOOP.
      RS_SELFIELD-REFRESH = 'X'.

    WHEN 'DESELECT'.
      LOOP AT IT_FINAL INTO WA_FINAL.
        CLEAR  : WA_FINAL-CHECK.
        MODIFY IT_FINAL FROM WA_FINAL.
      ENDLOOP.
      RS_SELFIELD-REFRESH = 'X'.

    WHEN 'SAVE'.
      DATA: LR_GRID TYPE REF TO CL_GUI_ALV_GRID.

      CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
        IMPORTING
          E_GRID = LR_GRID.

      IF LR_GRID IS BOUND.
        CALL METHOD LR_GRID->CHECK_CHANGED_DATA.
      ENDIF.
      REFRESH IT_ZTABLE.

      CLEAR: WA_ZTABLE.

      LOOP AT IT_FINAL INTO WA_FINAL
       WHERE CHECK = 'X'.

        CLEAR WA_ZTABLE.

    WA_ZTABLE-MATNR = WA_FINAL-MATNR.
    WA_ZTABLE-WERKS = WA_FINAL-WERKS.
    WA_ZTABLE-MTART = WA_FINAL-MTART.
    WA_ZTABLE-MAKTX = WA_FINAL-MAKTX.
    WA_ZTABLE-BOM_COM = WA_FINAL-MAT3.
    WA_ZTABLE-ARBPL = WA_FINAL-ARBPL.
    WA_ZTABLE-VERID = WA_FINAL-VERID.
    WA_ZTABLE-VBELN = WA_FINAL-VBELN.
    WA_ZTABLE-PLNUM = WA_FINAL-PLNUM.
    WA_ZTABLE-AUFNR = WA_FINAL-AUFNR.
    WA_ZTABLE-LAEDA = WA_FINAL-LAEDA.
    WA_ZTABLE-ERNAM = WA_FINAL-ERNAM.
    WA_ZTABLE-NETWR = WA_FINAL-NETWR.

    APPEND WA_ZTABLE TO IT_ZTABLE.


  IF IT_ZTABLE IS INITIAL.
    MESSAGE 'Please select at least one record' TYPE 'I'.
    EXIT.
  ENDIF.

  MODIFY ZDB_STD_MAT_PRD FROM TABLE IT_ZTABLE.

  IF SY-SUBRC = 0.
    COMMIT WORK.
    MESSAGE 'Selected records saved successfully' TYPE 'S'.
  ELSE.
    ROLLBACK WORK.
    MESSAGE 'Error while saving records' TYPE 'E'.
  ENDIF.
      ENDLOOP.
    WHEN 'DOWNLOAD'.

      DATA: "lr_grid     TYPE REF TO cl_gui_alv_grid,
        LV_FILENAME TYPE STRING,
        LV_PATH     TYPE STRING,
        LV_FULLPATH TYPE STRING,
        LT_DOWNLOAD TYPE TABLE OF STR_DOWNLOAD.

      "Get ALV reference (to capture edited data)
      CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
        IMPORTING
          E_GRID = LR_GRID.

      IF LR_GRID IS BOUND.
        LR_GRID->CHECK_CHANGED_DATA( ).
      ENDIF.

wa_download-matnr = 'MATERIAL NUMBER'.
wa_download-werks = 'PLANT'.
wa_download-mtart = 'MATERIAL TYPE'.
wa_download-maktx = 'MATERIAL DESCRIPTION'.
wa_download-mat3  = 'BOM COMPONENT'.
wa_download-arbpl = 'WORK CENTER'.
wa_download-verid = 'PROD VERSION'.
wa_download-vbeln = 'SALES ORDER'.
wa_download-plnum = 'PLANNED ORDER'.
wa_download-aufnr = 'PROD ORDER'.
wa_download-laeda = 'LAST CHANGE'.
wa_download-ernam = 'CREATED BY'.
wa_download-netwr = 'NET VALUE'.
APPEND wa_download TO lt_download.
      "Collect selected rows
      LOOP AT IT_FINAL INTO WA_FINAL WHERE CHECK = 'X'.
        CLEAR wa_download.

  wa_download-matnr = wa_final-matnr.
  wa_download-werks = wa_final-werks.
  wa_download-mtart = wa_final-mtart.
  wa_download-maktx = wa_final-maktx.
  wa_download-mat3  = wa_final-mat3.
  wa_download-arbpl = wa_final-arbpl.
  wa_download-verid = wa_final-verid.
  wa_download-vbeln = wa_final-vbeln.
  wa_download-plnum = wa_final-plnum.
  wa_download-aufnr = wa_final-aufnr.
  wa_download-laeda = wa_final-laeda.
  wa_download-ernam = wa_final-ernam.
  wa_download-netwr = wa_final-netwr.

  APPEND wa_download TO lt_download.


        APPEND WA_DOWNLOAD TO LT_DOWNLOAD.
      ENDLOOP.

      IF Lt_download IS INITIAL.
        MESSAGE 'Please select at least one record' TYPE 'I'.
        EXIT.
      ENDIF.

      "File save dialog
      CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
        EXPORTING
          DEFAULT_EXTENSION = 'xls'
          DEFAULT_FILE_NAME = 'Material_Report.xls'
        CHANGING
          FILENAME          = LV_FILENAME
          PATH              = LV_PATH
          FULLPATH          = LV_FULLPATH.

      IF LV_FULLPATH IS INITIAL.
        EXIT.
      ENDIF.

      CALL FUNCTION 'GUI_DOWNLOAD'
        EXPORTING
          FILENAME                = LV_FULLPATH
          FILETYPE                = 'ASC'
          WRITE_FIELD_SEPARATOR   = 'X'
        TABLES
          DATA_TAB                = LT_DOWNLOAD
        EXCEPTIONS
          FILE_WRITE_ERROR        = 1
          NO_BATCH                = 2
          GUI_REFUSE_FILETRANSFER = 3
          INVALID_TYPE            = 4
          NO_AUTHORITY            = 5
          UNKNOWN_ERROR           = 6
          HEADER_NOT_ALLOWED      = 7
          SEPARATOR_NOT_ALLOWED   = 8
          FILESIZE_NOT_ALLOWED    = 9
          HEADER_TOO_LONG         = 10
          DP_ERROR_CREATE         = 11
          DP_ERROR_SEND           = 12
          DP_ERROR_WRITE          = 13
          UNKNOWN_DP_ERROR        = 14
          ACCESS_DENIED           = 15
          DP_OUT_OF_MEMORY        = 16
          DISK_FULL               = 17
          DP_TIMEOUT              = 18
          FILE_NOT_FOUND          = 19
          DATAPROVIDER_EXCEPTION  = 20
          CONTROL_FLUSH_ERROR     = 21
          OTHERS                  = 22.

      IF SY-SUBRC = 0.
        MESSAGE 'File downloaded successfully' TYPE 'S'.
      ELSE.
        MESSAGE 'Error during file download' TYPE 'E'.
      ENDIF.
  ENDCASE.
ENDFORM.
