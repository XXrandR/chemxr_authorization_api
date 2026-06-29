package com.chemxr.authorization_api.authorization_api;

import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.core.AuthorizationGrantType;
import org.springframework.security.oauth2.core.ClientAuthenticationMethod;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClient;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClientRepository;

import java.util.UUID;

@SpringBootApplication
public class AuthorizationApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(AuthorizationApiApplication.class, args);
    }

    @Bean
    ApplicationRunner init(JdbcTemplate jdbcTemplate, RegisteredClientRepository repository,
                           PasswordEncoder encoder) {
        return args -> {
            jdbcTemplate.update("""
                    DELETE FROM auth.oauth2_registered_client
                    WHERE client_id = ?
                    """, "chemxr-client");


            RegisteredClient client =
                    RegisteredClient.withId(UUID.randomUUID().toString())
                            .clientId("chemxr-client")
                            .clientSecret(encoder.encode("bonjour"))
                            .clientAuthenticationMethod(ClientAuthenticationMethod.CLIENT_SECRET_BASIC)
                            .authorizationGrantType(AuthorizationGrantType.CLIENT_CREDENTIALS)
                            .scope("api.read")
                            .build();

            repository.save(client);
        };
    }

}
