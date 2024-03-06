class ChatEvent {
  String? eventType;
  String? payload;
  String? date;
  String? from;

  ChatEvent({this.eventType, this.payload, this.date, this.from});

  ChatEvent.fromJson(Map<String, dynamic> json) {
    eventType = json['event_type'];
    payload = json['payload'];
    date = json['date'];
    from = json['from'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['event_type'] = eventType;
    data['payload'] = payload;
    data['date'] = date;
    data['from'] = from;
    return data;
  }
}
