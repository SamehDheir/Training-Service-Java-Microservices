package com.example.enrollment_service.repository;

import com.example.enrollment_service.model.Enrollment;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface EnrollmentRepository extends JpaRepository<Enrollment, Long> {
    List<Enrollment> findByTraineeId(Long traineeId);
}
