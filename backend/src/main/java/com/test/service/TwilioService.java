package com.test.service;

import com.twilio.Twilio;
import com.twilio.rest.api.v2010.account.Message;
import com.twilio.type.PhoneNumber;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.Random;


@Service
public class TwilioService {

    @Value("${twilio.account.sid}")
    private String accountSid;

    @Value("${twilio.auth.token}")
    private String authToken;

    @Value("${twilio.phone.number}")
    private String twilioPhoneNumber;

    @PostConstruct
    public void init() {
        Twilio.init(accountSid, authToken);
    }

    public void sendOtp(String userPhoneNumber, String otp) {
        System.out.println("userPhoneNumber is "+userPhoneNumber);
        Message message = Message.creator(

                new PhoneNumber(userPhoneNumber),
                new PhoneNumber(twilioPhoneNumber),
                "Your OTP for password reset is: " + otp
        ).create();
        System.out.println("OTP sent: " + message.getSid());
    }



    public String generateOtp(int length){
        String numbers = "0123456789";
        Random random = new Random();
        StringBuilder otp = new StringBuilder();
        for(int i = 0; i< length; i++){
            int index = random.nextInt(numbers.length());
            otp.append(numbers.charAt(index));}
      return otp.toString();
    }
}
