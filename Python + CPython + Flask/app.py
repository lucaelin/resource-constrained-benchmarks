from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate


app = Flask(__name__)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://dbuser:dbpass@db:5432/apples'
db = SQLAlchemy(app)
migrate = Migrate(app, db)

@app.cli.command("db_init")
def db_init():
    from Event import Event
    db.create_all()
    print("Database initialized!")

@app.route('/<uuid>/command', methods=['POST'])
def handle_command(uuid):
    from Aggregate import Aggregate
    from Projection import Projection
    from Command import Command
    from Event import Event
    command_data = request.json.get('data')
    command = Command(command_data)

    event = Event(aggregate_uuid=uuid, data=command.data)
    db.session.add(event)
    db.session.commit()

    aggregate = Aggregate(uuid)
    aggregate.apply(event)

    return jsonify({"id": event.id, "aggregate_uuid": event.aggregate_uuid, "data": event.data})

@app.route('/<uuid>/query', methods=['GET'])
def handle_query(uuid):
    from Aggregate import Aggregate
    from Projection import Projection
    from Command import Command
    from Event import Event
    projection = Projection()
    projection.load_from_events(uuid)

    return jsonify(projection.get_state())

if __name__ == '__main__':
    app.run(debug=True, port=8080)