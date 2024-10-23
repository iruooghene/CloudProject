package africa.semicolon.service;

import africa.semicolon.dtos.requests.RegisterRequest;
import africa.semicolon.dtos.response.RegisterResponse;
import org.springframework.stereotype.Service;

@Service
public interface UserService {
    RegisterResponse register(RegisterRequest request);

}
