class Kiosk {
    Kiosk({
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
        this.profileId,
        this.hasParentTransaction,
        this.order,
        this.createdAt,
        this.currency,
        this.terminalId,
        this.merchantCommission,
        this.installment,
        this.isVoid,
        this.isRefund,
        this.errorOccured,
        this.refundedAmountCents,
        this.capturedAmount,
        this.merchantStaffTag,
        this.updatedAt,
        this.owner,
        this.parentTransaction,
        this.merchantOrderId,
        this.dataMessage,
        this.sourceDataType,
        this.sourceDataPan,
        this.sourceDataSubType,
        this.acqResponseCode,
        this.txnResponseCode,
        this.hmac,
        this.useRedirection,
        this.redirectionUrl,
        this.merchantResponse,
        this.bypassStepSix,
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
    dynamic profileId;
    dynamic hasParentTransaction;
    dynamic order;
    DateTime? createdAt;
    dynamic currency;
    dynamic terminalId;
    dynamic merchantCommission;
    dynamic installment;
    dynamic isVoid;
    dynamic isRefund;
    dynamic errorOccured;
    dynamic refundedAmountCents;
    dynamic capturedAmount;
    dynamic merchantStaffTag;
    DateTime? updatedAt;
    dynamic owner;
    dynamic parentTransaction;
    dynamic merchantOrderId;
    dynamic dataMessage;
    dynamic sourceDataType;
    dynamic sourceDataPan;
    dynamic sourceDataSubType;
    dynamic acqResponseCode;
    dynamic txnResponseCode;
    dynamic hmac;
    dynamic useRedirection;
    dynamic redirectionUrl;
    dynamic merchantResponse;
    dynamic bypassStepSix;

    factory Kiosk.fromJson(Map<String, dynamic>? json) => Kiosk(
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
        profileId: json?["profile_id"],
        hasParentTransaction: json?["has_parent_transaction"],
        order: json?["order"],
        createdAt: DateTime.parse(json?["created_at"]),
        currency: json?["currency"],
        terminalId: json?["terminal_id"],
        merchantCommission: json?["merchant_commission"],
        installment: json?["installment"],
        isVoid: json?["is_void"],
        isRefund: json?["is_refund"],
        errorOccured: json?["error_occured"],
        refundedAmountCents: json?["refunded_amount_cents"],
        capturedAmount: json?["captured_amount"],
        merchantStaffTag: json?["merchant_staff_tag"],
        updatedAt: DateTime.parse(json?["updated_at"]),
        owner: json?["owner"],
        parentTransaction: json?["parent_transaction"],
        merchantOrderId: json?["merchant_order_id"],
        dataMessage: json?["data.message"],
        sourceDataType: json?["source_data.type"],
        sourceDataPan: json?["source_data.pan"],
        sourceDataSubType: json?["source_data.sub_type"],
        acqResponseCode: json?["acq_response_code"],
        txnResponseCode: json?["txn_response_code"],
        hmac: json?["hmac"],
        useRedirection: json?["use_redirection"],
        redirectionUrl: json?["redirection_url"],
        merchantResponse: json?["merchant_response"],
        bypassStepSix: json?["bypass_step_six"],
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
        "profile_id": profileId,
        "has_parent_transaction": hasParentTransaction,
        "order": order,
        "created_at": createdAt!.toIso8601String(),
        "currency": currency,
        "terminal_id": terminalId,
        "merchant_commission": merchantCommission,
        "installment": installment,
        "is_void": isVoid,
        "is_refund": isRefund,
        "error_occured": errorOccured,
        "refunded_amount_cents": refundedAmountCents,
        "captured_amount": capturedAmount,
        "merchant_staff_tag": merchantStaffTag,
        "updated_at": updatedAt!.toIso8601String(),
        "owner": owner,
        "parent_transaction": parentTransaction,
        "merchant_order_id": merchantOrderId,
        "data.message": dataMessage,
        "source_data.type": sourceDataType,
        "source_data.pan": sourceDataPan,
        "source_data.sub_type": sourceDataSubType,
        "acq_response_code": acqResponseCode,
        "txn_response_code": txnResponseCode,
        "hmac": hmac,
        "use_redirection": useRedirection,
        "redirection_url": redirectionUrl,
        "merchant_response": merchantResponse,
        "bypass_step_six": bypassStepSix,
    };
}
