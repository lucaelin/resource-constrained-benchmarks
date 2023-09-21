package ac.lsys.apples;

import java.util.UUID;

public class Aggregate {
  private UUID aggregateUuid;
  private StringBuilder state = new StringBuilder();

  public Aggregate(UUID aggregateUuid) {
    this.aggregateUuid = aggregateUuid;
  }

  public void apply(Event event) {
    state.append(event.getData());
  }

  public UUID getAggregateUuid() {
    return aggregateUuid;
  }

  public String getState() {
    return state.toString();
  }
}