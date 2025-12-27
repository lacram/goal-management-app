package com.goalapp.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

/**
 * Root endpoint for load balancer and uptime checks.
 */
@RestController
public class RootController {

    @RequestMapping(value = "/", method = {RequestMethod.GET, RequestMethod.HEAD})
    public ResponseEntity<String> root() {
        return ResponseEntity.ok("OK");
    }

    @RequestMapping(value = "/favicon.ico", method = {RequestMethod.GET, RequestMethod.HEAD})
    public ResponseEntity<Void> favicon() {
        return ResponseEntity.noContent().build();
    }
}
