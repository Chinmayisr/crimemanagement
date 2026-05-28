package com.crime.management.repository;

import com.crime.management.entity.Crime;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDate;
import java.util.List;

@Repository
public interface CrimeRepository extends JpaRepository<Crime, Long> {
    List<Crime> findByCrimeTypeContainingIgnoreCase(String crimeType);
    List<Crime> findByLocationContainingIgnoreCase(String location);
    List<Crime> findByDateBetween(LocalDate startDate, LocalDate endDate);
    List<Crime> findByCrimeCaseIsNull();
}
