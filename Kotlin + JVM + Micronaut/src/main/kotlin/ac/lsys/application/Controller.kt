package ac.lsys.application

import ac.lsys.plugins.Aggregate
import ac.lsys.plugins.Command
import ac.lsys.plugins.Event
import ac.lsys.plugins.Projection
import io.micronaut.context.BeanContext
import io.micronaut.http.HttpResponse
import io.micronaut.http.MutableHttpResponse
import io.micronaut.http.annotation.Body
import io.micronaut.http.annotation.Controller
import io.micronaut.http.annotation.Get
import io.micronaut.http.annotation.PathVariable
import io.micronaut.http.annotation.Post
import io.micronaut.transaction.TransactionDefinition
import io.micronaut.transaction.annotation.Transactional
import java.util.UUID

@Controller
class Controller(private val beanContext: BeanContext) {


    @Post("/{uuid}/command")
    @Transactional(isolation = TransactionDefinition.Isolation.SERIALIZABLE)
    fun post(@PathVariable uuid: String, @Body command: Command): HttpResponse<Event> {

        val eventService = beanContext.getBean(EventRepository::class.java)

        val events: List<Event> = eventService.readByUuid(uuid)

        val aggregate = Aggregate(uuid)
        events.forEach(aggregate::apply)

        val newEvent = Event(uuid, command.data)
        aggregate.apply(newEvent)

        val eventId = eventService.create(newEvent)

        return HttpResponse.ok(eventId)
    }

    @Get("/{uuid}/query")
    fun query(@PathVariable uuid: String): HttpResponse<String>? {
        val eventService = beanContext.getBean(EventRepository::class.java)

        val events = eventService.readByUuid(uuid)

        val projection = Projection()
        events.forEach(projection::apply)

        return HttpResponse.ok<String>(projection.getState())
    }
}
