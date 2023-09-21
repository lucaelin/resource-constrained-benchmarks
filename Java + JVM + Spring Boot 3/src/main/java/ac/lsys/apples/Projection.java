package ac.lsys.apples;

public class Projection {

  private StringBuilder state = new StringBuilder();

  public void apply(Event event) {
    state.append(event.getData());
  }

  public String getState() {
    return state.toString();
  }
}