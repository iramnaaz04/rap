@AbapCatalog.sqlViewName: 'ZSQLVIEW_SALES'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Dictionary based CDS View'
@Metadata.ignorePropagatedAnnotations: true
define view ZCDS_DDIC_Sales as select from vbak
{
  key  vbak.vbeln , vbak.erdat
}
