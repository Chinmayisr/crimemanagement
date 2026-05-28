package com.crime.management.repository;

import com.crime.management.entity.PoliceOfficer;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface PoliceOfficerRepository extends JpaRepository<PoliceOfficer, Long> {
    List<PoliceOfficer> findByNameContainingIgnoreCase(String name);
    Optional<PoliceOfficer> findByBadgeNumber(String badgeNumber);
    List<PoliceOfficer> findByRank(String rank);
}
