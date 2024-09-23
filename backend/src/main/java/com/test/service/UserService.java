package com.test.service;
import com.test.model.SignupForm;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.test.repository.UserRepository;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public SignupForm saveUser(SignupForm signupForm) {
        return userRepository.save(signupForm);
    }
    public SignupForm loginUser(String email ,String password) {
        SignupForm user = userRepository.findByEmailAndPassword(email, password);

        if (user != null) {
            System.out.println(user);
            return user;
        } else {
            return null;
        }
    }
        public SignupForm findByPhoneNumber(String phoneNumber) {
            return userRepository.findByPhoneNumber(phoneNumber);
        }
}
