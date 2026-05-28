package com.crime.management.repository;

import com.crime.management.entity.Victim;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface VictimRepository extends JpaRepository<Victim, Long> {
    List<Victim> findByNameContainingIgnoreCase(String name);
    List<Victim> findByGender(String gender);
}
