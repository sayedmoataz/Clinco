
// create paymob account 
// settings => APIKEY 
const String paymobApiKey = "ZXlKMGVYQWlPaUpLVjFRaUxDSmhiR2NpT2lKSVV6VXhNaUo5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2libUZ0WlNJNkltbHVhWFJwWVd3aUxDSndjbTltYVd4bFgzQnJJam8xTVRNMU1UZDkua2ZjTVFMRF9yaVFkd1NHNlJ5MjV0N3EzekptZnVLTXhXeDVnbmg5eXNQNnlHZTd5aUwtbm1tTWRIOEtxRHRmNFRVNXJKQ3pDWmhKMWdyT3EtZ3FxM1E=";

// developes => payment integration
const String IntegrationIDCard = "2806829";

const String IntegrationIDKiosk = "2916727";

// get it from getAuthToken() 
String authToken ="";

// get it from getOrderID()
String orderID = "";

// get it from getPaymentKey()
String paymentToken = "";


// get it from getKioskKey()
String kioskID = "";

// price for each item
int price = 0;

// multiple price by 100 to conver it from cent to EGP 
// use it as a String
int priceInCents = price *100;

String iFrameLink = "https://accept.paymob.com/api/acceptance/iframes/678223?payment_token=$paymentToken";

String pending = '';

String success = "";