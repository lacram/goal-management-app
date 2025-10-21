package com.goalapp.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "routines")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class Routine {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(length = 1000)
    private String description;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RoutineFrequency frequency;

    @Builder.Default
    @Column(nullable = false)
    private boolean isActive = true;

    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    private LocalDateTime updatedAt;

    @OneToMany(mappedBy = "routine", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<RoutineCompletion> completions = new ArrayList<>();

    /**
     * 루틴 완료 추가
     */
    public void addCompletion(RoutineCompletion completion) {
        completions.add(completion);
        completion.setRoutine(this);
    }

    /**
     * 루틴 완료 제거
     */
    public void removeCompletion(RoutineCompletion completion) {
        completions.remove(completion);
        completion.setRoutine(null);
    }

    /**
     * 루틴 활성화
     */
    public void activate() {
        this.isActive = true;
    }

    /**
     * 루틴 비활성화
     */
    public void deactivate() {
        this.isActive = false;
    }

    /**
     * 완료 횟수 조회
     */
    public int getCompletionCount() {
        return completions != null ? completions.size() : 0;
    }

    /**
     * 유효성 검증
     */
    public void validate() {
        if (title == null || title.trim().isEmpty()) {
            throw new IllegalArgumentException("루틴 제목은 필수입니다");
        }
        if (frequency == null) {
            throw new IllegalArgumentException("반복 주기는 필수입니다");
        }
    }
}
