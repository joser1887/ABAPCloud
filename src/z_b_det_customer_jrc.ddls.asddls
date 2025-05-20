@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AbapCatalog.sqlViewName: 'ZV_DET_CUST_JRC'

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Details Customers'

@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true

define view z_b_det_customer_jrc
  as select from zrent_client_jrc

{
  key doc_id    as ID,
  key matricula as Matricula,

      nombres   as Nombre,
      apellidos as Apellidos,
      email     as Correo,
      cntr_type as TipoContrato
}
