package ac.lsys.model

class Projection {
    private val state = StringBuilder()

    fun apply(event: Event) {
        state.append(event.data)
    }

    fun getState() = state.toString()
}