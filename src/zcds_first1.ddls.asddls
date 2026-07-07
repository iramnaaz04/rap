@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'My first CDS View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCDS_First1
 as select from mara
 association [0..*] to marc as _plant
 on mara.matnr = _plant.matnr
{
    key matnr as material,
    ernam as created_by,
    ersda as created_on,
    mtart as material_type,
    matkl as material_group,
    _plant //expose for navigation
}
    where mtart = 'FERT'
