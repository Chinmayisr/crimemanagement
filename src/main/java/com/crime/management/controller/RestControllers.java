package com.crime.management.controller;

import com.crime.management.entity.*;
import com.crime.management.repository.*;
import com.crime.management.service.*;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;

// ─── VictimController ─────────────────────────────────────────────────────────
@RestController
@RequestMapping("/api/victims")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
class VictimController {
    private final VictimService service;

    @GetMapping
    ResponseEntity<List<Victim>> getAll(@RequestParam(required = false) String name) {
        return ResponseEntity.ok(name != null ? service.search(name) : service.findAll());
    }
    @GetMapping("/{id}")
    ResponseEntity<Victim> getById(@PathVariable Long id) {
        return service.findById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }
    @PostMapping
    ResponseEntity<Victim> create(@Valid @RequestBody Victim v) { return ResponseEntity.ok(service.save(v)); }
    @PutMapping("/{id}")
    ResponseEntity<Victim> update(@PathVariable Long id, @Valid @RequestBody Victim v) {
        return ResponseEntity.ok(service.update(id, v));
    }
    @DeleteMapping("/{id}")
    ResponseEntity<Map<String, String>> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.ok(Map.of("message", "Victim deleted"));
    }
}

// ─── PoliceOfficerController ──────────────────────────────────────────────────
@RestController
@RequestMapping("/api/officers")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
class PoliceOfficerController {
    private final PoliceOfficerService service;

    @GetMapping
    ResponseEntity<List<PoliceOfficer>> getAll(@RequestParam(required = false) String name) {
        return ResponseEntity.ok(name != null ? service.search(name) : service.findAll());
    }
    @GetMapping("/{id}")
    ResponseEntity<PoliceOfficer> getById(@PathVariable Long id) {
        return service.findById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }
    @PostMapping
    ResponseEntity<PoliceOfficer> create(@Valid @RequestBody PoliceOfficer o) { return ResponseEntity.ok(service.save(o)); }
    @PutMapping("/{id}")
    ResponseEntity<PoliceOfficer> update(@PathVariable Long id, @Valid @RequestBody PoliceOfficer o) {
        return ResponseEntity.ok(service.update(id, o));
    }
    @DeleteMapping("/{id}")
    ResponseEntity<Map<String, String>> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.ok(Map.of("message", "Officer deleted"));
    }
}

// ─── CrimeCaseController ──────────────────────────────────────────────────────
@RestController
@RequestMapping("/api/cases")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
class CrimeCaseController {
    private final CrimeCaseService service;

    @GetMapping
    ResponseEntity<List<CrimeCase>> getAll(@RequestParam(required = false) String status) {
        if (status != null) {
            return ResponseEntity.ok(service.findByStatus(CrimeCase.CaseStatus.valueOf(status.toUpperCase())));
        }
        return ResponseEntity.ok(service.findAll());
    }
    @GetMapping("/{id}")
    ResponseEntity<CrimeCase> getById(@PathVariable Long id) {
        return service.findById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }
    @PostMapping
    ResponseEntity<CrimeCase> create(
            @RequestBody CrimeCase c,
            @RequestParam(required = false) Long officerId,
            @RequestParam(required = false) List<Long> criminalIds) {
        return ResponseEntity.ok(service.save(c, officerId, criminalIds));
    }
    @PutMapping("/{id}")
    ResponseEntity<CrimeCase> update(
            @PathVariable Long id, @RequestBody CrimeCase c,
            @RequestParam(required = false) Long officerId,
            @RequestParam(required = false) List<Long> criminalIds) {
        return ResponseEntity.ok(service.update(id, c, officerId, criminalIds));
    }
    @DeleteMapping("/{id}")
    ResponseEntity<Map<String, String>> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.ok(Map.of("message", "Case deleted"));
    }
}

// ─── EvidenceController ───────────────────────────────────────────────────────
@RestController
@RequestMapping("/api/evidence")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
class EvidenceController {
    private final EvidenceService service;

    @GetMapping
    ResponseEntity<List<Evidence>> getAll(@RequestParam(required = false) String type) {
        return ResponseEntity.ok(type != null ? service.search(type) : service.findAll());
    }
    @GetMapping("/{id}")
    ResponseEntity<Evidence> getById(@PathVariable Long id) {
        return service.findById(id).map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
    }
    @GetMapping("/case/{caseId}")
    ResponseEntity<List<Evidence>> getByCase(@PathVariable Long caseId) {
        return ResponseEntity.ok(service.findByCase(caseId));
    }
    @PostMapping
    ResponseEntity<Evidence> create(@Valid @RequestBody Evidence ev, @RequestParam(required = false) Long caseId) {
        return ResponseEntity.ok(service.save(ev, caseId));
    }
    @PutMapping("/{id}")
    ResponseEntity<Evidence> update(@PathVariable Long id, @Valid @RequestBody Evidence ev,
            @RequestParam(required = false) Long caseId) {
        return ResponseEntity.ok(service.update(id, ev, caseId));
    }
    @DeleteMapping("/{id}")
    ResponseEntity<Map<String, String>> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.ok(Map.of("message", "Evidence deleted"));
    }
}

// ─── DashboardController ──────────────────────────────────────────────────────
@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
class DashboardController {
    private final CriminalService criminalService;
    private final CrimeService crimeService;
    private final VictimService victimService;
    private final PoliceOfficerService officerService;
    private final CrimeCaseService caseService;
    private final EvidenceService evidenceService;

    @GetMapping("/stats")
    ResponseEntity<Map<String, Object>> getStats() {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("totalCriminals", criminalService.count());
        stats.put("totalCrimes", crimeService.count());
        stats.put("totalVictims", victimService.count());
        stats.put("totalOfficers", officerService.count());
        stats.put("totalCases", caseService.count());
        stats.put("totalEvidence", evidenceService.count());
        stats.put("openCases", caseService.countByStatus(CrimeCase.CaseStatus.OPEN));
        stats.put("closedCases", caseService.countByStatus(CrimeCase.CaseStatus.CLOSED));
        stats.put("pendingCases", caseService.countByStatus(CrimeCase.CaseStatus.PENDING));
        stats.put("underInvestigation", caseService.countByStatus(CrimeCase.CaseStatus.UNDER_INVESTIGATION));
        return ResponseEntity.ok(stats);
    }
}
