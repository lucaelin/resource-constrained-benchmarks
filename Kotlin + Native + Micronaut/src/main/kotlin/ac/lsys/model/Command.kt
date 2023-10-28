package ac.lsys.model

import io.micronaut.serde.annotation.Serdeable


@Serdeable
data class Command(val data: String)