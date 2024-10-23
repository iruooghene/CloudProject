package africa.semicolon.data.repositories;

import africa.semicolon.data.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<User, Long> {

}
