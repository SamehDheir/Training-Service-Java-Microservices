package com.example.course_service.service;

import com.example.course_service.model.Course;
import com.example.course_service.repository.CourseRepository;
import org.springframework.stereotype.Service;
import org.springframework.beans.factory.annotation.Autowired;
import java.util.List;

@Service
public class CourseService {

    @Autowired
    private CourseRepository repository;

    // CREATE: Add a new course
    public Course createCourse(Course course) {
        if (course.getCourseName() == null || course.getCourseName().isEmpty()) {
            throw new IllegalArgumentException("Course name cannot be empty");
        }
        return repository.save(course);
    }

    // READ: Get all courses
    public List<Course> getAllCourses() {
        return repository.findAll();
    }

    // READ: Get course by ID
    public Course getCourseById(Long id) {
        return repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Course not found with ID: " + id));
    }

    // UPDATE: Update course
    public Course updateCourse(Long id, Course courseDetails) {
        Course course = repository.findById(id)
            .orElseThrow(() -> new RuntimeException("Course not found with ID: " + id));
        
        if (courseDetails.getCourseName() != null) {
            course.setCourseName(courseDetails.getCourseName());
        }
        if (courseDetails.getDescription() != null) {
            course.setDescription(courseDetails.getDescription());
        }
        if (courseDetails.getTrainerName() != null) {
            course.setTrainerName(courseDetails.getTrainerName());
        }
        
        return repository.save(course);
    }

    // DELETE: Delete course
    public void deleteCourse(Long id) {
        if (!repository.existsById(id)) {
            throw new RuntimeException("Course not found with ID: " + id);
        }
        repository.deleteById(id);
    }
}
