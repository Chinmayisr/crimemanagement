package com.crime.management.controller;

import com.crime.management.entity.Crime;
import com.crime.management.service.CrimeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/crimes")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CrimeController {

    private final CrimeService service;

    @GetMapping
    public ResponseEntity<List<Crime>> getAll(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String location,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        if (type != null) return ResponseEntity.ok(service.searchByType(type));
        if (location != null) return ResponseEntity.ok(service.searchByLocation(location));
        if (startDate != null && endDate != null) return ResponseEntity.ok(service.findByDateRange(startDate, endDate));
        return ResponseEntity.ok(service.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Crime> getById(@PathVariable Long id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Crime> create(
            @Valid @RequestBody Crime crime,
            @RequestParam(required = false) List<Long> victimIds,
            @RequestParam(required = false) Long caseId) {
        return ResponseEntity.ok(service.save(crime, victimIds, caseId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Crime> update(
            @PathVariable Long id,
            @Valid @RequestBody Crime crime,
            @RequestParam(required = false) List<Long> victimIds,
            @RequestParam(required = false) Long caseId) {
        return ResponseEntity.ok(service.update(id, crime, victimIds, caseId));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, String>> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.ok(Map.of("message", "Crime deleted successfully"));
    }
}
