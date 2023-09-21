from Event import Event

class Projection:

    def __init__(self):
        self.state = ""

    def apply(self, event):
        self.state += event.data

    def load_from_events(self, aggregate_uuid):
        events = Event.query.filter_by(aggregate_uuid=aggregate_uuid).all()
        for event in events:
            self.apply(event)

    def get_state(self):
        return self.state