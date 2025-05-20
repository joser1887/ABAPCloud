@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AbapCatalog.sqlViewName: 'ZV_BRANDS_JRC'

@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: 'Brands'

@Metadata.ignorePropagatedAnnotations: true

define view Z_B_BRANDS_JRC
  as select from zrent_brands_jrc

{
  key marca as Marca,

      @UI.hidden: true
      url   as Imagen
}
