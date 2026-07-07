@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOM Comparison CDS on top of existing CDS'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_CDS_BOM_DIFF as select from ZBOM_CDS1
{
    key Material,
    key Plant,
    
    BOMNumber,
    AlternativeBOM,
    
    ItemNumber,
    Component,
    
    @Semantics.quantity.unitOfMeasure: 'UOM'
    ComponentQty,
    UOM,
    
    case
    when ComponentQty = 0
    then 'CHECK'
    else 'ACTIVATE'
    end as BOMStatus    
}
