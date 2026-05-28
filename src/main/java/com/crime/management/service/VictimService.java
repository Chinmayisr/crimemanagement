package com.crime.management.service;

import com.crime.management.entity.Victim;
import java.util.*;

public interface VictimService {
    List<Victim> findAll();
    Optional<Victim> findById(Long id);
    List<Victim> search(String name);
    Victim save(Victim v);
    Victim update(Long id, Victim u);
    void delete(Long id);
    long count();
}
