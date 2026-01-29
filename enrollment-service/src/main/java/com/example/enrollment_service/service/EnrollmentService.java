package com.example.enrollment_service.service;

import com.example.enrollment_service.client.CourseClient;
import com.example.enrollment_service.model.Enrollment;
import com.example.enrollment_service.repository.EnrollmentRepository;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class EnrollmentService {

    private final EnrollmentRepository repository;
    private final CourseClient courseClient;

    public EnrollmentService(EnrollmentRepository repository, CourseClient courseClient) {
        this.repository = repository;
        this.courseClient = courseClient;
    }

    public Enrollment enroll(Long traineeId, Long courseId) {
        try {
            courseClient.getCourseById(courseId);
        } catch (Exception e) {
            throw new RuntimeException("Course not found with ID: " + courseId);
        }

        Enrollment enrollment = new Enrollment();
        enrollment.setTraineeId(traineeId);
        enrollment.setCourseId(courseId);
        enrollment.setProgress(0);
        enrollment.setCompleted(false);

        return repository.save(enrollment);
    }

    public List<Enrollment> getAllEnrollments() {
        return repository.findAll();
    }

    public Enrollment getEnrollmentById(Long id) {
        return repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Enrollment not found with ID: " + id));
    }

    public List<Enrollment> getEnrollmentsByTrainee(Long traineeId) {
        return repository.findByTraineeId(traineeId);
    }

    public Enrollment updateProgress(Long id, int progress) {
        Enrollment e = getEnrollmentById(id);
        e.setProgress(progress);
        e.setCompleted(progress == 100);
        return repository.save(e);
    }

    public Enrollment completeEnrollment(Long id) {
        return updateProgress(id, 100);
    }

    public void cancelEnrollment(Long id) {
        repository.deleteById(id);
    }
}
