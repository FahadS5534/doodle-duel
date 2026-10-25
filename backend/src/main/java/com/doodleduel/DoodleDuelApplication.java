package com.doodleduel;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class DoodleDuelApplication {

    public static void main(String[] args) {
        SpringApplication.run(DoodleDuelApplication.class, args);
    }
}
