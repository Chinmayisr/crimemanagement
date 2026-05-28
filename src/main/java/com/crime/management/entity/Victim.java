package com.crime.management.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "victims")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Victim {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "victim_id")
    private Long victimId;

    @NotBlank(message = "Name is required")
    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "age")
    private Integer age;

    @Column(name = "gender")
    private String gender;

    @Column(name = "contact_info")
    private String contactInfo;

    @ManyToMany(mappedBy = "victims", fetch = FetchType.LAZY)
    @JsonIgnore
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Set<Crime> crimes = new HashSet<>();
}
