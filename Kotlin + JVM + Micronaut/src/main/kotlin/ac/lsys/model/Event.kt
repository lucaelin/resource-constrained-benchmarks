package ac.lsys.model

import io.micronaut.data.annotation.GeneratedValue
import io.micronaut.data.annotation.Id
import io.micronaut.data.annotation.Index
import io.micronaut.data.annotation.MappedEntity
import io.micronaut.serde.annotation.Serdeable


@Serdeable
@MappedEntity
@Index(name = "idx_aggregate", columns = ["aggregateUUID"], unique = false)
data class Event(
    @field:Id
    @field:GeneratedValue(GeneratedValue.Type.AUTO)
    var id: Int = 0,
    var aggregateUUID: String,
    var data: String
)