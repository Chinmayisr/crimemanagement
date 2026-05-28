package com.crime.management.service;

import com.crime.management.entity.PoliceOfficer;
import java.util.*;

public interface PoliceOfficerService {
    List<PoliceOfficer> findAll();
    Optional<PoliceOfficer> findById(Long id);
    List<PoliceOfficer> search(String name);
    List<PoliceOfficer> findByRank(String rank);
    PoliceOfficer save(PoliceOfficer o);
    PoliceOfficer update(Long id, PoliceOfficer u);
    void delete(Long id);
    long count();
}
