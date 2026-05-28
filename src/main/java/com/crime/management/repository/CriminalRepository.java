package com.crime.management.repository;

import com.crime.management.entity.Criminal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface CriminalRepository extends JpaRepository<Criminal, Long> {
    List<Criminal> findByNameContainingIgnoreCase(String name);
    List<Criminal> findByGender(String gender);

    @Query("SELECT c FROM Criminal c WHERE c.age BETWEEN :minAge AND :maxAge")
    List<Criminal> findByAgeBetween(int minAge, int maxAge);
}
