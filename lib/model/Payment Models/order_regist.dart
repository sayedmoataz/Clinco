
class OrderRegis {
    OrderRegis({
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
        this.token,
        this.url,
    });

    int? id;
    DateTime? createdAt;
    bool? deliveryNeeded;
    Merchant? merchant;
    dynamic collector;
    int? amountCents;
    dynamic shippingData;
    String? currency;
    bool? isPaymentLocked;
    bool? isReturn;
    bool? isCancel;
    bool? isReturned;
    bool? isCanceled;
    dynamic merchantOrderId;
    dynamic walletNotification;
    int? paidAmountCents;
    bool? notifyUserWithEmail;
    List<dynamic>? items;
    String? orderUrl;
    int? commissionFees;
    int? deliveryFeesCents;
    int? deliveryVatCents;
    String? paymentMethod;
    dynamic merchantStaffTag;
    String? apiSource;
    Data? data;
    String? token;
    String? url;

    factory OrderRegis.fromJson(Map<String, dynamic>? json) => OrderRegis(
        id: json?["id"],
        createdAt: DateTime.parse(json?["created_at"]),
        deliveryNeeded: json?["delivery_needed"],
        merchant: Merchant.fromJson(json?["merchant"]),
        collector: json?["collector"],
        amountCents: json?["amount_cents"],
        shippingData: json?["shipping_data"],
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
        items: List<dynamic>.from(json?["items"].map((x) => x)),
        orderUrl: json?["order_url"],
        commissionFees: json?["commission_fees"],
        deliveryFeesCents: json?["delivery_fees_cents"],
        deliveryVatCents: json?["delivery_vat_cents"],
        paymentMethod: json?["payment_method"],
        merchantStaffTag: json?["merchant_staff_tag"],
        apiSource: json?["api_source"],
        data: Data.fromJson(json?["data"]),
        token: json?["token"],
        url: json?["url"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt!.toIso8601String(),
        "delivery_needed": deliveryNeeded,
        "merchant": merchant!.toJson(),
        "collector": collector,
        "amount_cents": amountCents,
        "shipping_data": shippingData,
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
        "items": List<dynamic>.from(items!.map((x) => x)),
        "order_url": orderUrl,
        "commission_fees": commissionFees,
        "delivery_fees_cents": deliveryFeesCents,
        "delivery_vat_cents": deliveryVatCents,
        "payment_method": paymentMethod,
        "merchant_staff_tag": merchantStaffTag,
        "api_source": apiSource,
        "data": data!.toJson(),
        "token": token,
        "url": url,
    };
}

class Data {
    Data();

    factory Data.fromJson(Map<String, dynamic> json) => Data(
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

    int? id;
    DateTime? createdAt;
    List<String>? phones;
    List<String>? companyEmails;
    String? companyName;
    String? state;
    String? country;
    dynamic city;
    String? postalCode;
    String? street;

    factory Merchant.fromJson(Map<String, dynamic>? json) => Merchant(
        id: json?["id"],
        createdAt: DateTime.parse(json?["created_at"]),
        phones: List<String>.from(json?["phones"].map((x) => x)),
        companyEmails: List<String>.from(json?["company_emails"].map((x) => x)),
        companyName: json?["company_name"],
        state: json?["state"],
        country: json?["country"],
        city: json?["city"],
        postalCode: json?["postal_code"],
        street: json?["street"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt!.toIso8601String(),
        "phones": List<dynamic>.from(phones!.map((x) => x)),
        "company_emails": List<dynamic>.from(companyEmails!.map((x) => x)),
        "company_name": companyName,
        "state": state,
        "country": country,
        "city": city,
        "postal_code": postalCode,
        "street": street,
    };
}
