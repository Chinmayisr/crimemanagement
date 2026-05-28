package com.crime.management.service;

import com.crime.management.entity.*;
import com.crime.management.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.*;

// ─── VictimServiceImpl ────────────────────────────────────────────────────────
@Service
@RequiredArgsConstructor
@Transactional
class VictimServiceImpl implements VictimService {
    private final VictimRepository repo;

    public List<Victim> findAll() { return repo.findAll(); }
    public Optional<Victim> findById(Long id) { return repo.findById(id); }
    public List<Victim> search(String name) { return repo.findByNameContainingIgnoreCase(name); }
    public Victim save(Victim v) { return repo.save(v); }
    public Victim update(Long id, Victim u) {
        Victim e = repo.findById(id).orElseThrow(() -> new RuntimeException("Victim not found: " + id));
        e.setName(u.getName());
        e.setAge(u.getAge());
        e.setGender(u.getGender());
        e.setContactInfo(u.getContactInfo());
        return repo.save(e);
    }
    public void delete(Long id) { repo.deleteById(id); }
    public long count() { return repo.count(); }
}

// ─── PoliceOfficerServiceImpl ─────────────────────────────────────────────────
@Service
@RequiredArgsConstructor
@Transactional
class PoliceOfficerServiceImpl implements PoliceOfficerService {
    private final PoliceOfficerRepository repo;

    public List<PoliceOfficer> findAll() { return repo.findAll(); }
    public Optional<PoliceOfficer> findById(Long id) { return repo.findById(id); }
    public List<PoliceOfficer> search(String name) { return repo.findByNameContainingIgnoreCase(name); }
    public List<PoliceOfficer> findByRank(String rank) { return repo.findByRank(rank); }
    public PoliceOfficer save(PoliceOfficer o) { return repo.save(o); }
    public PoliceOfficer update(Long id, PoliceOfficer u) {
        PoliceOfficer e = repo.findById(id).orElseThrow(() -> new RuntimeException("Officer not found: " + id));
        e.setName(u.getName());
        e.setRank(u.getRank());
        e.setBadgeNumber(u.getBadgeNumber());
        e.setContactNumber(u.getContactNumber());
        return repo.save(e);
    }
    public void delete(Long id) { repo.deleteById(id); }
    public long count() { return repo.count(); }
}

// ─── CrimeCaseServiceImpl ─────────────────────────────────────────────────────
@Service
@RequiredArgsConstructor
@Transactional
class CrimeCaseServiceImpl implements CrimeCaseService {
    private final CrimeCaseRepository caseRepo;
    private final PoliceOfficerRepository officerRepo;
    private final CriminalRepository criminalRepo;

    public List<CrimeCase> findAll() { return caseRepo.findAll(); }
    public Optional<CrimeCase> findById(Long id) { return caseRepo.findById(id); }
    public List<CrimeCase> findByStatus(CrimeCase.CaseStatus status) { return caseRepo.findByCaseStatus(status); }
    public List<CrimeCase> findByOfficer(Long officerId) { return caseRepo.findByOfficerOfficerId(officerId); }

    public CrimeCase save(CrimeCase c, Long officerId, List<Long> criminalIds) {
        if (officerId != null) {
            officerRepo.findById(officerId).ifPresent(c::setOfficer);
        }
        if (criminalIds != null && !criminalIds.isEmpty()) {
            Set<Criminal> criminals = new HashSet<>(criminalRepo.findAllById(criminalIds));
            c.setCriminals(criminals);
        }
        return caseRepo.save(c);
    }

    public CrimeCase update(Long id, CrimeCase u, Long officerId, List<Long> criminalIds) {
        CrimeCase e = caseRepo.findById(id).orElseThrow(() -> new RuntimeException("Case not found: " + id));
        e.setCaseStatus(u.getCaseStatus());
        e.setFilingDate(u.getFilingDate());
        e.setClosingDate(u.getClosingDate());
        if (officerId != null) {
            officerRepo.findById(officerId).ifPresent(e::setOfficer);
        }
        if (criminalIds != null) {
            e.setCriminals(new HashSet<>(criminalRepo.findAllById(criminalIds)));
        }
        return caseRepo.save(e);
    }

    public void delete(Long id) { caseRepo.deleteById(id); }
    public long count() { return caseRepo.count(); }
    public long countByStatus(CrimeCase.CaseStatus s) { return caseRepo.findByCaseStatus(s).size(); }
}

// ─── EvidenceServiceImpl ──────────────────────────────────────────────────────
@Service
@RequiredArgsConstructor
@Transactional
class EvidenceServiceImpl implements EvidenceService {
    private final EvidenceRepository evidenceRepo;
    private final CrimeCaseRepository caseRepo;

    public List<Evidence> findAll() { return evidenceRepo.findAll(); }
    public Optional<Evidence> findById(Long id) { return evidenceRepo.findById(id); }
    public List<Evidence> findByCase(Long caseId) { return evidenceRepo.findByCrimeCaseCaseId(caseId); }
    public List<Evidence> search(String type) { return evidenceRepo.findByTypeContainingIgnoreCase(type); }

    public Evidence save(Evidence ev, Long caseId) {
        if (caseId != null) {
            caseRepo.findById(caseId).ifPresent(ev::setCrimeCase);
        }
        return evidenceRepo.save(ev);
    }

    public Evidence update(Long id, Evidence u, Long caseId) {
        Evidence e = evidenceRepo.findById(id).orElseThrow(() -> new RuntimeException("Evidence not found: " + id));
        e.setType(u.getType());
        e.setDescription(u.getDescription());
        e.setCollectedDate(u.getCollectedDate());
        if (caseId != null) {
            caseRepo.findById(caseId).ifPresent(e::setCrimeCase);
        }
        return evidenceRepo.save(e);
    }

    public void delete(Long id) { evidenceRepo.deleteById(id); }
    public long count() { return evidenceRepo.count(); }
}
