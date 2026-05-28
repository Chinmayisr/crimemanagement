package com.crime.management.service;

import com.crime.management.entity.CrimeCase;
import java.util.*;

public interface CrimeCaseService {
    List<CrimeCase> findAll();
    Optional<CrimeCase> findById(Long id);
    List<CrimeCase> findByStatus(CrimeCase.CaseStatus status);
    List<CrimeCase> findByOfficer(Long officerId);
    CrimeCase save(CrimeCase c, Long officerId, List<Long> criminalIds);
    CrimeCase update(Long id, CrimeCase u, Long officerId, List<Long> criminalIds);
    void delete(Long id);
    long count();
    long countByStatus(CrimeCase.CaseStatus s);
}
