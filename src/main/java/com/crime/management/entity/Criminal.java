package com.crime.management.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Min;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "criminals")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Criminal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "criminal_id")
    private Long criminalId;

    @NotBlank(message = "Name is required")
    @Column(name = "name", nullable = false)
    private String name;

    @Min(value = 1, message = "Age must be positive")
    @Column(name = "age")
    private Integer age;

    @Column(name = "gender")
    private String gender;

    @Column(name = "address", columnDefinition = "TEXT")
    private String address;

    @Column(name = "crime_history", columnDefinition = "TEXT")
    private String crimeHistory;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "criminal_crime",
        joinColumns = @JoinColumn(name = "criminal_id"),
        inverseJoinColumns = @JoinColumn(name = "crime_id")
    )
    @JsonIgnore
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Set<Crime> crimes = new HashSet<>();

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
        name = "criminal_case",
        joinColumns = @JoinColumn(name = "criminal_id"),
        inverseJoinColumns = @JoinColumn(name = "case_id")
    )
    @JsonIgnore
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Set<CrimeCase> cases = new HashSet<>();
}
