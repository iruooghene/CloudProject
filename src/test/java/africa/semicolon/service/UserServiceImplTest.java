package africa.semicolon.service;

import africa.semicolon.dtos.requests.RegisterRequest;
import africa.semicolon.dtos.response.RegisterResponse;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;

import static org.junit.jupiter.api.Assertions.*;
@SpringBootTest
public class UserServiceImplTest {

    @Autowired
    private UserService userService;

    @Test
//    @Sql(scripts ={"/database/db.sql"})
    public void register() {
        RegisterRequest request = new RegisterRequest();
        request.setName("Vic");
        request.setEmail("eboh@gmail.com");
        request.setUsername("Victoria");
        request.setPassword("NewPassword");
        RegisterResponse response = userService.register(request);
        assertNotNull(response);
//        assertEquals("Success", response.getMessage());
        assertEquals("Successfully registered",response.getMessage());
    }
}