package com.crime.management.service;

import com.crime.management.entity.*;
import com.crime.management.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.*;

@Service
@RequiredArgsConstructor
@Transactional
public class CriminalService {

    private final CriminalRepository criminalRepository;
    private final CrimeRepository crimeRepository;
    private final CrimeCaseRepository caseRepository;

    public List<Criminal> findAll() {
        return criminalRepository.findAll();
    }

    public Optional<Criminal> findById(Long id) {
        return criminalRepository.findById(id);
    }

    public List<Criminal> searchByName(String name) {
        return criminalRepository.findByNameContainingIgnoreCase(name);
    }

    public Criminal save(Criminal criminal, List<Long> crimeIds, List<Long> caseIds) {
        if (crimeIds != null && !crimeIds.isEmpty()) {
            Set<Crime> crimes = new HashSet<>(crimeRepository.findAllById(crimeIds));
            criminal.setCrimes(crimes);
        }
        if (caseIds != null && !caseIds.isEmpty()) {
            Set<CrimeCase> cases = new HashSet<>(caseRepository.findAllById(caseIds));
            criminal.setCases(cases);
        }
        return criminalRepository.save(criminal);
    }

    public Criminal update(Long id, Criminal updated, List<Long> crimeIds, List<Long> caseIds) {
        Criminal existing = criminalRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Criminal not found: " + id));
        existing.setName(updated.getName());
        existing.setAge(updated.getAge());
        existing.setGender(updated.getGender());
        existing.setAddress(updated.getAddress());
        existing.setCrimeHistory(updated.getCrimeHistory());

        if (crimeIds != null) {
            existing.setCrimes(new HashSet<>(crimeRepository.findAllById(crimeIds)));
        }
        if (caseIds != null) {
            existing.setCases(new HashSet<>(caseRepository.findAllById(caseIds)));
        }
        return criminalRepository.save(existing);
    }

    public void delete(Long id) {
        criminalRepository.deleteById(id);
    }

    public long count() {
        return criminalRepository.count();
    }
}
