package com.chemxr.authorization_api.authorization_api.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.oauth2.core.OAuth2Token;
import org.springframework.security.oauth2.server.authorization.OAuth2AuthorizationConsentService;
import org.springframework.security.oauth2.server.authorization.OAuth2AuthorizationService;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClientRepository;
import org.springframework.security.oauth2.server.authorization.token.*;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class AuthorizationServerConfig {

    private final OAuth2TokenGenerator<? extends OAuth2Token> tokenGenerator;

    @Bean
    @Order(1)
    public SecurityFilterChain authorizationServerSecurityFilterChain(HttpSecurity http, RegisteredClientRepository registeredClientRepository,
                                                                      OAuth2AuthorizationService authorizationService,
                                                                      OAuth2AuthorizationConsentService authorizationConsentService,
                                                                      AuthenticationManager authenticationManager) {
        http.oauth2AuthorizationServer(server -> {
            http.securityMatcher(server.getEndpointsMatcher());
            server.tokenGenerator(tokenGenerator);
            server.clientAuthentication(Customizer.withDefaults());
            server.tokenEndpoint(Customizer.withDefaults());
            server.tokenIntrospectionEndpoint(Customizer.withDefaults());
            server.tokenRevocationEndpoint(Customizer.withDefaults());
        });

        http
                .securityMatcher("/oauth2/**", "/.well-known/**")
                .csrf(csrf -> csrf.ignoringRequestMatchers("/oauth2/**", "/.well-known/**"))
                .authorizeHttpRequests(auth -> auth.anyRequest().authenticated());

        return http.build();
    }

}
