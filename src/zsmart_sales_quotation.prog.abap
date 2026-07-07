*&---------------------------------------------------------------------*
*& Report ZSMART_SALES_QUOTATION
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSMART_SALES_QUOTATION.

TABLES: VBAK, VBAP, VBPA, ADRC, MAKT, MARC, PRCD_ELEMENTS.

SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-006.
  PARAMETERS P_VBELN TYPE VBAK-VBELN.
SELECTION-SCREEN: END OF BLOCK B1.

SELECTION-SCREEN PUSHBUTTON /5(20) BTN_DISP USER-COMMAND DISP.
SELECTION-SCREEN PUSHBUTTON /5(20) BTN_MAIL USER-COMMAND MAIL.

DATA : GS_HEADER      TYPE ZSTR_HEADER1,
       GT_ITEM        TYPE ZTT_SMARTFORM,
       GS_ITEM        TYPE ZSTR_ITEM2,
       LV_FM          TYPE RS38L_FNAM,
       LV_SRNO        TYPE CHAR2,
       LV_BASIC_TOTAL TYPE P DECIMALS 2,
       LV_GST_TOTAL   TYPE P DECIMALS 2,
       LV_PRICE_TOTAL TYPE P DECIMALS 2,
       LV_QTY_TOTAL   TYPE P DECIMALS 3.

DATA: LV_FILE          TYPE XSTRING,
      LT_BINARY_TAB    TYPE SOLIX_TAB,
      LO_BCS           TYPE REF TO CL_BCS,
      LO_SAPUSER       TYPE REF TO CL_SAPUSER_BCS,
      LO_EXTERNAL_USER TYPE REF TO CL_CAM_ADDRESS_BCS,
      LT_TEXT          TYPE SOLI_TAB,
      LWA_TEXT         TYPE SOLI,
      LO_DOCUMENT      TYPE REF TO CL_DOCUMENT_BCS,
      LV_SUBJECT       TYPE SO_OBJ_DES,
      LV_RESULT        TYPE OS_BOOLEAN.

DATA: LT_MESSAGE_BODY TYPE BCSY_TEXT,
      LS_MESSAGE_BODY TYPE SOLI,
      LR_DOCUMENT     TYPE REF TO CL_DOCUMENT_BCS,
      LR_SEND_REQUEST TYPE REF TO CL_BCS,
      LR_SENDER       TYPE REF TO CL_CAM_ADDRESS_BCS,
      LR_RECIPIENT    TYPE REF TO CL_CAM_ADDRESS_BCS,
      LV_SENDER       TYPE AD_SMTPADR,
      LV_RECEIVER     TYPE AD_SMTPADR,
      IT_PDF_DATA     TYPE SOLIX_TAB,
      LV_PDF_XSTRING  TYPE XSTRING,
*     LV_SUBJECT      TYPE SO_OBJ_DES.
      LX_BCS          TYPE REF TO CX_BCS.

DATA: LS_CONTROL_PARAMETERS TYPE SSFCTRLOP,
      LS_OUTPUT_OPTIONS     TYPE SSFCOMPOP,
      LS_JOB_OUTPUT_INFO    TYPE SSFCRESCL,
      LV_BIN_FILE           TYPE XSTRING,
      LT_PDF                TYPE TABLE OF TLINE.

DATA: I_OTF   TYPE ITCOO OCCURS 0 WITH HEADER LINE,
      I_TLINE TYPE TABLE OF TLINE WITH HEADER LINE.


INITIALIZATION.

  BTN_DISP = 'DISPLAY'.
  BTN_mail = 'SEND MAIL'.

AT SELECTION-SCREEN.
  CASE SY-UCOMM.
    WHEN 'DISP'.
      PERFORM SMARTFORM_DISPLAY .

    WHEN 'MAIL'.
      PERFORM MAIL_SEND.

  ENDCASE.


  DATA: LT_DTEXT              TYPE TSFTEXT,
        LS_DTEXT              TYPE TLINE,
        LS_CONTROL_PARAMETERS TYPE SSFCTRLOP,
        LS_OUTPUT_OPTIONS     TYPE SSFCOMPOP,
        LS_OUTPUT_INFO        TYPE SSFCRESCL,
        LT_LINES              TYPE TABLE OF TLINE,
        LS_JOB_OUTPUT_INFO    TYPE SSFCRESCL,
        LT_LINES_PDF          TYPE TABLE OF TLINE.


  """""""""""""""""""""""""""""""""SELECT QUERIES""""""""""""""""""""""""""""""""""""""""""

  "VBAK

  SELECT SINGLE
         VBELN,
         ERDAT,
         KNUMV
  FROM VBAK
  INTO @DATA(LS_VBAK)
  WHERE VBELN = @P_VBELN.



  "SOLD TO ADDRESS

  SELECT SINGLE ADRNR
  FROM VBPA
  INTO @DATA(LV_ADRNR)
  WHERE VBELN = @P_VBELN
  AND PARVW = 'AG'.



  "ADDRESS DETAILS

  SELECT SINGLE
         NAME1,
         STREET,
    STR_SUPPL1,
    STR_SUPPL2,
    STR_SUPPL3,
    CITY1,
    COUNTRY,
         REGION
  FROM ADRC
  INTO @DATA(LS_ADRC)
  WHERE ADDRNUMBER = @LV_ADRNR.



  """"""""""""""""""""""""ITEM + DESCRIPTION + HSN""""""""""""""""""""""""""""""""

  SELECT DISTINCT
        VBAP~MATNR,
        VBAP~KWMENG,
        VBAP~UMVKZ,
        MAKT~MAKTX,
        MARC~STEUC
  FROM VBAP

  LEFT JOIN MAKT
  ON MAKT~MATNR = VBAP~MATNR
  AND MAKT~SPRAS = @SY-LANGU

  LEFT JOIN MARC
  ON MARC~MATNR = VBAP~MATNR

  INTO TABLE @DATA(LT_ITEM)

  WHERE VBAP~VBELN = @P_VBELN.



  """"""""""""""""""PRICING DATA""""""""""""""""""""""

  SELECT
        KSCHL,
        KWERT
  FROM PRCD_ELEMENTS
  INTO TABLE @DATA(LT_PRICE)
  WHERE KNUMV = @LS_VBAK-KNUMV.




  """""""""""""""""""""""""""""""HEADER MOVE""""""""""""""""""""""""""""""""""""


  GS_HEADER-DATE    = LS_VBAK-ERDAT.
  GS_HEADER-VBELN = LS_VBAK-VBELN.
  GS_HEADER-KNUMV   = LS_VBAK-KNUMV.

  GS_HEADER-NAME1   = LS_ADRC-NAME1.
  GS_HEADER-STREET  = LS_ADRC-STREET.
  GS_HEADER-STR_SUPP1 = LS_ADRC-STR_SUPPL1.
  GS_HEADER-STR_SUPPL2 = LS_ADRC-STR_SUPPL2.
  GS_HEADER-STR_SUPPL3 = LS_ADRC-STR_SUPPL3.
  GS_HEADER-CITY    = LS_ADRC-CITY1.
  GS_HEADER-COUNTRY = LS_ADRC-COUNTRY.
  GS_HEADER-REGION  = LS_ADRC-REGION.



  """"""""""""""""""""""""""""""""""ITEM MOVE """"""""""""""""""""""""""""""""""""""""""""
  CLEAR LV_SRNO.

  LOOP AT LT_ITEM INTO DATA(LS_ITEM).


    CLEAR GS_ITEM.
    LV_SRNO = LV_SRNO + 1.

    GS_ITEM-SRNO = LV_SRNO.

    GS_ITEM-MATNR = LS_ITEM-MATNR.

    GS_ITEM-MAKTX = LS_ITEM-MAKTX.

    "NO OF PACKAGES

    GS_ITEM-PACKAGE = LS_ITEM-UMVKZ.

    "TOTAL PCS QTY

    GS_ITEM-TOTAL_QTY = LS_ITEM-KWMENG * LS_ITEM-UMVKZ.

    "HSN

    GS_ITEM-HSN = LS_ITEM-STEUC.

    "LOCATION

    GS_ITEM-LOCATION = LS_ADRC-CITY1.


*  "PRICE CALCULATION
*
*  LOOP AT LT_PRICE INTO DATA(LS_PRICE).
*
*    CASE LS_PRICE-KSCHL.
*
*      WHEN 'ZASV'.
*
*        GS_ITEM-BASIC_PRICE =
*        GS_ITEM-BASIC_PRICE +
*        LS_PRICE-KWERT.
*
*
*      WHEN 'JOIG'
*        OR 'JOSC'
*        OR 'JOCG'
*        OR 'JOUG'.
*
*        GS_ITEM-GST =
*        GS_ITEM-GST +
*        LS_PRICE-KWERT.

    GS_ITEM-BASIC_PRICE = 10.
    GS_ITEM-GST = 20.
    GS_ITEM-TOTAL_PRICE = 30.


*  ENDLOOP.
*  GS_ITEM-TOTAL_PRICE = GS_ITEM-BASIC_PRICE + GS_ITEM-GST.



    APPEND GS_ITEM TO GT_ITEM.


  ENDLOOP.

  "Total Calculation"
  CLEAR GS_ITEM.
  LOOP AT GT_ITEM INTO GS_ITEM.
    LV_BASIC_TOTAL = LV_BASIC_TOTAL + GS_ITEM-BASIC_PRICE.
    LV_GST_TOTAL = LV_GST_TOTAL + GS_ITEM-GST.
    LV_PRICE_TOTAL = LV_PRICE_TOTAL + GS_ITEM-TOTAL_PRICE.

    LV_QTY_TOTAL   = LV_QTY_TOTAL + GS_ITEM-TOTAL_QTY.


  ENDLOOP.

  CLEAR GS_ITEM.

  GS_ITEM-MAKTX = 'TOTAL'.
  GS_ITEM-SRNO = ''.
  GS_ITEM-TOTAL_QTY = LV_QTY_TOTAL.
  GS_ITEM-BASIC_PRICE = LV_BASIC_TOTAL.
  GS_ITEM-GST = LV_GST_TOTAL.
  GS_ITEM-TOTAL_PRICE = LV_PRICE_TOTAL.

  APPEND GS_ITEM TO GT_ITEM.

*                         SMARTFORM CALL

*
*CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
*  EXPORTING
*    FORMNAME = 'ZSMART_SALES_QUOTATION'
*  IMPORTING
*    FM_NAME  = LV_FM.
*
*LS_CONTROL_PARAMETERS-NO_DIALOG = 'X'.
*LS_CONTROL_PARAMETERS-PREVIEW = 'X'.
*LS_CONTROL_PARAMETERS-GETOTF = 'X'.
*LS_OUTPUT_OPTIONS-TDDEST = 'LP01'.
*
**CALL FUNCTION LV_FM
*
*
*
*CALL FUNCTION LV_FM
*  EXPORTING
**   ARCHIVE_INDEX      =
**   ARCHIVE_INDEX_TAB  =
**   ARCHIVE_PARAMETERS =
*    CONTROL_PARAMETERS = LS_CONTROL_PARAMETERS
**   MAIL_APPL_OBJ      =
**   MAIL_RECIPIENT     =
**   MAIL_SENDER        =
*    OUTPUT_OPTIONS     = LS_OUTPUT_OPTIONS
*    USER_SETTINGS      = ''
*    IS_HEADER          = GS_HEADER
*  IMPORTING
**   DOCUMENT_OUTPUT_INFO       =
*    JOB_OUTPUT_INFO    = LS_JOB_OUTPUT_INFO
**   JOB_OUTPUT_OPTIONS =
*  TABLES
*    IT_ITEM            = GT_ITEM
*  EXCEPTIONS
*    FORMATTING_ERROR   = 1
*    INTERNAL_ERROR     = 2
*    SEND_ERROR         = 3
*    USER_CANCELED      = 4
*    OTHERS             = 5.
*IF SY-SUBRC <> 0.
** Implement suitable error handling here
*ENDIF.
*
*CALL FUNCTION 'CONVERT_OTF'
*  EXPORTING
*    FORMAT                = 'PDF'
**   MAX_LINEWIDTH         = 132
**   ARCHIVE_INDEX         = ' '
**   COPYNUMBER            = 0
**   ASCII_BIDI_VIS2LOG    = ' '
**   PDF_DELETE_OTFTAB     = ' '
**   PDF_USERNAME          = ' '
**   PDF_PREVIEW           = ' '
**   USE_CASCADING         = ' '
**   MODIFIED_PARAM_TABLE  =
*  IMPORTING
**   BIN_FILESIZE          =
*    BIN_FILE              = LV_FILE
*  TABLES
*    OTF                   = LS_JOB_OUTPUT_INFO-OTFDATA
*    LINES                 = LT_LINES_PDF
*  EXCEPTIONS
*    ERR_MAX_LINEWIDTH     = 1
*    ERR_FORMAT            = 2
*    ERR_CONV_NOT_POSSIBLE = 3
*    ERR_BAD_OTF           = 4
*    OTHERS                = 5.
*IF SY-SUBRC <> 0.
** Implement suitable error handling here
*ENDIF.
*
*IF LS_JOB_OUTPUT_INFO-OTFDATA IS INITIAL.
*  MESSAGE 'No OTF data generated' TYPE 'E'.
*ENDIF.
*
*""""""""""""Convert the Bin_File from XString format to Binary format"""""""""""""""
*
*CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
*  EXPORTING
*    BUFFER     = LV_FILE
**   APPEND_TO_TABLE       = ' '
** IMPORTING
**   OUTPUT_LENGTH         =
*  TABLES
*    BINARY_TAB = LT_BINARY_TAB.   "This internal table contains content which we want to send through mail
*
*IF LT_BINARY_TAB IS INITIAL.
*  MESSAGE 'Binary table empty' TYPE 'E'.
*ENDIF.
*
*
*
*
*""""""""""""""""""""""Create send request(Compose Mail)""""""""""""""""""""""""""""
*
*TRY.
*    CALL METHOD CL_BCS=>CREATE_PERSISTENT
*      RECEIVING
*        RESULT = LO_BCS.
*  CATCH CX_SEND_REQ_BCS.
*ENDTRY.
*
*
*TRY.
*    CALL METHOD CL_SAPUSER_BCS=>CREATE
*      EXPORTING
*        I_USER = 'INT_IRAMNAAZ'
*      RECEIVING
*        RESULT = LO_SAPUSER.
*  CATCH CX_ADDRESS_BCS.
*ENDTRY.
*
*
*
*"""""""""""""""""Add Recipients""""""""""""""""
*
*TRY.
*    CALL METHOD LO_BCS->ADD_RECIPIENT
*      EXPORTING
*        I_RECIPIENT = LO_SAPUSER
**       I_EXPRESS   =
**       I_COPY      =
**       I_BLIND_COPY =
**       I_NO_FORWAD =
*      .
*  CATCH CX_SEND_REQ_BCS.
*ENDTRY.
*
*
*
*
*
*
*
*"""""""""""""""""""""""""Create External user"""""""""""""""""""""""""""""
*
*TRY.
*    CALL METHOD CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS
*      EXPORTING
*        I_ADDRESS_STRING = 'shaikhiramnaaz04@gmail.com'
**       I_ADDRESS_NAME   =
**       I_INCL_SAPUSER   =
*      RECEIVING
*        RESULT           = LO_EXTERNAL_USER.
*  CATCH CX_ADDRESS_BCS.
*ENDTRY.
*
*
*
*
*"""""""""""""""""Add Recipients for external user""""""""""""""""
*
*TRY.
*    CALL METHOD LO_BCS->ADD_RECIPIENT
*      EXPORTING
*        I_RECIPIENT = LO_EXTERNAL_USER
**       I_EXPRESS   =
**       I_COPY      =
**       I_BLIND_COPY =
**       I_NO_FORWAD =
*      .
*  CATCH CX_SEND_REQ_BCS.
*ENDTRY.
*
*
*"""""insert data to lt_text internal table"""""
*LWA_TEXT-LINE = TEXT-001.
*APPEND LWA_TEXT TO LT_TEXT.
*CLEAR: LWA_TEXT.
*
*LWA_TEXT-LINE = TEXT-002.
*APPEND LWA_TEXT TO LT_TEXT.
*CLEAR: LWA_TEXT.
*
*LWA_TEXT-LINE = TEXT-003.
*APPEND LWA_TEXT TO LT_TEXT.
*CLEAR: LWA_TEXT.
*
*LWA_TEXT-LINE = TEXT-004.
*APPEND LWA_TEXT TO LT_TEXT.
*CLEAR: LWA_TEXT.
*
*"""""""""""Create Document(Subject)"""""""""""""""
*TRY.
*    CALL METHOD CL_DOCUMENT_BCS=>CREATE_DOCUMENT
*      EXPORTING
*        I_TYPE    = 'RAW'
*        I_SUBJECT = TEXT-000 " 'Sales Quoatation'
**       I_LENGTH  =
**       I_LANGUAGE      = SPACE
**       I_IMPORTANCE    =
**       I_SENSITIVITY   =
*        I_TEXT    = LT_TEXT
**       I_HEX     =
**       I_HEADER  =
**       I_SENDER  =
**       IV_VSI_PROFILE  =
**       IV_VSI_SCAN_OFF =
*      RECEIVING
*        RESULT    = LO_DOCUMENT.
*  CATCH CX_DOCUMENT_BCS.
*ENDTRY.
*
*
*
*CONCATENATE TEXT-005 P_VBELN INTO LV_SUBJECT.
*
*
*IF LT_BINARY_TAB IS INITIAL.
*  MESSAGE 'PDF binary is empty' TYPE 'E'.
*ENDIF.
*"""""""""""""""""Add attachment""""""""""""""
*TRY.
*    CALL METHOD LO_DOCUMENT->ADD_ATTACHMENT
*      EXPORTING
*        I_ATTACHMENT_TYPE    = 'PDF'
*        I_ATTACHMENT_SUBJECT = LV_SUBJECT
**        I_ATTACHMENT_SIZE    = XSTRLEN( LV_FILE )
**       I_ATTACHMENT_LANGUAGE = SPACE
**       I_ATT_CONTENT_TEXT   =
*        I_ATT_CONTENT_HEX    = LT_BINARY_TAB
**       I_ATTACHMENT_HEADER  =
**       IV_VSI_PROFILE       =
**       IV_VSI_SCAN_OFF      =
**       I_ATTACHMENT_FILENAME =
*      .
*  CATCH CX_DOCUMENT_BCS.
*ENDTRY.
*
*
*
*
*
*"""""""""""""""Set the document""""""""""""""""""
*
*TRY.
*    CALL METHOD LO_BCS->SET_DOCUMENT
*      EXPORTING
*        I_DOCUMENT = LO_DOCUMENT.
*  CATCH CX_SEND_REQ_BCS.
*ENDTRY.
*
*
*
*
*
*
*
*"""""""""""""""""""Activate/deactivate immediate sending"""""""""""""""""""""
*TRY.
*    CALL METHOD LO_BCS->SET_SEND_IMMEDIATELY
*      EXPORTING
*        I_SEND_IMMEDIATELY = 'X'.
*  CATCH CX_SEND_REQ_BCS.
*ENDTRY.
*
*
*
*
*
*
*"""""""""""""""""""Send""""""""""""""""""""""""
*TRY.
*    CALL METHOD LO_BCS->SEND
*      EXPORTING
*        I_WITH_ERROR_SCREEN = SPACE
*      RECEIVING
*        RESULT              = LV_RESULT.
*  CATCH CX_SEND_REQ_BCS.
*ENDTRY.
*





  """""""""""""""""Commit"""""""""""""""""""""""

*CALL FUNCTION 'GUI_DOWNLOAD'
*  EXPORTING
**   BIN_FILESIZE            =
*    FILENAME                = 'C:\Users\iramnaaz\OneDrive - Abhiyanta India Solutions Pvt Ltd\Desktop\sales.PDF'
*    FILETYPE                = 'BIN'
**   APPEND                  = ' '
**   WRITE_FIELD_SEPARATOR   = ' '
**   HEADER                  = '00'
**   TRUNC_TRAILING_BLANKS   = ' '
**   WRITE_LF                = 'X'
**   COL_SELECT              = ' '
**   COL_SELECT_MASK         = ' '
**   DAT_MODE                = ' '
**   CONFIRM_OVERWRITE       = ' '
**   NO_AUTH_CHECK           = ' '
**   CODEPAGE                = ' '
**   IGNORE_CERR             = ABAP_TRUE
**   REPLACEMENT             = '#'
**   WRITE_BOM               = ' '
**   TRUNC_TRAILING_BLANKS_EOL       = 'X'
**   WK1_N_FORMAT            = ' '
**   WK1_N_SIZE              = ' '
**   WK1_T_FORMAT            = ' '
**   WK1_T_SIZE              = ' '
**   WRITE_LF_AFTER_LAST_LINE        = ABAP_TRUE
**   SHOW_TRANSFER_STATUS    = ABAP_TRUE
**   VIRUS_SCAN_PROFILE      = '/SCET/GUI_DOWNLOAD'
** IMPORTING
**   FILELENGTH              =
*  TABLES
*    DATA_TAB                = LT_LINES_PDF
**   FIELDNAMES              =
*  EXCEPTIONS
*    FILE_WRITE_ERROR        = 1
*    NO_BATCH                = 2
*    GUI_REFUSE_FILETRANSFER = 3
*    INVALID_TYPE            = 4
*    NO_AUTHORITY            = 5
*    UNKNOWN_ERROR           = 6
*    HEADER_NOT_ALLOWED      = 7
*    SEPARATOR_NOT_ALLOWED   = 8
*    FILESIZE_NOT_ALLOWED    = 9
*    HEADER_TOO_LONG         = 10
*    DP_ERROR_CREATE         = 11
*    DP_ERROR_SEND           = 12
*    DP_ERROR_WRITE          = 13
*    UNKNOWN_DP_ERROR        = 14
*    ACCESS_DENIED           = 15
*    DP_OUT_OF_MEMORY        = 16
*    DISK_FULL               = 17
*    DP_TIMEOUT              = 18
*    FILE_NOT_FOUND          = 19
*    DATAPROVIDER_EXCEPTION  = 20
*    CONTROL_FLUSH_ERROR     = 21
*    OTHERS                  = 22.
*IF SY-SUBRC <> 0.
** Implement suitable error handling here
*ENDIF.

FORM SMARTFORM_DISPLAY.
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME           = 'ZSMART_SALES_QUOTATION'
*     VARIANT            = ' '
*     DIRECT_CALL        = ' '
    IMPORTING
      FM_NAME            = LV_FM
    EXCEPTIONS
      NO_FORM            = 1
      NO_FUNCTION_MODULE = 2
      OTHERS             = 3.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.


  LS_CONTROL_PARAMETERS-NO_DIALOG = 'X'.
  LS_CONTROL_PARAMETERS-PREVIEW = 'X'.
  ls_control_parameters-getotf = 'X'.

  CALL FUNCTION LV_FM
    EXPORTING
      CONTROL_PARAMETERS = LS_CONTROL_PARAMETERS
      IS_HEADER          = GS_HEADER
    TABLES
      IT_ITEM            = GT_ITEM.

ENDFORM.

FORM MAIL_SEND.


  DATA: LS_CTRL TYPE SSFCTRLOP,
        LS_OUT  TYPE SSFCOMPOP.


  "Get Smartform FM

  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      FORMNAME = 'ZSMART_SALES_QUOTATION'
    IMPORTING
      FM_NAME  = LV_FM.


  IF SY-SUBRC <> 0.
    MESSAGE 'Smartform FM not found' TYPE 'E'.
  ENDIF.



  "Generate OTF

  LS_CTRL-NO_DIALOG = 'X'.
  LS_CTRL-GETOTF = 'X'.


  CALL FUNCTION LV_FM
    EXPORTING
      CONTROL_PARAMETERS = LS_CTRL
      OUTPUT_OPTIONS     = LS_OUT
      IS_HEADER          = GS_HEADER
    IMPORTING
      JOB_OUTPUT_INFO    = LS_JOB_OUTPUT_INFO
    TABLES
      IT_ITEM            = GT_ITEM.



  IF LS_JOB_OUTPUT_INFO-OTFDATA IS INITIAL.
    MESSAGE 'OTF not generated' TYPE 'E'.
  ENDIF.



  "OTF to PDF XSTRING

  CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      FORMAT   = 'PDF'
    IMPORTING
      BIN_FILE = LV_BIN_FILE
    TABLES
      OTF      = LS_JOB_OUTPUT_INFO-OTFDATA
      LINES    = LT_PDF
    EXCEPTIONS
      OTHERS   = 1.


  IF LV_BIN_FILE IS INITIAL.
    MESSAGE 'PDF not generated' TYPE 'E'.
  ENDIF.


  "XSTRING to Binary

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      BUFFER     = LV_BIN_FILE
    TABLES
      BINARY_TAB = LT_BINARY_tab.



  IF LT_BINARY_tab IS INITIAL.
    MESSAGE 'Attachment is empty' TYPE 'E'.
  ENDIF.



  "Mail Body

  CLEAR LS_MESSAGE_BODY.

  LS_MESSAGE_BODY-LINE = 'Dear Sir/Madam,'.
  APPEND LS_MESSAGE_BODY TO LT_MESSAGE_BODY.


  CLEAR LS_MESSAGE_BODY.

  LS_MESSAGE_BODY-LINE = 'Please find quotation attached.'.
  APPEND LS_MESSAGE_BODY TO LT_MESSAGE_BODY.


  CLEAR LS_MESSAGE_BODY.

  LS_MESSAGE_BODY-LINE = 'Regards'.
  APPEND LS_MESSAGE_BODY TO LT_MESSAGE_BODY.



  "Create mail

  LR_SEND_REQUEST = CL_BCS=>CREATE_PERSISTENT( ).



  LO_DOCUMENT = CL_DOCUMENT_BCS=>CREATE_DOCUMENT(
                  I_TYPE = 'RAW'
                  I_TEXT = LT_MESSAGE_BODY
                  I_SUBJECT = 'Sales Quotation' ).





  "Add PDF Attachment

  LO_DOCUMENT->ADD_ATTACHMENT(
   EXPORTING
     I_ATTACHMENT_TYPE    = 'PDF'
     I_ATTACHMENT_SUBJECT = 'Quotation.pdf'
     I_ATT_CONTENT_HEX    = LT_BINARY_tab ).





  LR_SEND_REQUEST->SET_DOCUMENT(
    LO_DOCUMENT ).





  "Receiver

  LR_RECIPIENT =
  CL_CAM_ADDRESS_BCS=>CREATE_INTERNET_ADDRESS(
  'shaikhiramnaaz04@gmail.com' ).





  LR_SEND_REQUEST->ADD_RECIPIENT(
   LR_RECIPIENT ).





  "Send

  LV_RESULT = LR_SEND_REQUEST->SEND( ).

  COMMIT WORK.



  IF LV_RESULT = 'X'.

    MESSAGE 'Mail sent successfully' TYPE 'S'.

  ENDIF.


ENDFORM.
