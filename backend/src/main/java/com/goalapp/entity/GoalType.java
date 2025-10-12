package com.goalapp.entity;

public enum GoalType {
    LIFETIME("평생목표"),
    LIFETIME_SUB("평생목표 하위목표"),
    YEARLY("년단위"),
    MONTHLY("월단위"),
    WEEKLY("주단위"),
    DAILY("일단위");
    
    private final String description;
    
    GoalType(String description) {
        this.description = description;
    }
    
    public String getDescription() {
        return description;
    }
}
