

package com.test.controller;

import com.test.model.SignupForm;
import com.test.repository.UserRepository;
import com.test.service.TwilioService;
import com.test.service.UserService;
import com.test.utils.GlobalResponse;
import com.test.utils.GlobalResponseEnum;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

        import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/user")
public class AuthController {

    @Autowired
    private TwilioService twilioService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserService userService;

    private Map<String, String> otpStore = new HashMap<>();

    @PostMapping("/register")
    public SignupForm Signup(@RequestBody SignupForm signupForm) {
        return userService.saveUser(signupForm);
    }

    @PostMapping("/login")
    public SignupForm login(@RequestBody Map<String,String> map) {
        String email = map.get("email");
        String pass = map.get("pass");
        return  userService.loginUser(email,pass);
    }

    @PostMapping("/forgot-password")
    public  ResponseEntity<GlobalResponse> forgotPassword(@RequestBody Map<String, String> request) {
        String phoneNumber = request.get("phoneNumber");

        SignupForm user = userRepository.findByPhoneNumber(phoneNumber);

        if(user != null){

            if (!phoneNumber.startsWith("+")) {
                phoneNumber = "+91" + phoneNumber;
            }

            String otp = twilioService.generateOtp(5);
            otpStore.put(phoneNumber, otp);


            try {
                // Send the OTP to the user
                twilioService.sendOtp(phoneNumber, otp);
                return ResponseEntity.ok(
                        GlobalResponse.builder()
                                .status(GlobalResponseEnum.SUCCESS)
                                .msg("OTP HAS BEEN SENT TO: "+phoneNumber)
                                .build()
                );
            } catch (Exception e) {
                return ResponseEntity.ok(
                        GlobalResponse.builder()
                                .status(GlobalResponseEnum.ERROR)
                                .msg("FAILED TO SENT OTP SOMETHING WENT WRONG ON SERVER SIDE")
                                .err(e.getMessage())
                                .build()
                );
            }

        }else{
            return ResponseEntity.ok(
                    GlobalResponse.builder()
                            .status(GlobalResponseEnum.USER_NOT_FOUND)
                            .msg("USER ACCOUNT WITH "+phoneNumber+" DOESN'T EXIST")
                            .build()
            );

        }



    }


    @PostMapping("/verify-otp")
    public ResponseEntity<GlobalResponse> validateOtp(@RequestBody Map<String, String> request) {
        String phoneNumber = request.get("phoneNumber");
        String otp = request.get("otp");


        if (!phoneNumber.startsWith("+")) {
            phoneNumber = "+91" + phoneNumber;
        }

        // Validate the OTP
        String storedOtp = otpStore.get(phoneNumber);
        if (storedOtp != null && storedOtp.equals(otp)) {
            return ResponseEntity.ok(
                    GlobalResponse.builder()
                            .status(GlobalResponseEnum.SUCCESS)
                            .msg("OTP VERIFIED, YOU CAN RESET YOUR PASSWORD NOW")
                            .build()
            );
        } else {
            return ResponseEntity.ok(
                    GlobalResponse.builder()
                            .status(GlobalResponseEnum.INVALID_OTP)
                            .msg("INVALID OTP, TRY AGAIN")
                            .build()
            );
        }
    }


    @PostMapping("/reset-password")
    public ResponseEntity<GlobalResponse> resetPassword(@RequestBody Map<String, String> request) {
        String phoneNumber = request.get("phoneNumber");
        String newPassword = request.get("newPassword");
        String otp = request.get("otp");

            SignupForm user = userService.findByPhoneNumber(phoneNumber);

        if (!phoneNumber.startsWith("+")) {
            phoneNumber = "+91" + phoneNumber;
        }

        if (otp.equals(otpStore.get(phoneNumber))) {

            user.setPassword(newPassword);


            try {
                SignupForm saved  = userRepository.save(user);

                otpStore.remove(phoneNumber);
                return ResponseEntity.ok(
                        GlobalResponse.builder()
                                .status(GlobalResponseEnum.SUCCESS)
                                .msg("PASSWORD CHANGED ")
                                .build()
                );


            }catch (Exception e){
                e.printStackTrace();
                return ResponseEntity.ok(
                        GlobalResponse.builder()
                                .status(GlobalResponseEnum.ERROR)
                                .msg("SOMETHING WENT WRONG ")
                                .err(e.getMessage())
                                .build()
                );
            }


        } else {
            return ResponseEntity.ok(
                    GlobalResponse.builder()
                            .status(GlobalResponseEnum.INVALID_OTP)
                            .msg("INVALID OTP, TRY AGAIN LATER")
                            .build()
            );
        }
    }
}


