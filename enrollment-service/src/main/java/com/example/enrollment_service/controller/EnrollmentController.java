package com.example.enrollment_service.controller;

import com.example.enrollment_service.model.Enrollment;
import com.example.enrollment_service.service.EnrollmentService;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/enrollments")
public class EnrollmentController {

    private final EnrollmentService service;

    public EnrollmentController(EnrollmentService service) {
        this.service = service;
    }

    @PostMapping
    public Enrollment enroll(@RequestParam Long traineeId, @RequestParam Long courseId) {
        return service.enroll(traineeId, courseId);
    }

    @GetMapping
    public List<Enrollment> getAllEnrollments() {
        return service.getAllEnrollments();
    }

    @GetMapping("/{id}")
    public Enrollment getEnrollmentById(@PathVariable Long id) {
        return service.getEnrollmentById(id);
    }

    @GetMapping("/trainee/{traineeId}")
    public List<Enrollment> getEnrollmentsByTrainee(@PathVariable Long traineeId) {
        return service.getEnrollmentsByTrainee(traineeId);
    }

    @PutMapping("/{id}/progress")
    public Enrollment updateProgress(@PathVariable Long id, @RequestParam int progress) {
        return service.updateProgress(id, progress);
    }

    @PutMapping("/{id}/complete")
    public Enrollment completeEnrollment(@PathVariable Long id) {
        return service.completeEnrollment(id);
    }

    @DeleteMapping("/{id}")
    public void cancelEnrollment(@PathVariable Long id) {
        service.cancelEnrollment(id);
    }
}
