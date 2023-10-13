package ac.lsys.plugins

import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.transactions.experimental.newSuspendedTransaction
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import kotlinx.serialization.Serializable
import kotlinx.coroutines.Dispatchers
import org.flywaydb.core.internal.database.base.Database
import org.jetbrains.exposed.sql.*

@Serializable
data class Event(val aggregateUuid: String, val data: String)

class EventService(private val database: Database) {

    object Events : Table() {
        val id = integer("id").autoIncrement()
        val aggregateUuid = varchar("aggregateUuid", length = 50).index()
        val data = varchar("data", length = 500)

        override val primaryKey = PrimaryKey(id)
    }

    init {
        transaction(database) {
            SchemaUtils.create(Events)
        }
    }

    suspend fun <T> dbQuery(block: suspend () -> T): T =
        newSuspendedTransaction(Dispatchers.IO) { block() }

    suspend fun create(event: Event): Int = dbQuery {
        Events.insert {
            it[aggregateUuid] = event.aggregateUuid
            it[data] = event.data
        }[Events.id]
    }

    suspend fun readByUuid(aggregateUuid: String): List<Event> = dbQuery {
        Events.select { Events.aggregateUuid eq aggregateUuid }
            .map { Event(it[Events.aggregateUuid], it[Events.data]) }
    }
}
