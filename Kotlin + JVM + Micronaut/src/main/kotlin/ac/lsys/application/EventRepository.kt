package ac.lsys.application

import ac.lsys.plugins.Event
import io.micronaut.data.jdbc.annotation.JdbcRepository
import io.micronaut.data.model.query.builder.sql.Dialect
import io.micronaut.data.repository.CrudRepository
import io.micronaut.data.repository.GenericRepository
import io.micronaut.transaction.annotation.Transactional
import jdk.internal.org.jline.utils.Colors.s
import java.awt.print.Book
import java.util.Optional
import java.util.UUID


@JdbcRepository(dialect = Dialect.POSTGRES)
abstract class EventRepository() : CrudRepository<Event, Int> {

    abstract fun findByAggregateUuid(aggregateUUID: UUID): List<Event>
    // {
//        return entityManager.createQuery("FROM Event AS event WHERE event.aggregateUUID = :aggregateUUID", Event::class.java)
//            .setParameter("aggregateUUID", aggregateUUID)
//            .resultList


    fun create(newEvent: Event): Event? {
        return save(newEvent)
    }

}