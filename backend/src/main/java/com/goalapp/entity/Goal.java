package com.goalapp.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "goals")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class Goal {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String title;
    
    @Column(length = 1000)
    private String description;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private GoalType type;
    
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private GoalStatus status = GoalStatus.ACTIVE;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_goal_id")
    @JsonIgnore
    private Goal parentGoal;
    
    @OneToMany(mappedBy = "parentGoal", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    @Builder.Default
    private List<Goal> subGoals = new ArrayList<>();
    
    @CreatedDate
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @LastModifiedDate
    private LocalDateTime updatedAt;
    
    private LocalDateTime dueDate;
    
    private LocalDateTime completedAt;
    
    @JsonProperty("isCompleted")
    @Builder.Default
    private boolean isCompleted = false;
    
    @Builder.Default
    private int priority = 1;
    
    @Builder.Default
    private boolean reminderEnabled = false;
    
    private String reminderFrequency;
    
    // 목표 타입에 따른 유효성 검증
    public boolean isValidParentChildRelation(Goal child) {
        if (this.type == GoalType.LIFETIME) {
            return child.type == GoalType.LIFETIME_SUB;
        }
        if (this.type == GoalType.LIFETIME_SUB) {
            return child.type == GoalType.YEARLY || 
                   child.type == GoalType.MONTHLY ||
                   child.type == GoalType.WEEKLY ||
                   child.type == GoalType.DAILY;
        }
        if (this.type == GoalType.YEARLY) {
            return child.type == GoalType.MONTHLY || 
                   child.type == GoalType.WEEKLY ||
                   child.type == GoalType.DAILY;
        }
        if (this.type == GoalType.MONTHLY) {
            return child.type == GoalType.WEEKLY ||
                   child.type == GoalType.DAILY;
        }
        if (this.type == GoalType.WEEKLY) {
            return child.type == GoalType.DAILY;
        }
        return false; // DAILY는 하위 목표를 가질 수 없음
    }
    
    // 독립 목표인지 확인 (어디에도 종속되지 않은 목표)
    public boolean isIndependentGoal() {
        return parentGoal == null && 
               (type == GoalType.YEARLY || 
                type == GoalType.MONTHLY || 
                type == GoalType.WEEKLY || 
                type == GoalType.DAILY);
    }
    
    // 하위 목표 추가
    public void addSubGoal(Goal subGoal) {
        if (isValidParentChildRelation(subGoal)) {
            subGoals.add(subGoal);
            subGoal.setParentGoal(this);
        } else {
            throw new IllegalArgumentException("Invalid parent-child goal relationship");
        }
    }
    
    // 하위 목표 제거
    public void removeSubGoal(Goal subGoal) {
        subGoals.remove(subGoal);
        subGoal.setParentGoal(null);
    }
    
    // 목표 완료 처리
    public void markAsCompleted() {
        this.isCompleted = true;
        this.status = GoalStatus.COMPLETED;
        this.completedAt = LocalDateTime.now();
    }
    
    // 목표 완료 취소
    public void markAsIncomplete() {
        this.isCompleted = false;
        this.status = GoalStatus.ACTIVE;
        this.completedAt = null;
    }
    
    // 진행률 계산 (하위 목표 기반)
    public double getProgressPercentage() {
        if (subGoals.isEmpty()) {
            return isCompleted ? 100.0 : 0.0;
        }
        
        long completedSubGoals = subGoals.stream()
                .mapToLong(goal -> goal.isCompleted() ? 1 : 0)
                .sum();
        
        return (double) completedSubGoals / subGoals.size() * 100;
    }
}
