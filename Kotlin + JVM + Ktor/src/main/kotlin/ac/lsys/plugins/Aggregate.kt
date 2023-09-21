package ac.lsys.plugins

class Aggregate(private val aggregateUuid: String) {
    private val state = StringBuilder()

    fun apply(event: Event) {
        state.append(event.data)
    }

    fun getState() = state.toString()
}