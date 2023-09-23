package ac.lsys.plugins

import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import org.jetbrains.exposed.sql.*
import com.zaxxer.hikari.HikariConfig
import com.zaxxer.hikari.HikariDataSource

fun Application.configureDatabases() {

    val hikariConfig = HikariConfig().apply {
        jdbcUrl = "jdbc:postgresql://db/apples"
        driverClassName = "org.postgresql.Driver"
        username = "dbuser"
        password = "dbpass"
        maximumPoolSize = 1000 // Set this to your desired pool size
        validate()
    }

    val dataSource = HikariDataSource(hikariConfig)
    val database = Database.connect(dataSource)
        
    val eventService = EventService(database)
    routing {
        post("/{uuid}/command") {
            val uuid = call.parameters["uuid"] ?: throw IllegalArgumentException("Invalid UUID")
            val command = call.receive<Command>()
            
            val events = eventService.readByUuid(uuid)
            
            val aggregate = Aggregate(uuid)
            events.forEach(aggregate::apply)

            val newEvent = Event(uuid, command.data)
            aggregate.apply(newEvent)
            
            val eventId = eventService.create(newEvent)
            call.respond(HttpStatusCode.OK, eventId)
        }
        
        get("/{uuid}/query") {
            val uuid = call.parameters["uuid"] ?: throw IllegalArgumentException("Invalid UUID")
            
            val events = eventService.readByUuid(uuid)
            
            val projection = Projection()
            events.forEach(projection::apply)
            
            call.respond(HttpStatusCode.OK, projection.getState())
        }
    }
}
