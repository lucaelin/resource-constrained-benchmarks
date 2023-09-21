from Event import Event

class Aggregate:

    def __init__(self, aggregate_uuid):
        self.aggregate_uuid = aggregate_uuid
        self.state = ""

    def apply(self, event):
        self.state += event.data

    def load_from_events(self):
        events = Event.query.filter_by(aggregate_uuid=self.aggregate_uuid).all()
        for event in events:
            self.apply(event)

    def get_state(self):
        return self.state