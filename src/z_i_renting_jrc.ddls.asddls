@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AbapCatalog.sqlViewName: 'ZV_RENT_JRC'

@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: 'Renting'

@Metadata.allowExtensions: true

define view Z_I_RENTING_JRC
  as select from Z_B_CARS_JRC as Cars

  association [1] to    Z_B_REM_DAYS_JRC     as _RemDays     on Cars.Matricula = _RemDays.Matricula
  association [0..*] to Z_B_BRANDS_JRC       as _Brands      on Cars.Marca = _Brands.Marca
  association [0..*] to z_b_det_customer_jrc as _DetCustomer on Cars.Matricula = _DetCustomer.Matricula

{
  key Cars.Matricula,

      Cars.Marca,
      Cars.Modelo,
      Cars.Color,
      Cars.Motor,
      Cars.Potencia,
      Cars.Unidad,
      Cars.Combustible,
      Cars.Consumo,
      Cars.FechaFabricacion,
      Cars.Puertas,
      Cars.Precio,
      Cars.Moneda,
      Cars.Alquilado,
      Cars.Desde,
      Cars.Hasta,

      // 0 neutral grey
      // 1 negative red
      // 2 critical yellow
      // 3 positive green
      case
      when _RemDays.Dias <= 0 then 0
      when _RemDays.Dias between 1 and 30 then 1
      when _RemDays.Dias between 31 and 100 then 2
      when _RemDays.Dias > 100 then 3
      else 0
      end                    as TiempoRenta,

      ''                     as Estado,
      _Brands.Imagen,

      _DetCustomer
}
