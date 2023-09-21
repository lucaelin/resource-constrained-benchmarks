package ac.lsys.apples;

import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/{uuid}")
public class Controller {

    private final EventRepository eventRepository;

    public Controller(EventRepository eventRepository) {
        this.eventRepository = eventRepository;
    }

    @PostMapping("/command")
    Event handleCommand(@PathVariable("uuid") UUID uuid, @RequestBody Command command) {
        // Query all existing events
        List<Event> events = eventRepository.findByAggregateUuid(uuid);

        // Apply all existing events to the aggregate
        Aggregate aggregate = new Aggregate(uuid);
        events.forEach(aggregate::apply);

        // Create a new event from the command
        Event event = new Event(uuid);
        event.setData(command.getData());

        // Apply the new event to the aggregate
        aggregate.apply(event);

        // Store and return the new event
        return eventRepository.save(event);
    }

    @GetMapping("/query")
    String handleQuery(@PathVariable("uuid") UUID uuid) {
        // Query all existing events
        List<Event> events = eventRepository.findByAggregateUuid(uuid);

        // Apply all events to the projection
        Projection projection = new Projection();
        events.forEach(projection::apply);

        // Return the projection's state
        return projection.getState();
    }
}