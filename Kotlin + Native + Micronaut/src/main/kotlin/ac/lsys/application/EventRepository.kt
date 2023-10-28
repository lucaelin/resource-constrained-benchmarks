package ac.lsys.application

import ac.lsys.model.Event
import io.micronaut.data.jdbc.annotation.JdbcRepository
import io.micronaut.data.model.query.builder.sql.Dialect
import io.micronaut.data.repository.CrudRepository
import io.micronaut.data.repository.GenericRepository
import io.micronaut.transaction.annotation.Transactional


@JdbcRepository(dialect = Dialect.POSTGRES)
abstract class EventRepository() : CrudRepository<Event, Int> {
    // Use the default save method provided by CrudRepository to store a new event
    // However, to make it explicit, you can define this:
    fun storeEvent(event: Event): Event {
        return save(event)
    }

    // Add custom method to retrieve all events with the same aggregateUUID
    abstract fun findByAggregateUUID(aggregateUUID: String): List<Event>
}