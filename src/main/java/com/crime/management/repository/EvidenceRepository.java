package com.crime.management.repository;

import com.crime.management.entity.Evidence;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface EvidenceRepository extends JpaRepository<Evidence, Long> {
    List<Evidence> findByCrimeCaseCaseId(Long caseId);
    List<Evidence> findByTypeContainingIgnoreCase(String type);
}
