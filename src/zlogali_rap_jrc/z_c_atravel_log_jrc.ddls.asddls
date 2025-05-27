@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: 'Consumption - Travel Aprobal'

@Metadata.allowExtensions: true

define root view entity Z_C_ATRAVEL_LOG_JRC
  as projection on Z_I_TRAVEL_LOG_JRC

{
  key TravelId,

      @ObjectModel.text.element: [ 'AgencyName' ]
      AgencyId,

      _Agency.Name       as AgencyName,

      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,

      _Customer.LastName as CustomerName,
      BeginDate,
      EndDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,

      @Semantics.user.createdBy: true
      CurrencyCode,

      Description,
      OverallStatus      as TravelStatus,
      LastChangedAt,
      /* Associations */
      _Booking : redirected to composition child Z_C_ABOOKING_LOG_JRC,

      _Customer
}
