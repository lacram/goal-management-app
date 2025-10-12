package com.goalapp.exception;

public class GoalNotFoundException extends RuntimeException {
    public GoalNotFoundException(String message) {
        super(message);
    }
    
    public GoalNotFoundException(Long goalId) {
        super("Goal not found with id: " + goalId);
    }
}