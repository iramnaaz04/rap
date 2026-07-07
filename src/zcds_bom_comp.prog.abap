*&---------------------------------------------------------------------*
*& Report ZCDS_BOM_COMP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZCDS_BOM_COMP.

TABLES: AUFK, MARA.

PARAMETERS:

p_werks TYPE werks_d.

SELECT-OPTIONS: s_aufnr for aufk-aufnr,
s_matnr FOR mara-matnr.

DATA it_data TYPE TABLE OF zddic_cds_bom.

SELECT *
FROM zddic_cds_bom
  WHERE plant = @p_werks
        AND productionorder in @s_aufnr
        AND finishedmaterial in @s_matnr
  INTO TABLE @it_data.

  IF it_data IS INITIAL.
  MESSAGE 'No data found.' TYPE 'I'.
  EXIT.
ENDIF.

TRY.
    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = DATA(lo_alv)
      CHANGING
        t_table      = it_data ).

      DATA: lo_Columns TYPE REF TO cl_salv_columns_table,
      lo_column  TYPE REF TO cl_salv_column_table.

lo_columns = lo_alv->get_columns( ).

TRY.

    lo_column ?= lo_columns->get_column( 'GRRATE' ).
    lo_column->set_short_text( 'GR Rate' ).
    lo_column->set_medium_text( 'GR Rate' ).
    lo_column->set_long_text( 'GR Rate (%)' ).

    lo_column ?= lo_columns->get_column( 'CONSUMPTIONSTATUS' ).
    lo_column->set_short_text( 'Status' ).
    lo_column->set_medium_text( 'Consumption Status' ).
    lo_column->set_long_text( 'Consumption Status' ).

    lo_column ?= lo_columns->get_column( 'SYSTEMDATE' ).
    lo_column->set_short_text( 'Date' ).
    lo_column->set_medium_text( 'System Date' ).
    lo_column->set_long_text( 'System Date' ).

  CATCH cx_salv_not_found.
ENDTRY.

    lo_alv->display( ).

  CATCH cx_salv_msg INTO DATA(lx_salv).
    MESSAGE lx_salv->get_text( ) TYPE 'E'.
ENDTRY.
