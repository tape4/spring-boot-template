package com.example.demo;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.core.env.Environment;

@Slf4j
@SpringBootApplication
public class DemoApplication {

	public static void main(String[] args) {
		SpringApplication.run(DemoApplication.class, args);
	}

	@Bean
	public ApplicationRunner applicationRunner(Environment environment) {
		return args -> {
			String activeProfiles = String.join(", ", environment.getActiveProfiles());
			log.info("Backend Application started with active profiles: {}",
					activeProfiles.isEmpty() ? "default" : activeProfiles);
		};
	}
}
