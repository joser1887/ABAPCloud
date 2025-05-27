@AbapCatalog.sqlViewName: 'ZV_CATEGO_JRC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Categorias de Libros'
@Metadata.ignorePropagatedAnnotations: true
define view Z_B_CATEGO_JRC as select from ztb_catego_jrc
{
    key bi_categ as BiCateg,
    descripcion as Descripcion
}
