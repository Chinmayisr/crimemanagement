package com.crime.management.service;

import com.crime.management.entity.*;
import com.crime.management.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.util.*;

@Service
@RequiredArgsConstructor
@Transactional
public class CrimeService {

    private final CrimeRepository crimeRepository;
    private final VictimRepository victimRepository;
    private final CriminalRepository criminalRepository;
    private final CrimeCaseRepository caseRepository;

    public List<Crime> findAll() { return crimeRepository.findAll(); }

    public Optional<Crime> findById(Long id) { return crimeRepository.findById(id); }

    public List<Crime> searchByType(String type) {
        return crimeRepository.findByCrimeTypeContainingIgnoreCase(type);
    }

    public List<Crime> searchByLocation(String location) {
        return crimeRepository.findByLocationContainingIgnoreCase(location);
    }

    public List<Crime> findByDateRange(LocalDate start, LocalDate end) {
        return crimeRepository.findByDateBetween(start, end);
    }

    public Crime save(Crime crime, List<Long> victimIds, Long caseId) {
        if (victimIds != null && !victimIds.isEmpty()) {
            Set<Victim> victims = new HashSet<>(victimRepository.findAllById(victimIds));
            crime.setVictims(victims);
        }
        if (caseId != null) {
            caseRepository.findById(caseId).ifPresent(crime::setCrimeCase);
        }
        return crimeRepository.save(crime);
    }

    public Crime update(Long id, Crime updated, List<Long> victimIds, Long caseId) {
        Crime existing = crimeRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Crime not found: " + id));
        existing.setCrimeType(updated.getCrimeType());
        existing.setDate(updated.getDate());
        existing.setLocation(updated.getLocation());
        existing.setDescription(updated.getDescription());
        if (victimIds != null) {
            existing.setVictims(new HashSet<>(victimRepository.findAllById(victimIds)));
        }
        if (caseId != null) {
            caseRepository.findById(caseId).ifPresent(existing::setCrimeCase);
        } else {
            existing.setCrimeCase(null);
        }
        return crimeRepository.save(existing);
    }

    public void delete(Long id) { crimeRepository.deleteById(id); }

    public long count() { return crimeRepository.count(); }
}
