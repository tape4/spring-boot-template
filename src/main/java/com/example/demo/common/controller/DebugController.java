package com.example.demo.common.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
@RequiredArgsConstructor
public class DebugController {

    @Value("${commit.hash}")
    private String commitHash;

    @GetMapping("/hash")
    public String hashCheck() {
        return commitHash;
    }
}
