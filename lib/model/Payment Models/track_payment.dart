class TrackTransaction {
  TrackTransaction({
    this.id,
    this.pending,
    this.amountCents,
    this.success,
    this.isAuth,
    this.isCapture,
    this.isStandalonePayment,
    this.isVoided,
    this.isRefunded,
    this.is3DSecure,
    this.integrationId,
    this.terminalId,
    this.terminalBranchId,
    this.hasParentTransaction,
    this.order,
    this.createdAt,
    this.paidAt,
    this.currency,
    this.sourceData,
    this.apiSource,
    this.fees,
    this.vat,
    this.convertedGrossAmount,
    this.data,
    this.isCashout,
    this.walletTransactionType,
    this.isUpg,
    this.isInternalRefund,
    this.billingData,
    this.installment,
    this.integrationType,
    this.cardType,
    this.routingBank,
    this.cardHolderBank,
    this.merchantCommission,
    this.extraDetail,
    this.discountDetails,
    this.preConversionCurrency,
    this.preConversionAmountCents,
    this.isHost2Host,
    this.installmentInfo,
    this.isVoid,
    this.isRefund,
    this.isHidden,
    this.errorOccured,
    this.isLive,
    this.otherEndpointReference,
    this.refundedAmountCents,
    this.sourceId,
    this.isCaptured,
    this.capturedAmount,
    this.merchantStaffTag,
    this.updatedAt,
    this.owner,
    this.parentTransaction,
  });

  dynamic id;
  dynamic pending;
  dynamic amountCents;
  dynamic success;
  dynamic isAuth;
  dynamic isCapture;
  dynamic isStandalonePayment;
  dynamic isVoided;
  dynamic isRefunded;
  dynamic is3DSecure;
  dynamic integrationId;
  dynamic terminalId;
  dynamic terminalBranchId;
  dynamic hasParentTransaction;
  Order? order;
  DateTime? createdAt;
  dynamic paidAt;
  dynamic currency;
  SourceData? sourceData;
  dynamic apiSource;
  dynamic fees;
  dynamic vat;
  dynamic convertedGrossAmount;
  TrackTransactionData? data;
  dynamic isCashout;
  dynamic walletTransactionType;
  dynamic isUpg;
  dynamic isInternalRefund;
  IngData? billingData;
  dynamic installment;
  dynamic integrationType;
  dynamic cardType;
  dynamic routingBank;
  dynamic cardHolderBank;
  dynamic merchantCommission;
  dynamic extraDetail;
  List<dynamic>? discountDetails;
  dynamic preConversionCurrency;
  dynamic preConversionAmountCents;
  dynamic isHost2Host;
  InstallmentInfo? installmentInfo;
  dynamic isVoid;
  dynamic isRefund;
  dynamic isHidden;
  dynamic errorOccured;
  dynamic isLive;
  dynamic otherEndpointReference;
  dynamic refundedAmountCents;
  dynamic sourceId;
  dynamic isCaptured;
  dynamic capturedAmount;
  dynamic merchantStaffTag;
  DateTime? updatedAt;
  dynamic owner;
  dynamic parentTransaction;

  factory TrackTransaction.fromJson(Map<String, dynamic>? json) => TrackTransaction(
    id: json?["id"],
    pending: json?["pending"],
    amountCents: json?["amount_cents"],
    success: json?["success"],
    isAuth: json?["is_auth"],
    isCapture: json?["is_capture"],
    isStandalonePayment: json?["is_standalone_payment"],
    isVoided: json?["is_voided"],
    isRefunded: json?["is_refunded"],
    is3DSecure: json?["is_3d_secure"],
    integrationId: json?["integration_id"],
    terminalId: json?["terminal_id"],
    terminalBranchId: json?["terminal_branch_id"],
    hasParentTransaction: json?["has_parent_transaction"],
    order: json?["order"] == null ? null : Order.fromJson(json?["order"]),
    createdAt: json?["created_at"] == null ? null : DateTime.parse(json?["created_at"]),
    paidAt: json?["paid_at"],
    currency: json?["currency"],
    sourceData: json?["source_data"] == null ? null : SourceData.fromJson(json?["source_data"]),
    apiSource: json?["api_source"],
    fees: json?["fees"],
    vat: json?["vat"],
    convertedGrossAmount: json?["converted_gross_amount"],
    data: json?["data"] == null ? null : TrackTransactionData.fromJson(json?["data"]),
    isCashout: json?["is_cashout"],
    walletTransactionType: json?["wallet_transaction_type"],
    isUpg: json?["is_upg"],
    isInternalRefund: json?["is_internal_refund"],
    billingData: json?["billing_data"] == null ? null : IngData.fromJson(json?["billing_data"]),
    installment: json?["installment"],
    integrationType: json?["integration_type"],
    cardType: json?["card_type"],
    routingBank: json?["routing_bank"],
    cardHolderBank: json?["card_holder_bank"],
    merchantCommission: json?["merchant_commission"],
    extraDetail: json?["extra_detail"],
    discountDetails: json?["discount_details"] == null ? null : List<dynamic>.from(json?["discount_details"].map((x) => x)),
    preConversionCurrency: json?["pre_conversion_currency"],
    preConversionAmountCents: json?["pre_conversion_amount_cents"],
    isHost2Host: json?["is_host2host"],
    installmentInfo: json?["installment_info"] == null ? null : InstallmentInfo.fromJson(json?["installment_info"]),
    isVoid: json?["is_void"],
    isRefund: json?["is_refund"],
    isHidden: json?["is_hidden"],
    errorOccured: json?["error_occured"],
    isLive: json?["is_live"],
    otherEndpointReference: json?["other_endpoint_reference"],
    refundedAmountCents: json?["refunded_amount_cents"],
    sourceId: json?["source_id"],
    isCaptured: json?["is_captured"],
    capturedAmount: json?["captured_amount"],
    merchantStaffTag: json?["merchant_staff_tag"],
    updatedAt: json?["updated_at"] == null ? null : DateTime.parse(json?["updated_at"]),
    owner: json?["owner"],
    parentTransaction: json?["parent_transaction"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "pending": pending,
    "amount_cents": amountCents,
    "success": success,
    "is_auth": isAuth,
    "is_capture": isCapture,
    "is_standalone_payment": isStandalonePayment,
    "is_voided": isVoided,
    "is_refunded": isRefunded,
    "is_3d_secure": is3DSecure,
    "integration_id": integrationId,
    "terminal_id": terminalId,
    "terminal_branch_id": terminalBranchId,
    "has_parent_transaction": hasParentTransaction,
    "order": order == null ? null : order!.toJson(),
    "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
    "paid_at": paidAt,
    "currency": currency,
    "source_data": sourceData == null ? null : sourceData!.toJson(),
    "api_source": apiSource,
    "fees": fees,
    "vat": vat,
    "converted_gross_amount": convertedGrossAmount,
    "data": data == null ? null : data!.toJson(),
    "is_cashout": isCashout,
    "wallet_transaction_type": walletTransactionType,
    "is_upg": isUpg,
    "is_internal_refund": isInternalRefund,
    "billing_data": billingData == null ? null : billingData!.toJson(),
    "installment": installment,
    "integration_type": integrationType,
    "card_type": cardType,
    "routing_bank": routingBank,
    "card_holder_bank": cardHolderBank,
    "merchant_commission": merchantCommission,
    "extra_detail": extraDetail,
    "discount_details": discountDetails == null ? null : List<dynamic>.from(discountDetails!.map((x) => x)),
    "pre_conversion_currency": preConversionCurrency,
    "pre_conversion_amount_cents": preConversionAmountCents,
    "is_host2host": isHost2Host,
    "installment_info": installmentInfo == null ? null : installmentInfo!.toJson(),
    "is_void": isVoid,
    "is_refund": isRefund,
    "is_hidden": isHidden,
    "error_occured": errorOccured,
    "is_live": isLive,
    "other_endpoint_reference": otherEndpointReference,
    "refunded_amount_cents": refundedAmountCents,
    "source_id": sourceId,
    "is_captured": isCaptured,
    "captured_amount": capturedAmount,
    "merchant_staff_tag": merchantStaffTag,
    "updated_at": updatedAt == null ? null : updatedAt!.toIso8601String(),
    "owner": owner,
    "parent_transaction": parentTransaction,
  };
}

class IngData {
  IngData({
    this.id,
    this.firstName,
    this.lastName,
    this.street,
    this.building,
    this.floor,
    this.apartment,
    this.city,
    this.state,
    this.country,
    this.email,
    this.phoneNumber,
    this.postalCode,
    this.ipAddress,
    this.extraDescription,
    this.transactionId,
    this.createdAt,
    this.shippingMethod,
    this.orderId,
    this.order,
  });

  dynamic id;
  dynamic firstName;
  dynamic lastName;
  dynamic street;
  dynamic building;
  dynamic floor;
  dynamic apartment;
  dynamic city;
  dynamic state;
  dynamic country;
  dynamic email;
  dynamic phoneNumber;
  dynamic postalCode;
  dynamic ipAddress;
  dynamic extraDescription;
  dynamic transactionId;
  DateTime? createdAt;
  dynamic shippingMethod;
  dynamic orderId;
  dynamic order;

  factory IngData.fromJson(Map<String, dynamic>? json) => IngData(
    id: json?["id"],
    firstName: json?["first_name"],
    lastName: json?["last_name"],
    street: json?["street"],
    building: json?["building"],
    floor: json?["floor"],
    apartment: json?["apartment"],
    city: json?["city"],
    state: json?["state"],
    country: json?["country"],
    email: json?["email"],
    phoneNumber: json?["phone_number"],
    postalCode: json?["postal_code"],
    ipAddress: json?["ip_address"],
    extraDescription: json?["extra_description"],
    transactionId: json?["transaction_id"],
    createdAt: json?["created_at"] == null ? null : DateTime.parse(json?["created_at"]),
    shippingMethod: json?["shipping_method"],
    orderId: json?["order_id"],
    order: json?["order"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "street": street,
    "building": building,
    "floor": floor,
    "apartment": apartment,
    "city": city,
    "state": state,
    "country": country,
    "email": email,
    "phone_number": phoneNumber,
    "postal_code": postalCode,
    "ip_address": ipAddress,
    "extra_description": extraDescription,
    "transaction_id": transactionId,
    "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
    "shipping_method": shippingMethod,
    "order_id": orderId,
    "order": order,
  };
}

class TrackTransactionData {
  TrackTransactionData({
    this.paidThrough,
    this.gatewayIntegrationPk,
    this.fromUser,
    this.aggTerminal,
    this.cashoutAmount,
    this.rrn,
    this.amount,
    this.dueAmount,
    this.message,
    this.biller,
    this.ref,
    this.otp,
    this.klass,
    this.billReference,
    this.txnResponseCode,
  });

  dynamic paidThrough;
  dynamic gatewayIntegrationPk;
  dynamic fromUser;
  dynamic aggTerminal;
  dynamic cashoutAmount;
  dynamic rrn;
  dynamic amount;
  dynamic dueAmount;
  dynamic message;
  dynamic biller;
  dynamic ref;
  dynamic otp;
  dynamic klass;
  dynamic billReference;
  dynamic txnResponseCode;

  factory TrackTransactionData.fromJson(Map<String, dynamic>? json) => TrackTransactionData(
    paidThrough: json?["paid_through"],
    gatewayIntegrationPk: json?["gateway_integration_pk"],
    fromUser: json?["from_user"],
    aggTerminal: json?["agg_terminal"],
    cashoutAmount: json?["cashout_amount"],
    rrn: json?["rrn"],
    amount: json?["amount"],
    dueAmount: json?["due_amount"],
    message: json?["message"],
    biller: json?["biller"],
    ref: json?["ref"],
    otp: json?["otp"],
    klass: json?["klass"],
    billReference: json?["bill_reference"],
    txnResponseCode: json?["txn_response_code"],
  );

  Map<String, dynamic> toJson() => {
    "paid_through": paidThrough,
    "gateway_integration_pk": gatewayIntegrationPk,
    "from_user": fromUser,
    "agg_terminal": aggTerminal,
    "cashout_amount": cashoutAmount,
    "rrn": rrn,
    "amount": amount,
    "due_amount": dueAmount,
    "message": message,
    "biller": biller,
    "ref": ref,
    "otp": otp,
    "klass": klass,
    "bill_reference": billReference,
    "txn_response_code": txnResponseCode,
  };
}

class InstallmentInfo {
  InstallmentInfo({
    this.administrativeFees,
    this.downPayment,
    this.items,
    this.tenure,
    this.financeAmount,
  });

  dynamic administrativeFees;
  dynamic downPayment;
  dynamic items;
  dynamic tenure;
  dynamic financeAmount;

  factory InstallmentInfo.fromJson(Map<String, dynamic>? json) => InstallmentInfo(
    administrativeFees: json?["administrative_fees"],
    downPayment: json?["down_payment"],
    items: json?["items"],
    tenure: json?["tenure"],
    financeAmount: json?["finance_amount"],
  );

  Map<String, dynamic> toJson() => {
    "administrative_fees": administrativeFees,
    "down_payment": downPayment,
    "items": items,
    "tenure": tenure,
    "finance_amount": financeAmount,
  };
}

class Order {
  Order({
    this.id,
    this.createdAt,
    this.deliveryNeeded,
    this.merchant,
    this.collector,
    this.amountCents,
    this.shippingData,
    this.currency,
    this.isPaymentLocked,
    this.isReturn,
    this.isCancel,
    this.isReturned,
    this.isCanceled,
    this.merchantOrderId,
    this.walletNotification,
    this.paidAmountCents,
    this.notifyUserWithEmail,
    this.items,
    this.orderUrl,
    this.commissionFees,
    this.deliveryFeesCents,
    this.deliveryVatCents,
    this.paymentMethod,
    this.merchantStaffTag,
    this.apiSource,
    this.data,
  });

  dynamic id;
  DateTime? createdAt;
  dynamic deliveryNeeded;
  Merchant? merchant;
  dynamic collector;
  dynamic amountCents;
  IngData? shippingData;
  dynamic currency;
  dynamic isPaymentLocked;
  dynamic isReturn;
  dynamic isCancel;
  dynamic isReturned;
  dynamic isCanceled;
  dynamic merchantOrderId;
  dynamic walletNotification;
  dynamic paidAmountCents;
  dynamic notifyUserWithEmail;
  List<dynamic>? items;
  dynamic orderUrl;
  dynamic commissionFees;
  dynamic deliveryFeesCents;
  dynamic deliveryVatCents;
  dynamic paymentMethod;
  dynamic merchantStaffTag;
  dynamic apiSource;
  OrderData? data;

  factory Order.fromJson(Map<String, dynamic>? json) => Order(
    id: json?["id"],
    createdAt: json?["created_at"] == null ? null : DateTime.parse(json?["created_at"]),
    deliveryNeeded: json?["delivery_needed"],
    merchant: json?["merchant"] == null ? null : Merchant.fromJson(json?["merchant"]),
    collector: json?["collector"],
    amountCents: json?["amount_cents"],
    shippingData: json?["shipping_data"] == null ? null : IngData.fromJson(json?["shipping_data"]),
    currency: json?["currency"],
    isPaymentLocked: json?["is_payment_locked"],
    isReturn: json?["is_return"],
    isCancel: json?["is_cancel"],
    isReturned: json?["is_returned"],
    isCanceled: json?["is_canceled"],
    merchantOrderId: json?["merchant_order_id"],
    walletNotification: json?["wallet_notification"],
    paidAmountCents: json?["paid_amount_cents"],
    notifyUserWithEmail: json?["notify_user_with_email"],
    items: json?["items"] == null ? null : List<dynamic>.from(json?["items"].map((x) => x)),
    orderUrl: json?["order_url"],
    commissionFees: json?["commission_fees"],
    deliveryFeesCents: json?["delivery_fees_cents"],
    deliveryVatCents: json?["delivery_vat_cents"],
    paymentMethod: json?["payment_method"],
    merchantStaffTag: json?["merchant_staff_tag"],
    apiSource: json?["api_source"],
    data: json?["data"] == null ? null : OrderData.fromJson(json?["data"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
    "delivery_needed": deliveryNeeded,
    "merchant": merchant == null ? null : merchant!.toJson(),
    "collector": collector,
    "amount_cents": amountCents,
    "shipping_data": shippingData == null ? null : shippingData!.toJson(),
    "currency": currency,
    "is_payment_locked": isPaymentLocked,
    "is_return": isReturn,
    "is_cancel": isCancel,
    "is_returned": isReturned,
    "is_canceled": isCanceled,
    "merchant_order_id": merchantOrderId,
    "wallet_notification": walletNotification,
    "paid_amount_cents": paidAmountCents,
    "notify_user_with_email": notifyUserWithEmail,
    "items": items == null ? null : List<dynamic>.from(items!.map((x) => x)),
    "order_url": orderUrl,
    "commission_fees": commissionFees,
    "delivery_fees_cents": deliveryFeesCents,
    "delivery_vat_cents": deliveryVatCents,
    "payment_method": paymentMethod,
    "merchant_staff_tag": merchantStaffTag,
    "api_source": apiSource,
    "data": data == null ? null : data!.toJson(),
  };
}

class OrderData {
  OrderData();

  factory OrderData.fromJson(Map<String, dynamic> json) => OrderData(
  );

  Map<String, dynamic> toJson() => {
  };
}

class Merchant {
  Merchant({
    this.id,
    this.createdAt,
    this.phones,
    this.companyEmails,
    this.companyName,
    this.state,
    this.country,
    this.city,
    this.postalCode,
    this.street,
  });

  dynamic id;
  DateTime? createdAt;
  List<dynamic>? phones;
  List<dynamic>? companyEmails;
  dynamic companyName;
  dynamic state;
  dynamic country;
  dynamic city;
  dynamic postalCode;
  dynamic street;

  factory Merchant.fromJson(Map<String, dynamic>? json) => Merchant(
    id: json?["id"],
    createdAt: json?["created_at"] == null ? null : DateTime.parse(json?["created_at"]),
    phones: json?["phones"] == null ? null : List<String>.from(json?["phones"].map((x) => x)),
    companyEmails: json?["company_emails"] == null ? null : List<String>.from(json?["company_emails"].map((x) => x)),
    companyName: json?["company_name"],
    state: json?["state"],
    country: json?["country"],
    city: json?["city"],
    postalCode: json?["postal_code"],
    street: json?["street"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
    "phones": phones == null ? null : List<dynamic>.from(phones!.map((x) => x)),
    "company_emails": companyEmails == null ? null : List<dynamic>.from(companyEmails!.map((x) => x)),
    "company_name": companyName,
    "state": state,
    "country": country,
    "city": city,
    "postal_code": postalCode,
    "street": street,
  };
}

class SourceData {
  SourceData({
    this.type,
    this.subType,
    this.pan,
  });

  dynamic type;
  dynamic subType;
  dynamic pan;

  factory SourceData.fromJson(Map<String, dynamic>? json) => SourceData(
    type: json?["type"],
    subType: json?["sub_type"],
    pan: json?["pan"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "sub_type": subType,
    "pan": pan,
  };
}
