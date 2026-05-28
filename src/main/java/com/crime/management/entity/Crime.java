package com.crime.management.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "crimes")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Crime {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "crime_id")
    private Long crimeId;

    @NotBlank(message = "Crime type is required")
    @Column(name = "crime_type", nullable = false)
    private String crimeType;

    @Column(name = "date")
    private LocalDate date;

    @Column(name = "location")
    private String location;

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @ManyToMany(mappedBy = "crimes", fetch = FetchType.LAZY)
    @JsonIgnore
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Set<Criminal> criminals = new HashSet<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "crime_victim",
        joinColumns = @JoinColumn(name = "crime_id"),
        inverseJoinColumns = @JoinColumn(name = "victim_id")
    )
    @JsonIgnore
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Set<Victim> victims = new HashSet<>();

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "case_id")
    @JsonIgnore
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private CrimeCase crimeCase;
}
