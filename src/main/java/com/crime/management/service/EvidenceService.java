package com.crime.management.service;

import com.crime.management.entity.Evidence;
import java.util.*;

public interface EvidenceService {
    List<Evidence> findAll();
    Optional<Evidence> findById(Long id);
    List<Evidence> findByCase(Long caseId);
    List<Evidence> search(String type);
    Evidence save(Evidence ev, Long caseId);
    Evidence update(Long id, Evidence u, Long caseId);
    void delete(Long id);
    long count();
}
