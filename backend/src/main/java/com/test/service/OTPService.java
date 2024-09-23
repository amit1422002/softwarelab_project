package com.test.service;

import com.test.model.SignupForm;
import com.test.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.Random;
import java.util.Map;

@Service
public class OTPService {

    @Autowired
    private UserRepository userRepository;

    private Map<String, String> otpData = new HashMap<>();  // Temporarily storing OTPs

    public String generateOTP(String phoneNumber) {

        String otp = String.valueOf(new Random().nextInt(900000) + 100000);
        otpData.put(phoneNumber, otp);

        System.out.println("Generated OTP: " + otp);
        return otp;
    }

    public boolean verifyOTP(String phoneNumber, String inputOtp) {
        String otp = otpData.get(phoneNumber);
        return otp != null && otp.equals(inputOtp);
    }

    public void clearOTP(String phoneNumber) {
        otpData.remove(phoneNumber);
    }
}
