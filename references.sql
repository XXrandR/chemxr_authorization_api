/*   SCHEMA AUTH    */
-- CREATE TABLE auth.client (
CREATE TABLE auth.oauth2_registered_client (
    id VARCHAR(255) PRIMARY KEY,
    client_id VARCHAR(255) NOT NULL,
    client_id_issued_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    client_secret VARCHAR(255),
    client_secret_expires_at TIMESTAMPTZ,
    client_name VARCHAR(255) NOT NULL,
    client_authentication_methods VARCHAR(1000) NOT NULL,
    authorization_grant_types VARCHAR(1000) NOT NULL,
    redirect_uris VARCHAR(1000),
    post_logout_redirect_uris VARCHAR(1000),
    scopes VARCHAR(1000) NOT NULL,
    client_settings VARCHAR(2000) NOT NULL,
    token_settings VARCHAR(2000) NOT NULL
);

-- CREATE TABLE auth.authorization (
CREATE TABLE auth.oauth2_authorization (
    id VARCHAR(255) PRIMARY KEY,
    registered_client_id VARCHAR(255) NOT NULL,
    principal_name VARCHAR(255) NOT NULL,
    authorization_grant_type VARCHAR(255) NOT NULL,
    authorized_scopes VARCHAR(1000),
    attributes VARCHAR(4000),
    state VARCHAR(500),
    authorization_code_value VARCHAR(4000),
    authorization_code_issued_at TIMESTAMPTZ,
    authorization_code_expires_at TIMESTAMPTZ,
    authorization_code_metadata VARCHAR(2000),
    access_token_value VARCHAR(4000),
    access_token_issued_at TIMESTAMPTZ,
    access_token_expires_at TIMESTAMPTZ,
    access_token_metadata VARCHAR(2000),
    access_token_type VARCHAR(255),
    access_token_scopes VARCHAR(1000),
    refresh_token_value VARCHAR(4000),
    refresh_token_issued_at TIMESTAMPTZ,
    refresh_token_expires_at TIMESTAMPTZ,
    refresh_token_metadata VARCHAR(2000),
    oidc_id_token_value VARCHAR(4000),
    oidc_id_token_issued_at TIMESTAMPTZ,
    oidc_id_token_expires_at TIMESTAMPTZ,
    oidc_id_token_metadata VARCHAR(2000),
    oidc_id_token_claims VARCHAR(2000),
    user_code_value VARCHAR(4000),
    user_code_issued_at TIMESTAMPTZ,
    user_code_expires_at TIMESTAMPTZ,
    user_code_metadata VARCHAR(2000),
    device_code_value VARCHAR(4000),
    device_code_issued_at TIMESTAMPTZ,
    device_code_expires_at TIMESTAMPTZ,
    device_code_metadata VARCHAR(2000)
);

CREATE TABLE auth.oauth2_authorization_consent (
    registered_client_id VARCHAR(255) NOT NULL,
    principal_name VARCHAR(255) NOT NULL,
    authorities VARCHAR(1000) NOT NULL,
    PRIMARY KEY (registered_client_id, principal_name)
);

CREATE TABLE auth.identity (
    id UUID PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    phone_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_blocked BOOLEAN NOT NULL DEFAULT FALSE,
    person_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

CREATE TABLE auth.verification_token (
    id UUID PRIMARY KEY,
    identity_id UUID NOT NULL,
    type VARCHAR(20) NOT NULL, -- EMAIL / PHONE
    target VARCHAR(255) NOT NULL,
    code VARCHAR(10) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    consumed_at TIMESTAMPTZ,
    attempts INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (identity_id) REFERENCES auth.identity(id) ON DELETE CASCADE
);

CREATE TABLE auth.role (
    id UUID PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE auth.identity_role (
    identity_id UUID NOT NULL,
    role_id UUID NOT NULL,
    PRIMARY KEY (identity_id, role_id),
    FOREIGN KEY (identity_id) REFERENCES auth.identity(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES auth.role(id) ON DELETE CASCADE
);

CREATE TABLE auth.external_identity (
    id UUID PRIMARY KEY,

    identity_id UUID NOT NULL,

    /*
     * External identity provider.
     *
     * Examples:
     * GOOGLE
     * MICROSOFT
     * FACEBOOK
     * APPLE
     * GITHUB
     */
    provider VARCHAR(30) NOT NULL,

    /*
     * OIDC issuer.
     *
     * Google:
     *   https://accounts.google.com
     *
     * Microsoft:
     *   https://login.microsoftonline.com/{tenant}/v2.0
     *
     * NULL is allowed for providers where issuer
     * is not part of the identity model you use.
     */
    issuer VARCHAR(500),

    /*
     * Stable identifier assigned by the provider.
     *
     * Google  -> sub
     * Microsoft -> oid/sub
     * Apple   -> sub
     * Facebook -> user ID
     * GitHub  -> user ID
     */
    provider_subject VARCHAR(255) NOT NULL,

    /*
     * Microsoft Entra tenant ID.
     *
     * NULL for providers where tenant concepts don't apply.
     */
    tenant_id VARCHAR(255),

    /*
     * Provider profile information.
     *
     * These are attributes, NOT identity keys.
     */
    email VARCHAR(255),
    email_verified BOOLEAN,
    name VARCHAR(255),
    given_name VARCHAR(255),
    family_name VARCHAR(255),
    picture_url VARCHAR(1000),
    profile_url VARCHAR(1000),

    /*
     * Provider's preferred username.
     *
     * Informational only.
     */
    preferred_username VARCHAR(255),

    /*
     * BCP-47 locale, e.g.:
     * en-US
     * es-PE
     */
    locale VARCHAR(20),

    /*
     * Google Workspace / Cloud hosted domain.
     *
     * Example:
     * company.com
     */
    hosted_domain VARCHAR(255),

    /*
     * Additional provider-specific claims.
     *
     * Do not put authentication credentials here.
     */
    metadata JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    CONSTRAINT uq_external_identity_provider_subject
        UNIQUE (
            provider,
            issuer,
            provider_subject
        ),
    CONSTRAINT fk_external_identity_identity
        FOREIGN KEY (identity_id)
        REFERENCES auth.identity(id)
        ON DELETE CASCADE
);

COMMENT ON TABLE auth.client IS 'OAuth2 clients registered in the authorization server (applications that request tokens).';
COMMENT ON TABLE auth.authorization IS 'Stores OAuth2 authorizations including access tokens, refresh tokens, and authorization codes.';
COMMENT ON TABLE auth.authorization_consent IS 'Stores user consent decisions for OAuth2 clients and granted authorities/scopes.';
COMMENT ON TABLE auth.identity IS 'Represents authenticated users with credentials and verification status.';
COMMENT ON TABLE auth.verification_token IS 'Temporary tokens used to verify email or phone during registration or updates.';
COMMENT ON TABLE auth.role IS 'Defines roles used for authorization and access control.';
COMMENT ON TABLE auth.identity_role IS 'Mapping between users (identity) and assigned roles.';

SELECt * FROM auth.role
SELECT * FROM auth.oauth2_registered_client
SELECT * FROM auth.client
SELECT * FROM auth.client
SELECT * FROM auth.oauth2_authorization

SELECT * FROM oauth2_registered_client

SELECT table_schema, table_name FROM information_schema.tables WHERE table_name ILIKE '%registered%client%';
