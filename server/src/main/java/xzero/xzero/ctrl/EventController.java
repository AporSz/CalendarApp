package xzero.xzero.ctrl;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import xzero.xzero.model.Event;
import xzero.xzero.repo.EventsRepo;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

@CrossOrigin
@RestController
@RequestMapping("event")
public class EventController {
    private final EventsRepo eventsRepo;
    public EventController(EventsRepo eventsRepo) {
        this.eventsRepo = eventsRepo;
    }

    @GetMapping( "/{id}") //@GetMapping(value = "/{id}") - it takes this by default so no use in specifying it
    public ResponseEntity<Event> getEvent(@PathVariable int id) {
        Optional<Event> event = eventsRepo.findById(id);
        System.out.println("Getting: " + id);

        if (event.isPresent()) {
            return ResponseEntity.ok(event.get());
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping
    public ResponseEntity<List<Event>> getEvents() {
        System.out.println("Getting all");

        List<Event> events = eventsRepo.findAll();
        return ResponseEntity.ok(events);
    }

    @GetMapping("/same-day")
    public ResponseEntity<List<Event>> getEventsSameDay(
            @RequestParam("date")
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {

        System.out.println("Getting same day: " + date);


        LocalDateTime startOfDay = date.atStartOfDay();
        LocalDateTime endOfDay = date.atTime(LocalTime.MAX);
        List<Event> events = eventsRepo.findByStartDateLessThanEqualAndEndDateGreaterThanEqual(endOfDay, startOfDay);

        return ResponseEntity.ok(events);
    }

    @PostMapping
    public ResponseEntity<Event> addEvent(@RequestBody Event event) {
        System.out.println("Adding: " + event.getTitle());
        return ResponseEntity.ok(eventsRepo.save(event));
    }

    @PutMapping
    public ResponseEntity<Event> updateEvent(@RequestBody Event event) {
        Optional<Event> optinalEvent = eventsRepo.findById(event.getId());
        System.out.println("Updating: " + event.getTitle());

        if (optinalEvent.isPresent()) {
            return ResponseEntity.ok(eventsRepo.save(event));
        }
        return ResponseEntity.notFound().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Event> deleteEvent(@PathVariable int id) {
        Event event = eventsRepo.findById(id).orElse(null);
        if (event != null) {
            eventsRepo.delete(event);
            System.out.println("Deleting: " + id);
        }
        return ResponseEntity.ok(null);
    }
}
