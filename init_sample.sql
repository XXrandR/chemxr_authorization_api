CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS app;

/* APP SCHEMA TABLES */
-- 1. countries
CREATE TABLE app.countries (
    id UUID PRIMARY KEY,
    code CHAR(3) NOT NULL CHECK (code ~ '^[A-Z]{3}$'),
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

-- 2. departments
CREATE TABLE app.departments (
    id UUID PRIMARY KEY,
    ubigeo_code CHAR(2) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

-- 3. provinces
CREATE TABLE app.provinces (
    id UUID PRIMARY KEY,
    department_id UUID NOT NULL,
    ubigeo_code CHAR(4) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    CONSTRAINT fk_prov_department FOREIGN KEY (department_id) REFERENCES app.departments(id) ON DELETE RESTRICT
);

-- 4. districts
CREATE TABLE app.districts (
    id UUID PRIMARY KEY,
    province_id UUID NOT NULL,
    ubigeo_code CHAR(6) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ,
    CONSTRAINT fk_dist_province FOREIGN KEY (province_id) REFERENCES app.provinces(id) ON DELETE RESTRICT
);

-- 5. icons
CREATE TABLE app.icons (
    id UUID PRIMARY KEY,
    code CHAR(3) NOT NULL,
    name VARCHAR(20) NOT NULL,
    type_img VARCHAR(50) NOT NULL,
    path VARCHAR(500) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

-- 6. resource_types
CREATE TABLE app.resource_types (
    id UUID PRIMARY KEY,
    code CHAR(3) NOT NULL,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(250),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

-- 7. course_modalities
CREATE TABLE app.course_modalities (
    id UUID PRIMARY KEY,
    code CHAR(3) NOT NULL,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(200),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

-- 8. course_conditions
CREATE TABLE app.course_conditions (
    id UUID PRIMARY KEY,
    code CHAR(3) NOT NULL,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(200),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

-- 9. course_visibility
CREATE TABLE app.course_visibility (
    id UUID PRIMARY KEY,
    code CHAR(3) NOT NULL,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(200),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

-- 10. course_roles
CREATE TABLE app.course_roles (
    id UUID PRIMARY KEY,
    code CHAR(3) NOT NULL,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(200),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

-- 11. module_view_types
CREATE TABLE app.module_view_types (
    id UUID PRIMARY KEY,
    code CHAR(3) NOT NULL,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(200),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

-- 12. academic_entity_types
CREATE TABLE app.academic_entity_types (
    id UUID PRIMARY KEY,
    code CHAR(3) NOT NULL,
    name VARCHAR(22) NOT NULL,
    description VARCHAR(230),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

-- 13. academic_categories
CREATE TABLE app.academic_categories (
    id UUID PRIMARY KEY,
    code CHAR(3) NOT NULL,
    name VARCHAR(150) NOT NULL,
    description VARCHAR(300),
    level SMALLINT,
    course_id UUID,
    color CHAR(6),
    icon_id UUID,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    updated_at TIMESTAMPTZ,
    CONSTRAINT fk_cat_course FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE RESTRICT,
    CONSTRAINT fk_cat_icon FOREIGN KEY (icon_id) REFERENCES app.icons(id) ON DELETE SET NULL
);

-- 14. academic_tags
CREATE TABLE app.academic_tags (
    id UUID PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    icon_id UUID,
    color CHAR(6),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    updated_at TIMESTAMPTZ,
    CONSTRAINT fk_tag_icon FOREIGN KEY (icon_id) REFERENCES app.icons(id) ON DELETE SET NULL
);

-- 15. companies
CREATE TABLE app.companies (
    id UUID PRIMARY KEY,
    tax_id BIGINT NOT NULL UNIQUE,
    name VARCHAR(500) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ
);

-- 16. people
CREATE TABLE app.people (
    id UUID PRIMARY KEY,
    document_type CHAR(3),
    client_code VARCHAR(20),
    document_number CHAR(8),
    full_name VARCHAR(200) NOT NULL,
    last_name VARCHAR(40),
    second_last_name VARCHAR(40),
    country_id UUID,
    district_id UUID,
    gender SMALLINT,
    phone_number VARCHAR(16) NOT NULL,
    birth_date DATE,
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    updated_at TIMESTAMPTZ,
    CONSTRAINT fk_people_country FOREIGN KEY (country_id) REFERENCES app.countries(id) ON DELETE RESTRICT,
    CONSTRAINT fk_people_district FOREIGN KEY (district_id) REFERENCES app.districts(id) ON DELETE RESTRICT
);

-- 18. academic_entities
CREATE TABLE app.academic_entities (
    id UUID PRIMARY KEY ,
    entity_type_id UUID NOT NULL,
    name VARCHAR(200) NOT NULL CHECK (name in ('STUDENT','TUTOR','AUDIT')), --(STUDENT,TUTOR,AUDIT)
    company_id UUID,
    person_id UUID,
    history_code VARCHAR(6),
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    updated_at TIMESTAMPTZ,
    CONSTRAINT fk_acad_entity_type FOREIGN KEY (entity_type_id) REFERENCES app.academic_entity_types(id) ON DELETE RESTRICT,
    CONSTRAINT fk_acad_company FOREIGN KEY (company_id) REFERENCES app.companies(id) ON DELETE SET NULL,
    CONSTRAINT fk_acad_user FOREIGN KEY (person_id) REFERENCES app.people(id) ON DELETE SET NULL,
    CONSTRAINT fk_acad_created_by FOREIGN KEY (created_by) REFERENCES app.people(id) ON DELETE SET NULL,
    CONSTRAINT fk_acad_updated_by FOREIGN KEY (updated_by) REFERENCES app.people(id) ON DELETE SET NULL
);

-- 19. courses
CREATE TABLE app.courses (
    id UUID PRIMARY KEY,
    academic_entity_id UUID,
    category_id UUID,
    name VARCHAR(200) NOT NULL,
    description VARCHAR(1000),
    modality_id UUID NOT NULL,
    condition_id UUID NOT NULL,
    visibility_id UUID NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    color CHAR(6),
    icon_id UUID,
    district_id UUID,
    address VARCHAR(300),
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    start_date DATE,
    end_date DATE,
    created_by UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    updated_at TIMESTAMPTZ,
    CONSTRAINT fk_course_acad_entity FOREIGN KEY (academic_entity_id) REFERENCES app.academic_entities(id) ON DELETE SET NULL,
    CONSTRAINT fk_course_category FOREIGN KEY (category_id) REFERENCES app.academic_categories(id) ON DELETE SET NULL,
    CONSTRAINT fk_course_modality FOREIGN KEY (modality_id) REFERENCES app.course_modalities(id) ON DELETE RESTRICT,
    CONSTRAINT fk_course_condition FOREIGN KEY (condition_id) REFERENCES app.course_conditions(id) ON DELETE RESTRICT,
    CONSTRAINT fk_course_visibility FOREIGN KEY (visibility_id) REFERENCES app.course_visibility(id) ON DELETE RESTRICT,
    CONSTRAINT fk_course_icon FOREIGN KEY (icon_id) REFERENCES app.icons(id) ON DELETE SET NULL,
    CONSTRAINT fk_course_district FOREIGN KEY (district_id) REFERENCES app.districts(id) ON DELETE SET NULL,
    CONSTRAINT fk_course_created_by FOREIGN KEY (created_by) REFERENCES app.people(id) ON DELETE RESTRICT,
    CONSTRAINT fk_course_updated_by FOREIGN KEY (updated_by) REFERENCES app.people(id) ON DELETE SET NULL
);

-- 20. course_tags
CREATE TABLE app.course_tags (
    course_id UUID NOT NULL,
    tag_id UUID NOT NULL,
    PRIMARY KEY (course_id, tag_id),
    CONSTRAINT fk_coursetag_course FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE CASCADE,
    CONSTRAINT fk_coursetag_tag FOREIGN KEY (tag_id) REFERENCES app.academic_tags(id) ON DELETE CASCADE
);

-- 21. course_modules
CREATE TABLE app.course_modules (
    id UUID PRIMARY KEY,
    course_id UUID NOT NULL,
    sequence SMALLINT NOT NULL,
    name VARCHAR(200) NOT NULL,
    description VARCHAR(1000),
    icon_id UUID,
    color CHAR(6),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_visible BOOLEAN NOT NULL DEFAULT TRUE,
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    updated_at TIMESTAMPTZ,
    CONSTRAINT fk_module_course FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE CASCADE,
    CONSTRAINT fk_module_icon FOREIGN KEY (icon_id) REFERENCES app.icons(id) ON DELETE SET NULL,
    CONSTRAINT fk_module_created_by FOREIGN KEY (created_by) REFERENCES app.people(id) ON DELETE SET NULL,
    CONSTRAINT fk_module_updated_by FOREIGN KEY (updated_by) REFERENCES app.people(id) ON DELETE SET NULL
);

-- 22. module_elements
CREATE TABLE app.module_elements (
    id UUID PRIMARY KEY,
    module_id UUID NOT NULL,
    sequence SMALLINT NOT NULL,
    code VARCHAR(20),
    name VARCHAR(150) NOT NULL,
    description VARCHAR(1000),
    icon_id UUID,
    color CHAR(6),
    pos_x SMALLINT,
    pos_y SMALLINT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_visible BOOLEAN NOT NULL DEFAULT TRUE,
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    updated_at TIMESTAMPTZ,
    CONSTRAINT fk_element_module FOREIGN KEY (module_id) REFERENCES app.course_modules(id) ON DELETE CASCADE,
    CONSTRAINT fk_element_icon FOREIGN KEY (icon_id) REFERENCES app.icons(id) ON DELETE SET NULL,
    CONSTRAINT fk_element_created_by FOREIGN KEY (created_by) REFERENCES app.people(id) ON DELETE SET NULL,
    CONSTRAINT fk_element_updated_by FOREIGN KEY (updated_by) REFERENCES app.people(id) ON DELETE SET NULL
);

-- 23. resources
CREATE TABLE app.resources (
    id UUID PRIMARY KEY,
    resource_type_id UUID NOT NULL,
    name VARCHAR(200) NOT NULL,
    description VARCHAR(1000),
    path VARCHAR(1000),
    url VARCHAR(1000),
    mime_type VARCHAR(100),
    size BIGINT,
    extension VARCHAR(10),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    updated_at TIMESTAMPTZ,
    CONSTRAINT fk_resource_type FOREIGN KEY (resource_type_id) REFERENCES app.resource_types(id) ON DELETE RESTRICT,
    CONSTRAINT fk_resource_created_by FOREIGN KEY (created_by) REFERENCES app.people(id) ON DELETE SET NULL,
    CONSTRAINT fk_resource_updated_by FOREIGN KEY (updated_by) REFERENCES app.people(id) ON DELETE SET NULL
);

-- 24. resource_assignments
CREATE TABLE app.resource_assignments (
    id UUID PRIMARY KEY,
    resource_id UUID NOT NULL,
    course_id UUID,
    module_id UUID,
    element_id UUID,
    sequence SMALLINT NOT NULL DEFAULT 1,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    updated_at TIMESTAMPTZ,
    CONSTRAINT fk_assign_resource FOREIGN KEY (resource_id) REFERENCES app.resources(id) ON DELETE CASCADE,
    CONSTRAINT fk_assign_course FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE CASCADE,
    CONSTRAINT fk_assign_module FOREIGN KEY (module_id) REFERENCES app.course_modules(id) ON DELETE CASCADE,
    CONSTRAINT fk_assign_element FOREIGN KEY (element_id) REFERENCES app.module_elements(id) ON DELETE CASCADE,
    CONSTRAINT fk_assign_created_by FOREIGN KEY (created_by) REFERENCES app.people(id) ON DELETE SET NULL,
    CONSTRAINT fk_assign_updated_by FOREIGN KEY (updated_by) REFERENCES app.people(id) ON DELETE SET NULL,
    CONSTRAINT chk_assign_target CHECK (
        (course_id IS NOT NULL AND module_id IS NULL AND element_id IS NULL) OR
        (module_id IS NOT NULL AND course_id IS NULL AND element_id IS NULL) OR
        (element_id IS NOT NULL AND course_id IS NULL AND module_id IS NULL)
    )
);

-- 25. ar_vr_scenes
CREATE TABLE app.ar_vr_scenes (
    id UUID PRIMARY KEY,
    resource_id UUID NOT NULL,
    name VARCHAR(200),
    description VARCHAR(1000),
    engine VARCHAR(50),
    format VARCHAR(20),
    has_marker BOOLEAN NOT NULL DEFAULT FALSE,
    marker_path VARCHAR(1000),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_by UUID,
    updated_at TIMESTAMPTZ,
    CONSTRAINT fk_scene_resource FOREIGN KEY (resource_id) REFERENCES app.resources(id) ON DELETE CASCADE,
    CONSTRAINT fk_scene_created_by FOREIGN KEY (created_by) REFERENCES app.people(id) ON DELETE SET NULL,
    CONSTRAINT fk_scene_updated_by FOREIGN KEY (updated_by) REFERENCES app.people(id) ON DELETE SET NULL
);

-- 26. course_members
CREATE TABLE app.course_members (
    course_id UUID NOT NULL,
    person_id UUID NOT NULL,
    role_id UUID NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    joined_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (course_id, person_id),
    CONSTRAINT fk_member_course FOREIGN KEY (course_id) REFERENCES app.courses(id) ON DELETE CASCADE,
    CONSTRAINT fk_member_user FOREIGN KEY (person_id) REFERENCES app.people(id) ON DELETE CASCADE,
    CONSTRAINT fk_member_role FOREIGN KEY (role_id) REFERENCES app.course_roles(id) ON DELETE RESTRICT,
    CONSTRAINT fk_member_created_by FOREIGN KEY (created_by) REFERENCES app.people(id) ON DELETE SET NULL
);

/*      INDICES     */
CREATE INDEX idx_prov_department_id ON app.provinces(department_id);
CREATE INDEX idx_dist_province_id ON app.districts(province_id);
CREATE INDEX idx_categories_parent_id ON app.academic_categories(course_id);
CREATE INDEX idx_categories_icon_id ON app.academic_categories(icon_id);
CREATE INDEX idx_tags_icon_id ON app.academic_tags(icon_id);
CREATE INDEX idx_people_country_id ON app.people(country_id);
CREATE INDEX idx_people_district_id ON app.people(district_id);
CREATE INDEX idx_people_created_by ON app.people(created_by);
CREATE INDEX idx_people_updated_by ON app.people(updated_by);
CREATE INDEX idx_users_person_id ON app.people(id);
CREATE INDEX idx_users_created_by ON app.people(created_by);
CREATE INDEX idx_users_updated_by ON app.people(updated_by);
CREATE INDEX idx_acad_entities_type_id ON app.academic_entities(entity_type_id);
CREATE INDEX idx_acad_entities_company_id ON app.academic_entities(company_id);
CREATE INDEX idx_acad_entities_user_id ON app.academic_entities(person_id);
CREATE INDEX idx_acad_entities_created_by ON app.academic_entities(created_by);
CREATE INDEX idx_acad_entities_updated_by ON app.academic_entities(updated_by);
CREATE INDEX idx_courses_acad_entity_id ON app.courses(academic_entity_id);
CREATE INDEX idx_courses_category_id ON app.courses(category_id);
CREATE INDEX idx_courses_modality_id ON app.courses(modality_id);
CREATE INDEX idx_courses_condition_id ON app.courses(condition_id);
CREATE INDEX idx_courses_visibility_id ON app.courses(visibility_id);
CREATE INDEX idx_courses_icon_id ON app.courses(icon_id);
CREATE INDEX idx_courses_district_id ON app.courses(district_id);
CREATE INDEX idx_courses_created_by ON app.courses(created_by);
CREATE INDEX idx_courses_updated_by ON app.courses(updated_by);
CREATE INDEX idx_course_tags_tag_id ON app.course_tags(tag_id);
CREATE INDEX idx_modules_course_id ON app.course_modules(course_id);
CREATE INDEX idx_modules_icon_id ON app.course_modules(icon_id);
CREATE INDEX idx_modules_created_by ON app.course_modules(created_by);
CREATE INDEX idx_modules_updated_by ON app.course_modules(updated_by);
CREATE INDEX idx_elements_module_id ON app.module_elements(module_id);
CREATE INDEX idx_elements_icon_id ON app.module_elements(icon_id);
CREATE INDEX idx_elements_created_by ON app.module_elements(created_by);
CREATE INDEX idx_elements_updated_by ON app.module_elements(updated_by);
CREATE INDEX idx_resources_type_id ON app.resources(resource_type_id);
CREATE INDEX idx_resources_created_by ON app.resources(created_by);
CREATE INDEX idx_resources_updated_by ON app.resources(updated_by);
CREATE INDEX idx_assignments_resource_id ON app.resource_assignments(resource_id);
CREATE INDEX idx_assignments_course_id ON app.resource_assignments(course_id);
CREATE INDEX idx_assignments_module_id ON app.resource_assignments(module_id);
CREATE INDEX idx_assignments_element_id ON app.resource_assignments(element_id);
CREATE INDEX idx_scenes_resource_id ON app.ar_vr_scenes(resource_id);
CREATE INDEX idx_scenes_created_by ON app.ar_vr_scenes(created_by);
CREATE INDEX idx_scenes_updated_by ON app.ar_vr_scenes(updated_by);
CREATE INDEX idx_members_user_id ON app.course_members(person_id);
CREATE INDEX idx_members_role_id ON app.course_members(role_id);
CREATE INDEX idx_members_created_by ON app.course_members(created_by);

/*  DOCUMENTATION   */
COMMENT ON TABLE app.countries IS 'List of countries';
COMMENT ON TABLE app.departments IS 'Departments of country (fourth-level)';
COMMENT ON TABLE app.provinces IS 'Provinces (second-level)';
COMMENT ON TABLE app.districts IS 'Districts (third-level)';
COMMENT ON TABLE app.icons IS 'Icons for UI elements';
COMMENT ON TABLE app.resource_types IS 'Types of academic resources (video, pdf, etc.)';
COMMENT ON TABLE app.course_modalities IS 'Course delivery mode (online, in-person, hybrid)';
COMMENT ON TABLE app.course_conditions IS 'Course status (draft, published, archived)';
COMMENT ON TABLE app.course_visibility IS 'Who can see the course';
COMMENT ON TABLE app.course_roles IS 'User roles within a course (student, teacher, admin)';
COMMENT ON TABLE app.module_view_types IS 'Visualization layout for modules';
COMMENT ON TABLE app.academic_entity_types IS 'Type of academic entity (university, institute, school)';
COMMENT ON TABLE app.academic_categories IS 'Hierarchical course categories';
COMMENT ON TABLE app.academic_tags IS 'Tags for course classification';
COMMENT ON TABLE app.companies IS 'Institutional partners or sponsors';
COMMENT ON TABLE app.people IS 'Person master data (students, teachers, etc.)';
COMMENT ON TABLE app.academic_entities IS 'Institutions offering courses';
COMMENT ON TABLE app.courses IS 'Course master data';
COMMENT ON TABLE app.course_tags IS 'Many-to-many between courses and tags';
COMMENT ON TABLE app.course_modules IS 'Modules inside a course';
COMMENT ON TABLE app.module_elements IS 'Learning elements (lessons, quizzes, etc.) inside a module';
COMMENT ON TABLE app.resources IS 'Reusable academic resources (files, links, videos)';
COMMENT ON TABLE app.resource_assignments IS 'Polymorphic assignment of resources to courses/modules/elements';
COMMENT ON TABLE app.ar_vr_scenes IS 'AR/VR scene metadata linked to a resource';
COMMENT ON TABLE app.course_members IS 'Members enrolled in a course with their roles';


/*   SCHEMA AUTH    */
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

COMMENT ON TABLE auth.client IS 'OAuth2 clients registered in the authorization server (applications that request tokens).';
COMMENT ON TABLE auth.authorization IS 'Stores OAuth2 authorizations including access tokens, refresh tokens, and authorization codes.';
COMMENT ON TABLE auth.authorization_consent IS 'Stores user consent decisions for OAuth2 clients and granted authorities/scopes.';
COMMENT ON TABLE auth.identity IS 'Represents authenticated users with credentials and verification status.';
COMMENT ON TABLE auth.verification_token IS 'Temporary tokens used to verify email or phone during registration or updates.';
COMMENT ON TABLE auth.role IS 'Defines roles used for authorization and access control.';
COMMENT ON TABLE auth.identity_role IS 'Mapping between users (identity) and assigned roles.';
