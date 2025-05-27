@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AbapCatalog.sqlViewName: 'ZV_ACCATEG_JRC'

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Datos de Categorias'

@Metadata.ignorePropagatedAnnotations: true

define view Z_B_ACC_CATEG_JRC
  as select from ztb_acc_categ_jr as acc_categ

  association [1] to Z_B_CATEGO_JRC as _CATEGO on _CATEGO.BiCateg = $projection.BiCateg

{
      @ObjectModel.text.element: [ 'Descripcion' ]
  key bi_categ            as BiCateg,

      @UI.hidden: true
  key tipo_acceso         as TipoAcceso,

      _CATEGO.Descripcion as Descripcion
}
