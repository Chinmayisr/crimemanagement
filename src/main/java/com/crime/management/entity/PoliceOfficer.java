package com.crime.management.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "police_officers")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PoliceOfficer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "officer_id")
    private Long officerId;

    @NotBlank(message = "Name is required")
    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "`rank`")
    private String rank;

    @Column(name = "badge_number", unique = true)
    private String badgeNumber;

    @Column(name = "contact_number")
    private String contactNumber;

    @OneToMany(mappedBy = "officer", fetch = FetchType.LAZY)
    @JsonIgnore
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private List<CrimeCase> cases = new ArrayList<>();
}
