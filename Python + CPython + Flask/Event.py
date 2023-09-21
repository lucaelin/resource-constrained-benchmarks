from app import db

class Event(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    aggregate_uuid = db.Column(db.String, nullable=False, index=True)
    data = db.Column(db.String, nullable=False)