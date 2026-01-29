package com.example.course_service.controller;

import com.example.course_service.model.Course;
import com.example.course_service.service.CourseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/courses")
@CrossOrigin(origins = "*")
public class CourseController {

    @Autowired
    private CourseService service;

    // Add a new course
    @PostMapping
    public ResponseEntity<Course> create(@RequestBody Course course) {
        Course createdCourse = service.createCourse(course);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdCourse);
    }

    // Get all courses
    @GetMapping
    public ResponseEntity<List<Course>> getAll() {
        List<Course> courses = service.getAllCourses();
        return ResponseEntity.ok(courses);
    }

    // Get course by id
    @GetMapping("/{id}")
    public ResponseEntity<Course> getById(@PathVariable Long id) {
        Course course = service.getCourseById(id);
        return ResponseEntity.ok(course);
    }

    // Update course
    @PutMapping("/{id}")
    public ResponseEntity<Course> update(@PathVariable Long id,
                                         @RequestBody Course course) {
        Course updatedCourse = service.updateCourse(id, course);
        return ResponseEntity.ok(updatedCourse);
    }

    // Delete course
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.deleteCourse(id);
        return ResponseEntity.noContent().build();
    }
}

