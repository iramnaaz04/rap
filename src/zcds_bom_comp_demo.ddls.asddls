@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCDS_BOM_COMP_DEMO
    
  with parameters
    p_aufnr : aufnr, //abap.char(12),   //Production Order  (AUFNR length)
    p_matnr : matnr, //abap.char(18),   //Finished Material  (MATNR length, 18 for S/4HANA)
    p_werks : werks_d,  // abap.char(4),    //Plant               (WERKS_D length)
    p_date  : erdat //abap.dats        //Date

  as select from aufk  //Production Header Table

  inner join afko
    on aufk.aufnr = afko.aufnr

  inner join resb
    on aufk.aufnr = resb.aufnr

  left outer join mseg
    on  mseg.aufnr = resb.aufnr
    and mseg.matnr = resb.matnr

  left outer join makt
    on  makt.matnr = resb.matnr
    and makt.spras = $session.system_language

  left outer join jest
    on  jest.objnr = aufk.objnr

{
  key aufk.aufnr                  as ProductionOrder,
      afko.plnbez                 as FinishedMaterial,
      aufk.werks                  as Plant,
      jest.stat                   as OrderStatus,
      resb.matnr                  as ComponentMaterial,
      makt.maktx                  as ComponentDescription,

      //@Semantics.unitOfMeasure: true
      resb.meins                  as UoM,

      @Semantics.quantity.unitOfMeasure: 'UoM'
      resb.bdmng                  as PlannedQty,

      @Semantics.quantity.unitOfMeasure: 'UoM'
      mseg.menge                  as ActualQtyIssued,

      @Semantics.quantity.unitOfMeasure: 'UoM'
      ( mseg.menge - resb.bdmng ) as Variance,

      case
        when resb.bdmng <> 0
          then cast( ( ( mseg.menge - resb.bdmng ) / resb.bdmng ) * 100 as abap.dec( 15, 2 ) )
        else cast( 0 as abap.dec( 15, 2 ) )
      end                          as VariancePercent,

      case
        when mseg.menge =  resb.bdmng then 'MATCH'
        when mseg.menge >  resb.bdmng then 'OVER ISSUE'
        when mseg.menge <  resb.bdmng then 'UNDER ISSUE'
        else 'NOT ISSUED'
      end                          as ConsumptionStatus,

      mseg.budat_mkpf              as PostingDate,

      $session.system_date         as SystemDate,

      case
        when mseg.menge > resb.bdmng then 'Extra Consumption'
        else 'OK'
      end                          as Remarks

}

where
      aufk.aufnr  = $parameters.p_aufnr
 // and afko.plnbez = $parameters.p_matnr
  and aufk.werks  = $parameters.p_werks
