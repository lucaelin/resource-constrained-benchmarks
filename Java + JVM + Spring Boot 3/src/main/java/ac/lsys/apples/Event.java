package ac.lsys.apples;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Index;
import jakarta.persistence.Table;
import java.util.UUID;

@Entity
@Table(indexes = @Index(columnList = "aggregateUuid", name = "index_aggregateUuid"))
public class Event {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    private UUID aggregateUuid;

    private String data;

    public Event() {
    }

    public Event(UUID aggregateUuid) {
        this.aggregateUuid = aggregateUuid;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    // Getters and Setters
    public UUID getAggregateUuid() {
        return aggregateUuid;
    }

    public void setAggregateUuid(UUID aggregateUuid) {
        this.aggregateUuid = aggregateUuid;
    }

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }
}