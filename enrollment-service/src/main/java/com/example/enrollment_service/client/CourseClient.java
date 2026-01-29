package com.example.enrollment_service.client;

import com.example.enrollment_service.dto.CourseDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "course-service")
public interface CourseClient {

    @GetMapping("/api/courses/{id}")
    CourseDto getCourseById(@PathVariable("id") Long id);
}
