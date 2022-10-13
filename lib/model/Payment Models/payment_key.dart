class PaymentKey {
    PaymentKey({
        this.token,
    });

    dynamic token;

    factory PaymentKey.fromJson(Map<String, dynamic>? json) => PaymentKey(
        token: json?["token"],
    );

    Map<String, dynamic> toJson() => {
        "token": token,
    };
}
