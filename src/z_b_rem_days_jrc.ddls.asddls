@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AbapCatalog.sqlViewName: 'ZV_REM_DAYS_JRC'

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Remaining days'

@Metadata.ignorePropagatedAnnotations: true

define view Z_B_REM_DAYS_JRC
  as select from zrent_cars_jrc

{
  key matricula as Matricula,

      marca     as Marca,

      case
      when alq_hasta > $session.system_date then
      dats_days_between(cast($session.system_date as abap.dats), alq_hasta)
      else 0 
      end       as Dias,
      alq_hasta as Alq_hasta
}
