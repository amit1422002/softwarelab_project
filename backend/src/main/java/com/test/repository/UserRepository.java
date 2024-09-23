package com.test.repository;

import com.test.model.SignupForm;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<SignupForm, Long> {
    SignupForm findByEmailAndPassword(String email, String password);
    SignupForm findByPhoneNumber(String phoneNumber);
}
