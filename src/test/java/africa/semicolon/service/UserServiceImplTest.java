package africa.semicolon.service;

import africa.semicolon.dtos.requests.RegisterRequest;
import africa.semicolon.dtos.response.RegisterResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.*;
@SpringBootTest
public class UserServiceImplTest {

    @Autowired
    private UserService userService;

    @Test
    void register() {
        RegisterRequest request = new RegisterRequest();
        request.setPassword("password");
        request.setUsername("username");
        RegisterResponse response = userService.register(request);
        assertNotNull(response);
        assertEquals("Registered", response.getMessage());

    }
}