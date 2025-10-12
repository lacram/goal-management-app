package com.goalapp.entity;

public enum GoalStatus {
    ACTIVE("진행중"),
    COMPLETED("완료"),
    FAILED("실패"),
    POSTPONED("연기");
    
    private final String description;
    
    GoalStatus(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}
