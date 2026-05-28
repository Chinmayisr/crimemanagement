package com.crime.management.repository;

import com.crime.management.entity.CrimeCase;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CrimeCaseRepository extends JpaRepository<CrimeCase, Long> {
    List<CrimeCase> findByCaseStatus(CrimeCase.CaseStatus status);
    List<CrimeCase> findByOfficerOfficerId(Long officerId);
}
