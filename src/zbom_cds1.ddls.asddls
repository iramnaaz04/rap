@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOM Comparison CDS Basics'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZBOM_CDS1
 as select from stpo inner join stko
 on stpo.stlnr = stko.stlnr
 
 inner join mast
 on mast.stlnr = stko.stlnr
 
{
    key mast.matnr as Material,
    key mast.werks as Plant,
    key stpo.stlkn as ItemNode,
    
    stko.stlnr as BOMNumber,
    stko.stlal as AlternativeBOM,
    
    stpo.posnr as ItemNumber,
    stpo.idnrk as Component,
    
    @Semantics.quantity.unitOfMeasure: 'UOM'
    stpo.menge as ComponentQty,
    
//    @Semantics.unitOfMeasure: true
    stpo.meins as UOM,
    
    stpo.postp as ItemCategory
}
