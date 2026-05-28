package com.crime.management.dto;

import jakarta.validation.constraints.*;
import lombok.*;
import java.time.LocalDate;
import java.util.List;

// ─── Criminal ───────────────────────────────────────────────
@Data @NoArgsConstructor @AllArgsConstructor @Builder
class CriminalDTO {
    private Long criminalId;
    @NotBlank private String name;
    @Min(1) private Integer age;
    private String gender;
    private String address;
    private String crimeHistory;
    private List<Long> crimeIds;
    private List<Long> caseIds;
    // counts for list view
    private int crimeCount;
    private int caseCount;
}

// ─── Crime ──────────────────────────────────────────────────
@Data @NoArgsConstructor @AllArgsConstructor @Builder
class CrimeDTO {
    private Long crimeId;
    @NotBlank private String crimeType;
    private LocalDate date;
    private String location;
    private String description;
    private List<Long> criminalIds;
    private List<Long> victimIds;
    private Long caseId;
    private int criminalCount;
    private int victimCount;
}

// ─── Victim ──────────────────────────────────────────────────
@Data @NoArgsConstructor @AllArgsConstructor @Builder
class VictimDTO {
    private Long victimId;
    @NotBlank private String name;
    @Min(1) private Integer age;
    private String gender;
    private String contactInfo;
    private List<Long> crimeIds;
    private int crimeCount;
}

// ─── PoliceOfficer ────────────────────────────────────────────
@Data @NoArgsConstructor @AllArgsConstructor @Builder
class PoliceOfficerDTO {
    private Long officerId;
    @NotBlank private String name;
    private String rank;
    private String badgeNumber;
    private String contactNumber;
    private int caseCount;
}

// ─── CrimeCase ────────────────────────────────────────────────
@Data @NoArgsConstructor @AllArgsConstructor @Builder
class CrimeCaseDTO {
    private Long caseId;
    private String caseStatus;
    private LocalDate filingDate;
    private LocalDate closingDate;
    private Long officerId;
    private String officerName;
    private List<Long> crimeIds;
    private List<Long> criminalIds;
    private int evidenceCount;
}

// ─── Evidence ─────────────────────────────────────────────────
@Data @NoArgsConstructor @AllArgsConstructor @Builder
class EvidenceDTO {
    private Long evidenceId;
    @NotBlank private String type;
    private String description;
    private LocalDate collectedDate;
    private Long caseId;
    private String caseSummary;
}

// ─── Dashboard Stats ──────────────────────────────────────────
@Data @NoArgsConstructor @AllArgsConstructor @Builder
class DashboardStats {
    private long totalCriminals;
    private long totalCrimes;
    private long totalVictims;
    private long totalOfficers;
    private long totalCases;
    private long totalEvidence;
    private long openCases;
    private long closedCases;
    private long pendingCases;
}
