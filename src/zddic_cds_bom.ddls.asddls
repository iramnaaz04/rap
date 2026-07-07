@AbapCatalog.sqlViewName: 'ZVBOMCOMP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Data Dictionary based CDS View for BOM Comparison'
@Metadata.ignorePropagatedAnnotations: true
define view ZDDIC_CDS_BOM
//        with parameters
//        p_aufnr : aufnr,
//          p_matnr : matnr,                              //Finished Material
//     
//    p_werks : werks_d //Plant
    
as select from aufk                                    //Production Header Table

    inner join      afko   on aufk.aufnr = afko.aufnr       //Production Order Master Information Table
                                                            //To get the finished materials

    inner join      resb   on aufk.aufnr = resb.aufnr       //Stores all the planned BOM Components and their planned quantities
                           and resb.bwart = '261'
    inner join matdoc on  matdoc.aufnr = resb.aufnr    //Matdoc stores actual material movements in S/4HANA
                           and matdoc.matnr = resb.matnr
                           and matdoc.bwart = '261'         //Good Issue to Production Order
                           //Raw materials have been issued from warehouse to a production order for manufacturing.

  //    left outer join     mkpf   on matdoc.mblnr  =  mkpf.mblnr
  //                           and mkpf.mjahr = matdoc.mjahr




    left outer join makt   on  makt.matnr = resb.matnr     //Stores description
                           and makt.spras = $session.system_language


    left outer join jest   on jest.objnr = aufk.objnr                //Stores Production Order Status.
                           and jest.stat = 'I0002'
                           and jest.inact = ''
                           
    left outer join tj02t  on tj02t.istat = jest.stat
                           and tj02t.spras = $session.system_language
                           
//    left outer join mkpf   on  mkpf.mblnr = matdoc.mblnr
//                           and mkpf.mjahr = matdoc.mjahr



{

  key aufk.aufnr           as ProductionOrder,
      aufk.werks           as Plant,
      afko.plnbez          as FinishedMaterial,
      tj02t.txt30          as OrderStatus,
      resb.matnr           as ComponentMaterial,
      makt.maktx           as ComponentDescription,



      @Semantics.quantity.unitOfMeasure: 'UOM'
      resb.bdmng           as PlannedQty,


      //       @Semantics.unitOfMeasure
      resb.meins           as UOM,

      //        resb.meins as UOM,
      //        resb.bdmng as PlannedQty,
      
      
      @Semantics.quantity.unitOfMeasure: 'UOM2'
      matdoc.menge         as ActualQtyIssued,

      resb.meins           as UOM2,



      cast(
          case
              when resb.bdmng <> 0

              then
            (
              cast( matdoc.menge as abap.fltp ) /
              cast( resb.bdmng as abap.fltp  )
            ) * cast( 100 as abap.fltp )

          else cast( 0 as abap.fltp )

        end
        as abap.fltp
      )                    as GRRate,

      case
          when matdoc.menge = resb.bdmng  //bdmng = requirement quantity or Planned Quantity
          then 'MATCH'

          when matdoc.menge > resb.bdmng
          then 'OVER ISSUE'

          when matdoc.menge < resb.bdmng
          then 'UNDER ISSUE'

          else 'NOT ISSUED'
      end                  as ConsumptionStatus,
      
      

      // cast(mkpf.budat as dats) as PostingDate,
      
      
      matdoc.budat           as PostingDate,
      matdoc.vgart           as event_type,
      //mkpf.blaum               as doc_type,
      matdoc.bwart         as MovementType,
      matdoc.mblnr         as MaterialDocument,
      matdoc.mjahr         as MaterialDocYear,

      matdoc.mblnr           as MKPFDocument,
      matdoc.mjahr           as MKPFYear,

      $session.system_date as SystemDate,



      case

      when matdoc.menge is null
      then 'Not yet issued - stock shortage?'

      when matdoc.menge = resb.bdmng
      then 'Exact match'

      when matdoc.menge > resb.bdmng
      then 'Over-issue - scrap loss'

      when matdoc.menge < resb.bdmng
      then 'Under-issue - partial GI pending'

      else 'Review Required'

      end                  as Remarks,

      resb.meins           as UOM3


}

//where
//      aufk.aufnr = $parameters.p_aufnr
//
//  and afko.plnbez = $parameters.p_matnr
//
//  and aufk.werks = $parameters.p_werks
