package africa.semicolon.service;

import africa.semicolon.data.model.User;
import africa.semicolon.data.repositories.UserRepository;
import africa.semicolon.dtos.requests.RegisterRequest;
import africa.semicolon.dtos.response.RegisterResponse;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl implements UserService{

    @Autowired
    private final UserRepository userRepository;
    private final ModelMapper modelMapper;

    public UserServiceImpl(UserRepository userRepository, ModelMapper modelMapper) {
        this.userRepository = userRepository;
        this.modelMapper = modelMapper;
    }

    @Override
    public RegisterResponse register(RegisterRequest request) {
        User user = modelMapper.map(request, User.class);
        userRepository.save(user);
        var response = modelMapper.map(user, RegisterResponse.class);
        response.setMessage("Successfully registered");
        return response;


    }
}
