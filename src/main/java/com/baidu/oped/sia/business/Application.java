package com.baidu.oped.sia.business;

import com.baidu.oped.sia.boot.exception.SystemExceptionHandler;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.web.ErrorMvcAutoConfiguration;
import org.springframework.context.annotation.Bean;

/**
 * demo application entrance.
 *
 * @author mason
 */
@SpringBootApplication(exclude = {ErrorMvcAutoConfiguration.class})
public class Application {

    @Bean
    public SystemExceptionHandler exceptionHandler() {
        return new SystemExceptionHandler();
    }

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
