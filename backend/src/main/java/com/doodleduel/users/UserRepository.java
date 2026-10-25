package com.doodleduel.users;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface UserRepository extends JpaRepository<User, UUID> {

    Optional<User> findByUsername(String username);

    boolean existsByUsername(String username);

    @Query("SELECT u FROM User u ORDER BY u.xp DESC")
    List<User> findTopByXp(Pageable pageable);

    @Query("SELECT u FROM User u ORDER BY u.bestScore DESC")
    List<User> findTopByBestScore(Pageable pageable);
}
