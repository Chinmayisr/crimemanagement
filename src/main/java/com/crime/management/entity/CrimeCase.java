package com.crime.management.entity;

import jakarta.persistence.*;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Table(name = "cases")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CrimeCase {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "case_id")
    private Long caseId;

    @Column(name = "case_status")
    @Enumerated(EnumType.STRING)
    private CaseStatus caseStatus;

    @Column(name = "filing_date")
    private LocalDate filingDate;

    @Column(name = "closing_date")
    private LocalDate closingDate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "officer_id")
    @JsonIgnore
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private PoliceOfficer officer;

    @OneToMany(mappedBy = "crimeCase", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JsonIgnore
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<Crime> crimes = new ArrayList<>();

    @OneToMany(mappedBy = "crimeCase", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @JsonIgnore
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<Evidence> evidences = new ArrayList<>();

    @ManyToMany(mappedBy = "cases", fetch = FetchType.LAZY)
    @JsonIgnore
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Set<Criminal> criminals = new HashSet<>();

    public enum CaseStatus {
        OPEN, CLOSED, PENDING, UNDER_INVESTIGATION
    }
}
