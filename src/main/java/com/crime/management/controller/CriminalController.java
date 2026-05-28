package com.crime.management.controller;

import com.crime.management.entity.Crime;
import com.crime.management.entity.CrimeCase;
import com.crime.management.entity.Criminal;
import com.crime.management.service.CriminalService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Set;

@RestController
@RequestMapping("/api/criminals")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CriminalController {

    private final CriminalService service;

    @GetMapping
    public ResponseEntity<List<Criminal>> getAll(@RequestParam(required = false) String name) {
        if (name != null && !name.isEmpty()) {
            return ResponseEntity.ok(service.searchByName(name));
        }
        return ResponseEntity.ok(service.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Criminal> getById(@PathVariable Long id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Criminal> create(
            @Valid @RequestBody Criminal criminal,
            @RequestParam(required = false) List<Long> crimeIds,
            @RequestParam(required = false) List<Long> caseIds) {
        return ResponseEntity.ok(service.save(criminal, crimeIds, caseIds));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Criminal> update(
            @PathVariable Long id,
            @Valid @RequestBody Criminal criminal,
            @RequestParam(required = false) List<Long> crimeIds,
            @RequestParam(required = false) List<Long> caseIds) {
        return ResponseEntity.ok(service.update(id, criminal, crimeIds, caseIds));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.ok(Map.of("message", "Criminal deleted successfully"));
    }

    @GetMapping("/{id}/crimes")
    public ResponseEntity<Set<Crime>> getCrimes(@PathVariable Long id) {
        return service.findById(id)
                .map(c -> ResponseEntity.ok(c.getCrimes()))
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}/cases")
    public ResponseEntity<Set<CrimeCase>> getCases(@PathVariable Long id) {
        return service.findById(id)
                .map(c -> ResponseEntity.ok(c.getCases()))
                .orElse(ResponseEntity.notFound().build());
    }
}
