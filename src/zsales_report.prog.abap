*&---------------------------------------------------------------------*
*& Report ZSALES_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSALES_REPORT.

TABLES: VBAK, VBAP.
DATA: IT_VBAK TYPE TABLE OF ZSTR_VBAK,
      WA_VBAK TYPE ZSTR_VBAK.

DATA: IT_VBAP TYPE TABLE OF ZSTR_VBAP,
      WA_VBAP TYPE ZSTR_VBAP.

DATA: IT_FINAL TYPE TABLE OF ZSTR_FINAL,
      WA_fINAL TYPE ZSTR_FINAL.

DATA: IT_FCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_FCAT TYPE SLIS_FIELDCAT_ALV.

DATA: it_header TYPE SLIS_T_LISTHEADER,
      wa_header TYPE SLIS_LISTHEADER.


SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: S_VBELN FOR VBAK-VBELN.
SELECTION-SCREEN: END OF BLOCK B1.

START-OF-SELECTION.
  SELECT
  VBELN
  ERDAT
  ERZET
  ERNAM
  AUDAT
    FROM VBAK
    INTO TABLE IT_VBAK
    WHERE VBELN IN S_VBELN.

  IF IT_VBAK IS NOT INITIAL.

    SELECT
      VBELN
      POSNR
      MATNR
      MATKL
      MEINS
       FROM VBAP
      INTO TABLE IT_VBAP
      FOR ALL ENTRIES IN IT_VBAK
      WHERE VBELN = IT_VBAK-VBELN.
ENDIF.


      LOOP AT IT_VBAK INTO WA_VBAK.

        LOOP AT IT_VBAP INTO WA_VBAP
          WHERE VBELN = WA_VBAK-VBELN.

          CLEAR WA_FINAL.


        WA_FINAL-VBELN = WA_VBAK-VBELN.
        wa_final-erdat = wa_vbak-erdat.
        wa_final-erzet = wa_vbak-erzet.
        wa_final-ernam = wa_vbak-ernam.
        wa_final-audat = wa_vbak-audat.

        wa_final-posnr = wa_vbap-posnr.
        wa_final-matnr = wa_vbap-matnr.
        wa_final-matkl = wa_vbap-matkl.
        wa_final-meins = wa_vbap-meins.

         APPEND wa_final TO it_final.
      ENDLOOP.
ENDLOOP.

*LOOP AT IT_FINAL INTO WA_FINAL.
*  WRITE : / WA_FINAL-VBELN ,
*            wa_final-erdat ,
*             wa_final-erzet ,
*            wa_final-ernam ,
*            wa_final-audat ,
*
*            wa_final-posnr ,
*            wa_final-matnr,
*            wa_final-matkl,
*            wa_final-meins.
*            ENDLOOP.



*            CLEAR: WA_FINAL.
*
*            WA_FCAT-COL_POS = '1'.
*            WA_FCAT-FIELDNAME = 'VBELN'.
*            WA_FCAT-SELTEXT_L = 'SALES ORDER'.
*            APPEND WA_FCAT TO IT_FCAT.
*            CLEAR: WA_FCAT.
*
*            WA_FCAT-COL_POS = '2'.
*            WA_FCAT-FIELDNAME = 'ERDAT'.
*            WA_FCAT-SELTEXT_L = 'CREATION DATE'.
*            APPEND WA_FCAT TO IT_FCAT.
*            CLEAR: WA_FCAT.
*
*            WA_FCAT-COL_POS = '3'.
*            WA_FCAT-FIELDNAME = 'ERZET'.
*            WA_FCAT-SELTEXT_L = 'ENTRY TIME'.
*            APPEND WA_FCAT TO IT_FCAT.
*            CLEAR: WA_FCAT.
*
*            WA_FCAT-COL_POS = '4'.
*            WA_FCAT-FIELDNAME = 'ERNAM'.
*            WA_FCAT-SELTEXT_L = 'NAME OF THE PERSON'.
*            APPEND WA_FCAT TO IT_FCAT.
*            CLEAR: WA_FCAT.
*
*
*            WA_FCAT-COL_POS = '5'.
*            WA_FCAT-FIELDNAME = 'AUDAT'.
*            WA_FCAT-SELTEXT_L = 'DOCUMENT DATE'.
*            APPEND WA_FCAT TO IT_FCAT.
*            CLEAR: WA_FCAT.
*
*
*            WA_FCAT-COL_POS = '6'.
*            WA_FCAT-FIELDNAME = 'POSNR'.
*            WA_FCAT-SELTEXT_L = 'SALES ITEM NO'.
*            APPEND WA_FCAT TO IT_FCAT.
*            CLEAR: WA_FCAT.
*
*
*            WA_FCAT-COL_POS = '7'.
*            WA_FCAT-FIELDNAME = 'MATNR'.
*            WA_FCAT-SELTEXT_L = 'MATERIAL'.
*            APPEND WA_FCAT TO IT_FCAT.
*            CLEAR: WA_FCAT.
*
*
*            WA_FCAT-COL_POS = '8'.
*            WA_FCAT-FIELDNAME = 'MATKL'.
*            WA_FCAT-SELTEXT_L = 'MATERIAL GROUP'.
*            APPEND WA_FCAT TO IT_FCAT.
*            CLEAR: WA_FCAT.
*
*
*            WA_FCAT-COL_POS = '9'.
*            WA_FCAT-FIELDNAME = 'MEINS'.
*            WA_FCAT-SELTEXT_L = 'BASE UNIT OF MEASURE'.
*            APPEND WA_FCAT TO IT_FCAT.
*            CLEAR: WA_FCAT.

PERFORM add_fieldcatalog USING 'VBELN' 'SALES ORDER'.
PERFORM add_fieldcatalog USING 'ERDAT' 'DATE'.
PERFORM add_fieldcatalog USING 'ERZET' 'TIME'.
PERFORM add_fieldcatalog USING 'ERNAM' 'NAME OF THE PERSON'.
PERFORM add_fieldcatalog USING 'AUDAT' 'DOCUMENT DATE'.
PERFORM add_fieldcatalog USING 'POSNR' 'SALES ITEM NO'.
PERFORM add_fieldcatalog USING 'MATNR' 'MATERIAL'.
PERFORM add_fieldcatalog USING 'MATKL' 'MATERIAL GROUP'.
PERFORM add_fieldcatalog USING 'MEINS' 'BASE UNIT OF MEASURE'.




CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
 EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
*    I_CALLBACK_PROGRAM                =
*   I_CALLBACK_PF_STATUS_SET          = ' '
*   I_CALLBACK_USER_COMMAND           = ' '
*    I_CALLBACK_TOP_OF_PAGE            =
*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
*   IS_LAYOUT                         =
    IT_FIELDCAT                       = IT_FCAT
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
*   IT_SORT                           =
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
*   I_SAVE                            = ' '
*   IS_VARIANT                        =
*   IT_EVENTS                         =
*   IT_EVENT_EXIT                     =
*   IS_PRINT                          =
*   IS_REPREP_ID                      =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE                 = 0
*   I_HTML_HEIGHT_TOP                 = 0
*   I_HTML_HEIGHT_END                 = 0
*   IT_ALV_GRAPHICS                   =
*   IT_HYPERLINK                      =
*   IT_ADD_FIELDCAT                   =
*   IT_EXCEPT_QINFO                   =
*   IR_SALV_FULLSCREEN_ADAPTER        =
*   O_PREVIOUS_SRAL_HANDLER           =
*   O_COMMON_HUB                      =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
  TABLES
    T_OUTTAB                          = IT_FINAL
* EXCEPTIONS
*   PROGRAM_ERROR                     = 1
*   OTHERS                            = 2
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.



form add_fieldcatalog USING p_field p_text.

  CLEAR: wa_fcat.
  wa_fcat-fieldname = p_field.
  wa_fcat-seltext_l = p_text.
  APPEND wa_fcat to it_fcat.

  ENDFORM.
