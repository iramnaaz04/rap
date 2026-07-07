*&---------------------------------------------------------------------*
*& Report ZSALES_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSALES_REPORT_HOTSPOT.

TABLES: VBAK, VBAP.
DATA: IT_VBAK TYPE TABLE OF ZSTR_VBAK,
      WA_VBAK TYPE ZSTR_VBAK.

DATA: IT_VBAP TYPE TABLE OF ZSTR_VBAP,
      WA_VBAP TYPE ZSTR_VBAP.

DATA: IT_FCAT  TYPE SLIS_T_FIELDCAT_ALV,
      WA_FCAT  TYPE SLIS_FIELDCAT_ALV.
*      IT_FCAT1 TYPE SLIS_T_FIELDCAT_ALV,
*      WA_FCAT1 TYPE SLIS_FIELDCAT_ALV.

DATA: it_header TYPE SLIS_T_LISTHEADER,
      wa_header TYPE SLIS_LISTHEADER.


SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
  SELECT-OPTIONS: S_VBELN FOR VBAK-VBELN.
SELECTION-SCREEN: END OF BLOCK B1.

SELECT vbeln
         erdat
         erzet
         ernam
         audat
    INTO TABLE it_vbak
    FROM vbak
   WHERE vbeln IN s_vbeln.

* Field Catalog
  CLEAR wa_fcat.
  wa_fcat-col_pos   = 1.
  wa_fcat-fieldname = 'VBELN'.
  wa_fcat-seltext_l = 'Sales Order'.
  wa_fcat-hotspot   = 'X'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-col_pos   = 2.
  wa_fcat-fieldname = 'ERDAT'.
  wa_fcat-seltext_l = 'Creation Date'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-col_pos   = 3.
  wa_fcat-fieldname = 'ERZET'.
  wa_fcat-seltext_l = 'Entry Time'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-col_pos   = 4.
  wa_fcat-fieldname = 'ERNAM'.
  wa_fcat-seltext_l = 'Created By'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-col_pos   = 5.
  wa_fcat-fieldname = 'AUDAT'.
  wa_fcat-seltext_l = 'Document Date'.
  APPEND wa_fcat TO it_fcat.

* Display ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'USER_COMMAND'
      it_fieldcat             = it_fcat
    TABLES
      t_outtab                = it_vbak
    EXCEPTIONS
      program_error           = 1
      others                  = 2.

*---------------------------------------------------------------------*
* Hotspot Click Event
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  DATA: ls_vbak TYPE ZSTR_vbak.

  IF r_ucomm = '&IC1'.

    READ TABLE it_vbak INTO ls_vbak INDEX rs_selfield-tabindex.

    IF sy-subrc = 0
       AND rs_selfield-fieldname = 'VBELN'.

      SET PARAMETER ID 'AUN' FIELD ls_vbak-vbeln.

      CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

    ENDIF.

  ENDIF.

ENDFORM.
