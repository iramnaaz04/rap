@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Second CDS View'
@Metadata.ignorePropagatedAnnotations: true
define view entity zcds_second
  as select from makt
{
  key spras as language,
  key matnr as material,
      maktx as mat_description,
      maktg as mat_desc_match
}

  
