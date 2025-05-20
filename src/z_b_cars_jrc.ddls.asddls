@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AbapCatalog.sqlViewName: 'ZV_CARS_JRC'

@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: 'Cars'

@Metadata.ignorePropagatedAnnotations: true

define view Z_B_CARS_JRC
  as select from zrent_cars_jrc

{
  key matricula    as Matricula,

      marca        as Marca,
      modelo       as Modelo,
      color        as Color,
      motor        as Motor,
      potencia     as Potencia,
      und_potencia as Unidad,
      combustible  as Combustible,
      consumo      as Consumo,
      fecha_fabr   as FechaFabricacion,
      puertas      as Puertas,
      precio       as Precio,
      moneda       as Moneda,
      alquilado    as Alquilado,
      alq_desde    as Desde,
      alq_hasta    as Hasta
}
