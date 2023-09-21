package ac.lsys.apples;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface EventRepository extends JpaRepository<Event, Long> {
    List<Event> findByAggregateUuid(UUID uuid);
}