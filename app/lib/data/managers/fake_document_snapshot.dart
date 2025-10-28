class FakeDocumentSnapshot {
  final String id;
  final Map<String, dynamic> _data;
  FakeDocumentSnapshot(this.id, this._data);
  Map<String, dynamic> data() => _data;
}
