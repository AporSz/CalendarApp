package xzero.xzero.repo;

import org.springframework.data.jpa.repository.JpaRepository;
import xzero.xzero.model.Event;

import java.time.LocalDateTime;
import java.util.List;

public interface EventsRepo extends JpaRepository<Event, Integer> {
    List<Event> findByStartDateLessThanEqualAndEndDateGreaterThanEqual(LocalDateTime endOfDay, LocalDateTime startOfDay);
}
