package com.chemxr.authorization_api.authorization_api.service;

import com.chemxr.authorization_api.authorization_api.domain.Identity;
import com.chemxr.authorization_api.authorization_api.repository.IdentityRepository;
import lombok.RequiredArgsConstructor;
import org.jspecify.annotations.NonNull;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.*;
import org.springframework.stereotype.Service;

import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class JpaUserDetailsService implements UserDetailsService {
    IdentityRepository identityRepository;

    @Override
    public UserDetails loadUserByUsername(@NonNull String username) throws UsernameNotFoundException {
        Identity identity = identityRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
        Set<GrantedAuthority> authorities = identity.getRoles().stream()
                .map(role -> new SimpleGrantedAuthority("ROLE_" + role.getName()))
                .collect(Collectors.toSet());
        return new User(
                identity.getUsername(),
                identity.getPasswordHash(),
                identity.isActive() && !identity.isBlocked(),
                true, true, true,
                authorities
        );
    }
}
