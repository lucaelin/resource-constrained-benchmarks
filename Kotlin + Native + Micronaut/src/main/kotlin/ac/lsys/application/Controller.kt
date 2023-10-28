package ac.lsys.application

import ac.lsys.model.Aggregate
import ac.lsys.model.Command
import ac.lsys.model.Event
import ac.lsys.model.Projection
import io.micronaut.http.HttpResponse
import io.micronaut.http.MutableHttpResponse
import io.micronaut.http.annotation.Body
import io.micronaut.http.annotation.Controller
import io.micronaut.http.annotation.Get
import io.micronaut.http.annotation.PathVariable
import io.micronaut.http.annotation.Post
import io.micronaut.transaction.TransactionDefinition
import io.micronaut.transaction.annotation.Transactional

@Controller
open class Controller(
    private val eventRepository: EventRepository
) {


    @Post("/{uuid}/command")
    @Transactional(isolation = TransactionDefinition.Isolation.SERIALIZABLE)
    open fun post(@PathVariable uuid: String, @Body command: Command): HttpResponse<Int> {

        val events: List<Event> = eventRepository.findByAggregateUUID(uuid)

        val aggregate = Aggregate(uuid)
        events.forEach(aggregate::apply)

        val newEvent = Event(0, uuid, command.data)
        aggregate.apply(newEvent)

        val eventId = eventRepository.storeEvent(newEvent).id

        return HttpResponse.ok(eventId)
    }

    @Get("/{uuid}/query")
    open fun query(@PathVariable uuid: String): HttpResponse<String>? {
        val events = eventRepository.findByAggregateUUID(uuid)

        val projection = Projection()
        events.forEach(projection::apply)

        return HttpResponse.ok<String>(projection.getState())
    }
}
