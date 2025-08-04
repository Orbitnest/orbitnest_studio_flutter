# OrbitNest Studio Backend API Documentation

## Overview

OrbitNest Studio Backend provides a Supabase-compatible platform for managing projects, authentication, databases, and edge functions. This documentation covers all available API endpoints with curl examples for frontend implementation.

**Key Features:**
- **Dual API Keys**: Each project gets one anon key (client-side) and one service role key (server-side)
- **Supabase Compatibility**: JWT-based authentication system compatible with Supabase client libraries
- **Database Isolation**: Each project has its own PostgreSQL database with auth schema
- **Secure Authentication**: Project-scoped access prevents cross-project data leaks
- **Key Pair Replacement**: Creating new keys replaces both existing keys simultaneously

**Base URL:** `http://localhost:3001`

## API URL Structure Overview

The OrbitNest Studio API follows a consistent hierarchical URL structure:

### Admin Management Routes (`/api/`)
- **Authentication**: `/api/auth/*` - Admin signup, signin, password management
- **Admin Users**: `/api/admin/*` - Admin user management and API keys  
- **Projects**: `/api/projects/*` - Project creation, management, and API key management
- **Database**: `/api/database/*` - System health and database operations

### Project-Scoped Routes (`/api/projects/:projectId/`)
- **Project Auth**: `/api/projects/:projectId/auth/*` - Project user authentication
- **Database Operations**: `/api/projects/:projectId/database/*` - Database management
- **Edge Functions**: `/api/projects/:projectId/functions/*` - Function management
- **Environment Variables**: `/api/projects/:projectId/environment-variables/*` - Env var management
- **Logging**: `/api/projects/:projectId/logs/*` - Log monitoring and analytics

### Authenticated Project Routes (`/api/project/:slug/`)
- **Project Info**: `/api/project/:slug/info` - Project information with API key auth
- **Health Check**: `/api/project/:slug/health` - Project health status
- **Auth Test**: `/api/project/:slug/test-auth` - API key authentication testing

### Public Function Invocation Routes (Supabase-compatible)
- **Function Execution**: `/projects/:slug/functions/v1/:functionName` - Direct function invocation

## Table of Contents

1. [Authentication (Admin)](#authentication-admin)
2. [Admin User Management](#admin-user-management)
3. [Project Management](#project-management)
4. [Project API Key Authentication](#project-api-key-authentication)
5. [Project Authentication](#project-authentication)
6. [Edge Functions](#edge-functions)
7. [Environment Variables](#environment-variables)
8. [Database Operations](#database-operations)
9. [Logging & Monitoring](#logging--monitoring)
10. [Health Checks](#health-checks)
11. [Error Responses](#error-responses)

---

## Authentication (Admin)

### 1. Request Email Verification

Start the admin registration process by requesting email verification.

**Endpoint:** `POST /api/auth/request-verification`

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
  "email": "admin@orbitnest.io",
  "password": "SecurePass123!"
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/auth/request-verification \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@orbitnest.io",
    "password": "SecurePass123!"
  }'
```

**Response (200):**
```json
{
  "success": true,
  "message": "Verification code sent to email",
  "email": "admin@orbitnest.io"
}
```

### 2. Complete Admin Signup

Complete the registration process with the verification code.

**Endpoint:** `POST /api/auth/signup`

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@orbitnest.io",
    "password": "SecurePass123!",
    "code": "1234"
  }'
```

**Response (201):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 900,
  "token_type": "Bearer",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "admin@orbitnest.io",
    "is_active": true,
    "created_at": "2025-01-28T10:00:00Z"
  }
}
```

### 3. Admin Sign In

Sign in an existing admin user.

**Endpoint:** `POST /api/auth/signin`

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@orbitnest.io",
    "password": "SecurePass123!"
  }'
```

**Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 900,
  "token_type": "Bearer",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "admin@orbitnest.io",
    "is_active": true,
    "last_sign_in_at": "2025-01-28T10:00:00Z"
  }
}
```

### 4. Get Admin Profile

Get the current admin's profile information.

**Endpoint:** `GET /api/auth/profile`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Curl Example:**
```bash
curl -X GET http://localhost:3001/api/auth/profile \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "admin@orbitnest.io",
  "is_active": true,
  "created_at": "2025-01-28T10:00:00Z",
  "last_sign_in_at": "2025-01-28T10:00:00Z"
}
```

### 5. Refresh Access Token

Refresh the access token using the refresh token.

**Endpoint:** `POST /api/auth/refresh`

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }'
```

**Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 900,
  "token_type": "Bearer"
}
```

### 6. Sign Out

Sign out the current admin user.

**Endpoint:** `POST /api/auth/signout`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/auth/signout \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }'
```

**Response (200):**
```json
{
  "success": true,
  "message": "Signed out successfully"
}
```

### 7. Request Password Reset

Request a password reset OTP for an admin account.

**Endpoint:** `POST /api/auth/reset-password-request`

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
  "email": "admin@orbitnest.io"
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/auth/reset-password-request \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@orbitnest.io"
  }'
```

**Response (200):**
```json
{
  "success": true,
  "message": "If the email exists, a password reset code has been sent"
}
```

### 8. Reset Password with OTP

Reset password using the OTP received via email.

**Endpoint:** `POST /api/auth/reset-password`

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
  "email": "admin@orbitnest.io",
  "code": "1234",
  "new_password": "NewSecurePass123!"
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@orbitnest.io",
    "code": "1234",
    "new_password": "NewSecurePass123!"
  }'
```

**Response (200):**
```json
{
  "success": true,
  "message": "Password reset successfully"
}
```

### 9. Change Password (Authenticated)

Change the current admin's password (requires current password).

**Endpoint:** `POST /api/auth/change-password`

**Headers:**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Body:**
```json
{
  "current_password": "OldSecurePass123!",
  "new_password": "NewSecurePass123!"
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/auth/change-password \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "current_password": "OldSecurePass123!",
    "new_password": "NewSecurePass123!"
  }'
```

**Response (200):**
```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

---

## Admin User Management

All admin user management endpoints require authentication with a valid JWT token.

### Password Reset Flow (OTP-Based)

The password reset process follows these steps:

1. **Request Reset**: Admin requests password reset using their email
2. **OTP Generation**: System generates a 4-digit OTP and sends it via email
3. **OTP Validation**: Admin enters the OTP along with their new password
4. **Password Update**: System validates OTP and updates the password

**Security Features:**
- OTP expires in 10 minutes
- OTP can only be used once
- Failed login attempts are reset after successful password reset
- Account lockout is cleared after successful password reset
- All password changes are logged for audit purposes

### 1. Get All Admins

Retrieve a list of all admin users.

**Endpoint:** `GET /api/admin/admins`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Curl Example:**
```bash
curl -X GET http://localhost:3001/api/admin/admins \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "admin@orbitnest.io",
    "is_active": true,
    "failed_login_attempts": 0,
    "locked_until": null,
    "created_at": "2025-01-28T10:00:00Z",
    "updated_at": "2025-01-28T10:00:00Z",
    "last_sign_in_at": "2025-01-28T10:00:00Z"
  }
]
```

### 2. Get Admin by ID

Get a specific admin user by ID.

**Endpoint:** `GET /api/admin/admins/{id}`

**Curl Example:**
```bash
curl -X GET http://localhost:3001/api/admin/admins/550e8400-e29b-41d4-a716-446655440000 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 3. Update Admin

Update an admin user's information.

**Endpoint:** `PATCH /api/admin/admins/{id}`

**Curl Example:**
```bash
curl -X PATCH http://localhost:3001/api/admin/admins/550e8400-e29b-41d4-a716-446655440000 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "is_active": false
  }'
```

### 4. Delete Admin

Delete an admin user.

**Endpoint:** `DELETE /api/admin/admins/{id}`

**Curl Example:**
```bash
curl -X DELETE http://localhost:3001/api/admin/admins/550e8400-e29b-41d4-a716-446655440000 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 5. Update Admin Password

Update an admin user's password (admin-only feature).

**Endpoint:** `PATCH /api/admin/admins/{id}/password`

**Headers:**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Body:**
```json
{
  "new_password": "NewSecurePass123!"
}
```

**Curl Example:**
```bash
curl -X PATCH http://localhost:3001/api/admin/admins/550e8400-e29b-41d4-a716-446655440000/password \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "new_password": "NewSecurePass123!"
  }'
```

**Response (200):**
```json
{
  "success": true,
  "message": "Admin password updated successfully"
}
```

---

## API Key Management (Admin)

### 1. Create API Key

Create a new API key for the current admin.

**Endpoint:** `POST /api/admin/api-keys`

**Headers:**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/admin/api-keys \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Development API Key",
    "expires_at": "2025-12-31T23:59:59Z"
  }'
```

**Response (201):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "name": "Development API Key",
  "key": "sk_live_abcd1234567890...",
  "is_active": true,
  "expires_at": "2025-12-31T23:59:59Z",
  "created_at": "2025-01-28T10:00:00Z",
  "last_used_at": null
}
```

### 2. Get API Keys

Get all API keys for the current admin.

**Endpoint:** `GET /api/admin/api-keys`

**Curl Example:**
```bash
curl -X GET http://localhost:3001/api/admin/api-keys \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 3. Delete API Key

Delete an API key.

**Endpoint:** `DELETE /api/admin/api-keys/{keyId}`

**Curl Example:**
```bash
curl -X DELETE http://localhost:3001/api/admin/api-keys/550e8400-e29b-41d4-a716-446655440001 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

---

## Project Management

**🔐 Enhanced Security with Encrypted API Keys**

Starting from v2.0, OrbitNest Studio uses encrypted API keys for enhanced security. API keys are stored encrypted and returned encrypted from GET endpoints. Use the decryption key endpoint to decrypt them on the client side.

### Key Features

- **Default API Keys**: When a project is created, anonymous and service role keys are automatically generated
- **Encrypted Storage**: API keys are stored encrypted in the database using AES-256-CBC
- **Client-Side Decryption**: Keys are returned encrypted and must be decrypted on the client
- **One-Time Plaintext**: Keys are shown in plaintext only once during project creation
- **Secure Key Management**: Separate decryption key endpoint provides client-side decryption capability

### 1. Create Project

Create a new project with default API keys automatically generated.

**Endpoint:** `POST /api/projects`

**Headers:**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Body:**
```json
{
  "name": "My Awesome Project",
  "settings": {
    "theme": "dark",
    "notifications": true
  }
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3002/api/projects \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Awesome Project",
    "settings": {"theme": "dark"}
  }'
```

**Response (201):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "My Awesome Project",
  "slug": "my_awesome_project",
  "db_name": "orbitnest_project_my_awesome_project",
  "project_url": "http://localhost:3002/api/project/my_awesome_project",
  "created_by": "admin-user-uuid",
  "settings": {
    "theme": "dark",
    "notifications": true
  },
  "created_at": "2025-01-28T10:00:00Z",
  "updated_at": "2025-01-28T10:00:00Z",
  "anon_key": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "service_role_key": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "usage_instructions": {
    "anon_key_usage": "Use for client-side apps with limited permissions",
    "service_role_key_usage": "Use for backend apps with full admin access",
    "security_note": "Keys shown in plaintext only during creation. Store securely.",
    "next_steps": [
      "Test authentication: curl -H 'Authorization: Bearer {anon_key}' http://localhost:3002/api/project/my_awesome_project/test-auth",
      "Get project info: curl -H 'Authorization: Bearer {anon_key}' http://localhost:3002/api/project/my_awesome_project/info"
    ]
  }
}
```

**⚠️ Important**: API keys are shown in plaintext only once during project creation. After this, they will be returned encrypted and you'll need to use the decryption key to decrypt them.

### 2. Get Decryption Key

Get the decryption key needed to decrypt encrypted API keys on the client side.

**Endpoint:** `GET /api/projects/decryption-key`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Curl Example:**
```bash
curl -X GET http://localhost:3002/api/projects/decryption-key \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "decryption_key": "ee6e747f22249d5c007eaa95179ea884ce642ccc8de79aa98f038fb74cf9c5fb",
  "algorithm": "aes-256-cbc",
  "key_length": 32,
  "usage_instructions": {
    "note": "Use this key to decrypt encrypted API keys on the client side",
    "security_note": "Store this key securely in your application environment",
    "examples": "See decryption examples below for Node.js and browser implementations"
  }
}
```

### 3. Get Project API Keys (Encrypted)

Retrieve encrypted API keys for a project. Keys are returned encrypted for security.

**Endpoint:** `GET /api/projects/{id}/api-keys`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Curl Example:**
```bash
curl -X GET http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440000/api-keys \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "anon_key": {
    "id": "550e8400-e29b-41d4-a716-446655440001",
    "name": "Default Anonymous Key",
    "key_type": "anon",
    "encrypted_key": "a1b2c3d4e5f6789:7g8h9i0j1k2l3m4n5o6p1q2r3s4t5u6v7w8x9y0z",
    "created_at": "2025-01-28T10:00:00Z"
  },
  "service_role_key": {
    "id": "550e8400-e29b-41d4-a716-446655440002", 
    "name": "Default Service Role Key",
    "key_type": "service_role",
    "encrypted_key": "x1y2z3a4b5c6789:d7e8f9g0h1i2j3k4l5m6n7o8p9q0r1s2t3u4v5w6",
    "created_at": "2025-01-28T10:00:00Z"
  },
  "project_url": "http://localhost:3002/api/project/my_awesome_project",
  "encryption_info": {
    "algorithm": "aes-256-cbc",
    "format": "iv:encrypted_data (both in hex format)",
    "note": "Keys are encrypted. Use decryption key to decrypt on client side."
  }
}
```

### 4. Client-Side Decryption Examples

**Node.js Decryption:**
```javascript
const crypto = require('crypto');

function decryptApiKey(encryptedData, decryptionKey) {
  try {
    const parts = encryptedData.split(':');
    if (parts.length !== 2) {
      throw new Error('Invalid encrypted data format');
    }
    
    const iv = Buffer.from(parts[0], 'hex');
    const encrypted = parts[1];
    const decipher = crypto.createDecipheriv('aes-256-cbc', Buffer.from(decryptionKey, 'hex'), iv);
    
    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  } catch (error) {
    console.error('Decryption failed:', error.message);
    throw error;
  }
}

// Usage Example
async function getAndDecryptApiKeys() {
  // 1. Get decryption key
  const decryptionResponse = await fetch('http://localhost:3002/api/projects/decryption-key', {
    headers: { 'Authorization': 'Bearer your-admin-token' }
  });
  const { decryption_key } = await decryptionResponse.json();
  
  // 2. Get encrypted API keys
  const keysResponse = await fetch('http://localhost:3002/api/projects/your-project-id/api-keys', {
    headers: { 'Authorization': 'Bearer your-admin-token' }
  });
  const { anon_key, service_role_key } = await keysResponse.json();
  
  // 3. Decrypt keys
  const decryptedAnonKey = decryptApiKey(anon_key.encrypted_key, decryption_key);
  const decryptedServiceKey = decryptApiKey(service_role_key.encrypted_key, decryption_key);
  
  return {
    anon_key: decryptedAnonKey,
    service_role_key: decryptedServiceKey
  };
}
```

**Browser/React Decryption (using crypto-js):**

First install crypto-js:
```bash
npm install crypto-js
```

```javascript
import CryptoJS from 'crypto-js';

function decryptApiKey(encryptedData, decryptionKey) {
  try {
    const parts = encryptedData.split(':');
    if (parts.length !== 2) {
      throw new Error('Invalid encrypted data format');
    }
    
    const iv = CryptoJS.enc.Hex.parse(parts[0]);
    const encrypted = parts[1];
    const keyBuffer = CryptoJS.enc.Hex.parse(decryptionKey);
    
    const decrypted = CryptoJS.AES.decrypt(
      { ciphertext: CryptoJS.enc.Hex.parse(encrypted) },
      keyBuffer,
      { 
        iv: iv, 
        mode: CryptoJS.mode.CBC, 
        padding: CryptoJS.pad.Pkcs7 
      }
    );
    
    return decrypted.toString(CryptoJS.enc.Utf8);
  } catch (error) {
    console.error('Decryption failed:', error.message);
    throw error;
  }
}

// React Hook Example
import { useState, useEffect } from 'react';

export function useDecryptedApiKeys(projectId, adminToken) {
  const [keys, setKeys] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    async function fetchAndDecryptKeys() {
      try {
        // Get decryption key
        const decryptionResponse = await fetch('/api/projects/decryption-key', {
          headers: { 'Authorization': `Bearer ${adminToken}` }
        });
        const { decryption_key } = await decryptionResponse.json();
        
        // Get encrypted API keys
        const keysResponse = await fetch(`/api/projects/${projectId}/api-keys`, {
          headers: { 'Authorization': `Bearer ${adminToken}` }
        });
        const { anon_key, service_role_key } = await keysResponse.json();
        
        // Decrypt keys
        const decryptedKeys = {
          anon_key: decryptApiKey(anon_key.encrypted_key, decryption_key),
          service_role_key: decryptApiKey(service_role_key.encrypted_key, decryption_key)
        };
        
        setKeys(decryptedKeys);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    }

    if (projectId && adminToken) {
      fetchAndDecryptKeys();
    }
  }, [projectId, adminToken]);

  return { keys, loading, error };
}
```

### 5. Complete Workflow

**Security-First API Key Management:**

1. **Create Project** → Get plaintext keys initially (one-time only)
2. **Store Keys Securely** → Save them in your environment/database
3. **Get Decryption Key** → Fetch once and store securely in your app
4. **Get Encrypted Keys** → When you need to retrieve stored keys later
5. **Decrypt on Client** → Use decryption key to get plaintext keys
6. **Use Keys** → Make authenticated API calls to your project

**Best Practices:**
- Store the decryption key securely in your environment variables
- Never log or expose decrypted API keys in client-side code
- Cache decrypted keys temporarily in memory, don't persist them
- Rotate API keys periodically by creating new ones

### 6. Environment Configuration

Add to your `.env` file:

```env
# Required: JWT secret for token signing
JWT_SECRET=your-super-secure-jwt-secret-here

# Optional: Custom encryption key (64 hex characters)
# If not provided, derived from JWT_SECRET
ENCRYPTION_KEY=ee6e747f22249d5c007eaa95179ea884ce642ccc8de79aa98f038fb74cf9c5fb

# API Configuration
API_BASE_URL=http://localhost:3002
PORT=3002

# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/orbitnest_studio
```

**Environment Variable Notes:**
- `JWT_SECRET`: Required for all token operations
- `ENCRYPTION_KEY`: Optional 64-character hex string for API key encryption
- If `ENCRYPTION_KEY` is not provided, it will be derived from `JWT_SECRET`
- Use `openssl rand -hex 32` to generate a secure encryption key

### 7. Get All Projects

Retrieve a list of all projects for the authenticated admin user.

**Endpoint:** `GET /api/projects`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Curl Example:**
```bash
curl -X GET http://localhost:3002/api/projects \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440002",
    "name": "My Awesome Project",
    "slug": "my_awesome_project",
    "db_name": "orbitnest_project_my_awesome_project",
    "project_url": "http://localhost:3002/api/project/my_awesome_project",
    "created_by": "550e8400-e29b-41d4-a716-446655440000",
    "settings": {
      "theme": "dark",
      "notifications": true
    },
    "created_at": "2025-01-28T10:00:00Z",
    "updated_at": "2025-01-28T10:00:00Z"
  }
]
```

### 8. Get Project by ID

Get a specific project by its ID.

**Endpoint:** `GET /api/projects/{id}`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Curl Example:**
```bash
curl -X GET http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440002",
  "name": "My Awesome Project",
  "slug": "my_awesome_project",
  "db_name": "orbitnest_project_my_awesome_project",
  "project_url": "http://localhost:3002/api/project/my_awesome_project",
  "created_by": "550e8400-e29b-41d4-a716-446655440000",
  "settings": {
    "theme": "dark",
    "notifications": true
  },
  "created_at": "2025-01-28T10:00:00Z",
  "updated_at": "2025-01-28T10:00:00Z"
}
```

### 9. Update Project

Update a project's information.

**Endpoint:** `PATCH /api/projects/{id}`

**Headers:**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Body:**
```json
{
  "name": "Updated Project Name",
  "settings": {
    "theme": "light",
    "notifications": false
  }
}
```

**Curl Example:**
```bash
curl -X PATCH http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Project Name",
    "settings": {
      "theme": "light",
      "notifications": false
    }
  }'
```

### 10. Delete Project

Delete a project and perform complete cleanup including database, API keys, and edge functions.

**Endpoint:** `DELETE /api/projects/{id}`

**Headers:**
```
Authorization: Bearer {access_token}
```

**Curl Example:**
```bash
curl -X DELETE http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "message": "Project deleted successfully",
  "cleanup_performed": [
    "Project database dropped",
    "API keys revoked",
    "Edge functions removed",
    "Project record deleted"
  ]
}
```

### 11. Create New Project API Keys

Create new API keys for a project. This will replace any existing API keys.

**Endpoint:** `POST /api/projects/{id}/api-keys`

**Headers:**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Body:**
```json
{
  "name": "New Project API Keys"
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002/api-keys \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "New Project API Keys"
  }'
```

**Response (201):**
```json
{
  "anon_key": {
    "id": "anon-key-uuid",
    "name": "New Project API Keys (Anonymous)",
    "key_type": "anon",
    "key": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "created_at": "2025-01-28T10:30:00Z"
  },
  "service_role_key": {
    "id": "service-key-uuid", 
    "name": "New Project API Keys (Service Role)",
    "key_type": "service_role",
    "key": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "created_at": "2025-01-28T10:30:00Z"
  },
  "project_url": "http://localhost:3002/api/project/my_awesome_project",
  "usage_examples": {
    "client_side": "curl -X GET 'http://localhost:3002/api/project/my_awesome_project/test-auth' -H 'Authorization: Bearer {anon_key}'",
    "server_side": "curl -X GET 'http://localhost:3002/api/project/my_awesome_project/test-auth' -H 'Authorization: Bearer {service_role_key}'"
  }
}
```

**⚠️ Important**: New API keys are shown in plaintext only once during creation. After this, use the encrypted endpoint to retrieve them.

### 12. Project Health Check

Check the health status of a project and its database connectivity.

**Endpoint:** `GET /api/project/{slug}/health`

**Curl Example:**
```bash
curl -X GET http://localhost:3002/api/project/my_awesome_project/health
```

**Response (200):**
```json
{
  "status": "healthy",
  "project_id": "550e8400-e29b-41d4-a716-446655440002",
  "database_status": "connected",
  "timestamp": "2025-01-28T10:00:00Z"
}
```

---

## Project API Key Authentication

OrbitNest Studio uses a dual API key system where **each project has exactly one anon key and one service role key at any time**. This approach provides secure, project-isolated access for both client-side and server-side applications.

### ⚠️ Important: Key Pair Replacement

**Key Replacement Behavior:**
- Each project can have only **one anon key and one service role key**
- Creating new API keys **automatically deletes** both existing keys
- Both new keys are created simultaneously and become active immediately
- This ensures security and prevents confusion with multiple key versions

### API Key Management

Each project has **exactly two API keys** at any given time: one anon key and one service role key. When you create new API keys, both existing keys are automatically replaced with new ones.

### API Key Types

All projects get both types of API keys simultaneously:

1. **Anonymous Key (`anon`)**: Limited permissions for client-side usage
   - Read access to public data
   - Insert access to allowed tables
   - Cannot bypass Row Level Security (RLS)
   - Safe for use in browsers and mobile apps
   - Ideal for frontend applications
   
2. **Service Role Key (`service_role`)**: Full permissions for server-side usage
   - Full CRUD operations
   - Admin access to project resources
   - Can bypass Row Level Security (RLS)
   - Database management operations
   - Only for secure server environments
   - Ideal for backend services and admin operations

**Key Pair Replacement:** Both keys are created and replaced together as a pair. You cannot create or replace individual keys - it's always both at once.

### API Key Format

API keys are JWT tokens containing different roles:

**Anonymous Key Format:**
```json
{
  "role": "anon",
  "project_slug": "your_project_slug",
  "iat": 1640995200,
  "exp": 1672531200
}
```

**Service Role Key Format:**
```json
{
  "role": "service_role",
  "project_slug": "your_project_slug",
  "iat": 1640995200,
  "exp": 1672531200
}
```

### Authentication Headers

All project API requests require the `Authorization` header with either key:

**For Client-Side Applications:**
```
Authorization: Bearer {your_anon_key}
```

**For Server-Side Applications:**
```
Authorization: Bearer {your_service_role_key}
```

### How to Access Your Project

When you create API keys, the response includes everything you need to connect to your project immediately.

#### What You Get:
- **anon_key**: Your client-side authentication token
- **service_role_key**: Your server-side authentication token  
- **project_url**: Ready-to-use base URL for your project
- **usage_examples**: Copy-paste commands to test both keys

#### Quick Start Example
```bash
# 1. Create a project (using admin token)
PROJECT_RESPONSE=$(curl -X POST "http://localhost:3001/api/projects" \
  -H "Authorization: Bearer {admin_token}" \
  -H "Content-Type: application/json" \
  -d '{"name": "My Project", "description": "Test project"}')

# 2. Extract project ID
PROJECT_ID=$(echo $PROJECT_RESPONSE | jq -r '.id')

# 3. Create API keys - response includes both keys and URL!
API_RESPONSE=$(curl -X POST "http://localhost:3001/api/projects/${PROJECT_ID}/api-keys" \
  -H "Authorization: Bearer {admin_token}" \
  -H "Content-Type: application/json" \
  -d '{"name": "Main Keys"}')

# Response provides everything you need:
# {
#   "anon_key": { "key": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." },
#   "service_role_key": { "key": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." },
#   "project_url": "http://localhost:3001/api/project/my_project_123",
#   "usage_examples": { ... }
# }

# 4. Extract the values
ANON_KEY=$(echo $API_RESPONSE | jq -r '.anon_key.key')
SERVICE_KEY=$(echo $API_RESPONSE | jq -r '.service_role_key.key')
PROJECT_URL=$(echo $API_RESPONSE | jq -r '.project_url')

# 5. Test your connections
# Client-side test (anon key)
curl -X GET "${PROJECT_URL}/test-auth" \
  -H "Authorization: Bearer ${ANON_KEY}"

# Server-side test (service role key)  
curl -X GET "${PROJECT_URL}/test-auth" \
  -H "Authorization: Bearer ${SERVICE_KEY}"
```

#### Manual Connection
If you already have your keys and project URL:

**Client-Side (Frontend/Mobile):**
```bash
curl -X GET "http://localhost:3001/api/project/your_project_slug/test-auth" \
  -H "Authorization: Bearer your_anon_key"
```

**Server-Side (Backend/Admin):**
```bash
curl -X GET "http://localhost:3001/api/project/your_project_slug/test-auth" \
  -H "Authorization: Bearer your_service_role_key"
```

### Project-Scoped Endpoints

These endpoints require project API key authentication and are scoped to a specific project:

#### 1. Test Authentication

Test if your API keys are working correctly. Works with both anon and service role keys.

**Endpoint:** `GET /api/project/{project_slug}/test-auth`

**Headers:**
```
Authorization: Bearer {anon_key_or_service_role_key}
```

**Curl Examples:**

**With Anon Key (Client-Side):**
```bash
curl -X GET http://localhost:3001/api/project/my_awesome_project/test-auth \
  -H "Authorization: Bearer {your_anon_key}"
```

**With Service Role Key (Server-Side):**
```bash
curl -X GET http://localhost:3001/api/project/my_awesome_project/test-auth \
  -H "Authorization: Bearer {your_service_role_key}"
```

**Response (200) - Anon Key:**
```json
{
  "message": "Authentication successful",
  "authenticated_as": "anon",
  "project": "my_awesome_project",
  "timestamp": "2025-01-28T10:00:00Z"
}
```

**Response (200) - Service Role Key:**
```json
{
  "message": "Authentication successful", 
  "authenticated_as": "service_role",
  "project": "my_awesome_project",
  "timestamp": "2025-01-28T10:00:00Z"
}
```

#### 2. Get Project Information

Get detailed information about the current project.

**Endpoint:** `GET /api/project/{project_slug}/info`

**Headers:**
```
Authorization: Bearer {anon_key_or_service_role_key}
```

**Curl Example:**
```bash
curl -X GET http://localhost:3001/api/project/my_awesome_project/info \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200) - Anonymous Key:**
```json
{
  "project": {
    "slug": "my_awesome_project",
    "role": "anon"
  },
  "permissions": {
    "read": true,
    "insert": true,
    "update": false,
    "delete": false
  },
  "authenticated_as": "anon"
}
```

**Response (200) - Service Role Key:**
```json
{
  "project": {
    "slug": "my_awesome_project",
    "role": "service_role"
  },
  "permissions": {
    "read": true,
    "insert": true,
    "update": true,
    "delete": true,
    "admin": true,
    "bypass_rls": true
  },
  "has_db_access": true,
  "authenticated_as": "service_role"
}
```

#### 3. Project Health Check

Check if the project and its database are accessible.

**Endpoint:** `GET /api/project/{project_slug}/health` 

**Headers:**
```
Authorization: Bearer {anon_key_or_service_role_key}
```

**Curl Example:**
```bash
curl -X GET http://localhost:3001/api/project/my_awesome_project/health \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "status": "healthy",
  "project": "my_awesome_project",
  "database": "connected",
  "timestamp": "2025-01-28T10:00:00Z"
}
```

### Usage Examples

#### Frontend Integration (Anonymous Key)

```javascript
// Initialize your client with anonymous key
const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
const projectUrl = 'http://localhost:3001/api/project/my_awesome_project';

// Make authenticated requests
const response = await fetch(`${projectUrl}/info`, {
  headers: {
    'Authorization': `Bearer ${anonKey}`,
    'Content-Type': 'application/json'
  }
});
```

#### Backend Integration (Service Role Key)

```javascript
// Use service role key for server-side operations
const serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
const projectUrl = 'http://localhost:3001/api/project/my_awesome_project';

// Make admin requests
const response = await fetch(`${projectUrl}/info`, {
  headers: {
    'Authorization': `Bearer ${serviceRoleKey}`,
    'Content-Type': 'application/json'
  }
});
```

### Error Responses

Common error responses for API key authentication:

**401 Unauthorized - Missing API Key:**
```json
{
  "message": "API key is required",
  "error": "Unauthorized",
  "statusCode": 401
}
```

**401 Unauthorized - Invalid API Key:**
```json
{
  "message": "Invalid API key",
  "error": "Unauthorized", 
  "statusCode": 401
}
```

**403 Forbidden - Wrong Project:**
```json
{
  "message": "API key does not belong to this project",
  "error": "Forbidden",
  "statusCode": 403
}
```

**401 Unauthorized - Revoked Key:**
```json
{
  "message": "API key has been revoked or is invalid",
  "error": "Unauthorized",
  "statusCode": 401
}
```

### Integration Patterns

#### React/Next.js Integration

```javascript
// utils/orbitnest.js
const PROJECT_URL = 'http://localhost:3001/api/project/my_awesome_project';
const ANON_KEY = 'your_anon_key_here';
const SERVICE_ROLE_KEY = 'your_service_role_key_here'; // Server-side only!

export const orbitNestClient = {
  // Client-side methods (use anon key)
  async testAuth() {
    return fetch(`${PROJECT_URL}/test-auth`, {
      headers: { 'Authorization': `Bearer ${ANON_KEY}` }
    }).then(res => res.json());
  },
  
  async getProjectInfo() {
    return fetch(`${PROJECT_URL}/info`, {
      headers: { 'Authorization': `Bearer ${ANON_KEY}` }
    }).then(res => res.json());
  }
};

// Server-side methods (Next.js API routes - use service role key)
export const adminClient = {
  async getProjectInfoAdmin() {
    return fetch(`${PROJECT_URL}/info`, {
      headers: { 'Authorization': `Bearer ${SERVICE_ROLE_KEY}` }
    }).then(res => res.json());
  }
};
```

#### Vue.js Integration

```javascript
// plugins/orbitnest.js
import { ref } from 'vue'

const projectUrl = 'http://localhost:3001/api/project/my_awesome_project'
const anonKey = 'your_anon_key_here'

export const useOrbitNest = () => {
  const isAuthenticated = ref(false)
  const projectInfo = ref(null)
  
  const testConnection = async () => {
    try {
      const response = await fetch(`${projectUrl}/test-auth`, {
        headers: { 'Authorization': `Bearer ${anonKey}` }
      })
      const data = await response.json()
      isAuthenticated.value = response.ok
      return data
    } catch (error) {
      isAuthenticated.value = false
      throw error
    }
  }
  
  const getProjectInfo = async () => {
    const response = await fetch(`${projectUrl}/info`, {
      headers: { 'Authorization': `Bearer ${anonKey}` }
    })
    projectInfo.value = await response.json()
    return projectInfo.value
  }
  
  return {
    isAuthenticated,
    projectInfo,
    testConnection,
    getProjectInfo
  }
}
```

#### Express.js Backend Integration

```javascript
// server.js
const express = require('express');
const app = express();

const PROJECT_URL = 'http://localhost:3001/api/project/my_awesome_project';
const SERVICE_ROLE_KEY = 'your_service_role_key_here';

// Middleware to create OrbitNest client
app.use((req, res, next) => {
  req.orbitNest = {
    async makeRequest(endpoint, options = {}) {
      const response = await fetch(`${PROJECT_URL}${endpoint}`, {
        ...options,
        headers: {
          'Authorization': `Bearer ${SERVICE_ROLE_KEY}`,
          'Content-Type': 'application/json',
          ...options.headers
        }
      });
      return response.json();
    }
  };
  next();
});

// Example route using OrbitNest
app.get('/api/project-status', async (req, res) => {
  try {
    const health = await req.orbitNest.makeRequest('/health');
    const info = await req.orbitNest.makeRequest('/info');
    res.json({ health, info });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

#### Python/FastAPI Integration

```python
# orbitnest_client.py
import httpx
from typing import Optional, Dict, Any

class OrbitNestClient:
    def __init__(self, project_slug: str, api_key: str):
        self.base_url = f"http://localhost:3001/api/project/{project_slug}"
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
        self.client = httpx.AsyncClient()
    
    async def test_auth(self) -> Dict[str, Any]:
        response = await self.client.get(
            f"{self.base_url}/test-auth",
            headers=self.headers
        )
        response.raise_for_status()
        return response.json()
    
    async def get_project_info(self) -> Dict[str, Any]:
        response = await self.client.get(
            f"{self.base_url}/info", 
            headers=self.headers
        )
        response.raise_for_status()
        return response.json()
    
    async def health_check(self) -> Dict[str, Any]:
        response = await self.client.get(
            f"{self.base_url}/health",
            headers=self.headers
        )
        response.raise_for_status()
        return response.json()

# Usage in FastAPI
from fastapi import FastAPI
import os

app = FastAPI()
orbit_client = OrbitNestClient(
    project_slug="my_awesome_project",
    api_key=os.getenv("ORBITNEST_SERVICE_ROLE_KEY")
)

@app.get("/status")
async def get_status():
    return await orbit_client.health_check()
```

#### Environment Variables Setup

Create a `.env` file for your project:

```bash
# .env
ORBITNEST_PROJECT_URL=http://localhost:3001/api/project/my_awesome_project
ORBITNEST_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
ORBITNEST_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Never commit service role keys to version control!
# Add .env to your .gitignore file
```

### Security Notes

- **Anonymous keys** are safe to use in client-side code (browsers, mobile apps)
- **Service role keys** should only be used in secure server environments
- Keys are project-scoped and cannot access other projects
- All API requests are validated against the project's database
- Keys can be revoked through the admin API if compromised

---

## Project Authentication

All project authentication endpoints use the project ID or slug in the URL path.

### Public Authentication Endpoints

#### 1. Start Email-First Registration

Begin the email-first registration flow.

**Endpoint:** `POST /projects/{projectId}/auth/signup-with-email`

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/my_awesome_project/auth/signup-with-email \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com"
  }'
```

**Response (200):**
```json
{
  "success": true,
  "message": "OTP sent to email",
  "email": "user@example.com"
}
```

#### 2. Complete Email-First Registration

Complete registration with OTP and optional password.

**Endpoint:** `POST /projects/{projectId}/auth/verify-signup`

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/my_awesome_project/auth/verify-signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "code": "1234",
    "password": "UserPass123!"
  }'
```

**Response (201):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 900,
  "token_type": "Bearer",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440004",
    "email": "user@example.com",
    "email_confirmed": true,
    "created_at": "2025-01-28T10:00:00Z"
  }
}
```

#### 3. Start Passwordless Sign In

Start passwordless sign-in flow.

**Endpoint:** `POST /projects/{projectId}/auth/signin-with-email`

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/my_awesome_project/auth/signin-with-email \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com"
  }'
```

#### 4. Complete Passwordless Sign In

Complete sign-in with OTP.

**Endpoint:** `POST /projects/{projectId}/auth/verify-signin`

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/my_awesome_project/auth/verify-signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "code": "1234"
  }'
```

#### 5. Traditional Email/Password Registration

Traditional registration with email and password.

**Endpoint:** `POST /projects/{projectId}/auth/signup`

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/my_awesome_project/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "UserPass123!"
  }'
```

#### 6. Traditional Email/Password Sign In

Traditional sign-in with email and password.

**Endpoint:** `POST /projects/{projectId}/auth/signin`

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/my_awesome_project/auth/signin \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "UserPass123!"
  }'
```

#### 7. Send Password Recovery OTP

Send recovery OTP to email.

**Endpoint:** `POST /projects/{projectId}/auth/recover`

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/my_awesome_project/auth/recover \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com"
  }'
```

#### 8. Reset Password with OTP

Reset password using OTP.

**Endpoint:** `POST /projects/{projectId}/auth/reset-password`

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/my_awesome_project/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "code": "1234",
    "password": "NewPassword123!"
  }'
```

#### 9. Refresh Token

Refresh access token.

**Endpoint:** `POST /projects/{projectId}/auth/refresh`

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/my_awesome_project/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }'
```

### Authenticated User Endpoints

#### 10. Get Current User Profile

Get the current user's profile.

**Endpoint:** `GET /projects/{projectId}/auth/user`

**Headers:**
```
Authorization: Bearer {project_access_token}
```

**Curl Example:**
```bash
curl -X GET http://localhost:3001/projects/my_awesome_project/auth/user \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440004",
  "email": "user@example.com",
  "email_confirmed": true,
  "phone": null,
  "phone_confirmed": false,
  "last_sign_in_at": "2025-01-28T10:00:00Z",
  "app_metadata": {},
  "user_metadata": {},
  "created_at": "2025-01-28T10:00:00Z",
  "updated_at": "2025-01-28T10:00:00Z"
}
```

#### 11. Update User Profile

Update the current user's profile.

**Endpoint:** `PUT /projects/{projectId}/auth/user`

**Curl Example:**
```bash
curl -X PUT http://localhost:3001/projects/my_awesome_project/auth/user \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+1234567890",
    "user_metadata": {
      "first_name": "John",
      "last_name": "Doe"
    }
  }'
```

#### 12. Delete User Account

Delete the current user's account.

**Endpoint:** `DELETE /projects/{projectId}/auth/user`

**Curl Example:**
```bash
curl -X DELETE http://localhost:3001/projects/my_awesome_project/auth/user \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### 13. Sign Out

Sign out the current user.

**Endpoint:** `POST /projects/{projectId}/auth/signout`

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/my_awesome_project/auth/signout \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### 14. Sign Out from All Devices

Sign out from all devices.

**Endpoint:** `POST /projects/{projectId}/auth/signout-all`

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/my_awesome_project/auth/signout-all \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Admin Endpoints (Project-Level)

#### 15. List All Users (Admin Only)

List all users in the project.

**Endpoint:** `GET /projects/{projectId}/auth/admin/users`

**Headers:**
```
Authorization: Bearer {service_role_key}
```

**Curl Example:**
```bash
curl -X GET "http://localhost:3001/projects/my_awesome_project/auth/admin/users?page=1&limit=50&search=john" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### 16. Create User (Admin Only)

Create a new user account as admin.

**Endpoint:** `POST /projects/{projectId}/auth/admin/users`

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/my_awesome_project/auth/admin/users \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "TempPass123!",
    "email_confirmed": true,
    "user_metadata": {
      "role": "user"
    }
  }'
```

#### 17. Get Auth Statistics (Admin Only)

Get authentication statistics.

**Endpoint:** `GET /projects/{projectId}/auth/admin/stats`

**Curl Example:**
```bash
curl -X GET http://localhost:3001/projects/my_awesome_project/auth/admin/stats \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### 18. Get Auth Configuration (Admin Only)

Get authentication configuration.

**Endpoint:** `GET /projects/{projectId}/auth/admin/config`

**Curl Example:**
```bash
curl -X GET http://localhost:3001/projects/my_awesome_project/auth/admin/config \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### 19. Update Auth Configuration (Admin Only)

Update authentication configuration.

**Endpoint:** `PUT /projects/{projectId}/auth/admin/config`

**Curl Example:**
```bash
curl -X PUT http://localhost:3001/projects/my_awesome_project/auth/admin/config \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "enable_email_signup": true,
    "enable_phone_signup": false,
    "minimum_password_length": 8,
    "require_email_confirmation": true
  }'
```

---

## Edge Functions

OrbitNest Studio provides a serverless edge function execution environment compatible with Supabase Edge Functions. Functions are executed in isolated JavaScript environments with access to project context and authentication state.

### Function Code Format

Edge functions should use the `export default` function format with ENV() for environment variables:

```javascript
export default async function handler(req, context) {
  // Access environment variables using ENV() function
  const databaseUrl = ENV('DATABASE_URL');
  const apiKey = ENV('API_SECRET_KEY');
  
  // Your function logic here
  return new Response(JSON.stringify({
    message: "Hello World!",
    project: context.project.id,
    method: req.method,
    hasDatabase: !!databaseUrl
  }), {
    status: 200,
    headers: { "Content-Type": "application/json" }
  });
}
```

### Function Management Endpoints (Admin Protected)

#### 1. Create Edge Function

Create a new edge function for a project.

**Endpoint:** `POST /projects/{id}/functions`

**Headers:**
```
Authorization: Bearer {admin_access_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "function-name",
  "description": "Function description",
  "sourceCode": "async function handler(req, context) { ... }",
  "executionConfig": {
    "timeout": 30000,
    "memory": 128,
    "enableLogs": true
  }
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/3ff8390f-f24e-454a-8f84-55ed4f021364/functions \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "sample-json-function",
    "description": "A sample edge function that returns JSON data",
    "sourceCode": "export default async function handler(req, context) {\n  console.log(\"Sample function called\", req.method, req.url);\n  \n  // Access environment variables using ENV() function\n  const dbUrl = ENV(\"DATABASE_URL\");\n  const apiKey = ENV(\"API_KEY\");\n  \n  const responseData = {\n    message: \"Hello from OrbitNest Edge Function!\",\n    project: context.project.id,\n    timestamp: new Date().toISOString(),\n    method: req.method,\n    url: req.url,\n    hasDbUrl: !!dbUrl,\n    headers: req.headers\n  };\n  \n  return new Response(JSON.stringify(responseData), {\n    status: 200,\n    headers: {\n      \"Content-Type\": \"application/json\"\n    }\n  });\n}",
    "executionConfig": {
      "timeout": 30000,
      "memory": 128,
      "enableLogs": true
    }
  }'
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440005",
    "name": "sample-json-function",
    "description": "A sample edge function that returns JSON data",
    "status": "active",
    "createdAt": "2025-01-28T10:00:00Z",
    "updatedAt": "2025-01-28T10:00:00Z"
  }
}
```

#### 2. Get All Functions

Get all edge functions for a project.

**Endpoint:** `GET /projects/{id}/functions`

**Curl Example:**
```bash
curl -X GET http://localhost:3001/projects/550e8400-e29b-41d4-a716-446655440002/functions \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "functions": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440005",
        "name": "hello-world",
        "description": "A simple hello world function",
        "status": "active",
        "createdAt": "2025-01-28T10:00:00Z",
        "updatedAt": "2025-01-28T10:00:00Z"
      }
    ],
    "total": 1
  }
}
```

#### 3. Get Function Details

Get detailed information about a specific function.

**Endpoint:** `GET /projects/{id}/functions/{name}`

**Curl Example:**
```bash
curl -X GET http://localhost:3001/projects/550e8400-e29b-41d4-a716-446655440002/functions/hello-world \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440005",
    "name": "hello-world",
    "description": "A simple hello world function",
    "sourceCode": "export default async function handler(req, context) {\n  return new Response(JSON.stringify({ message: \"Hello World!\" }), {\n    headers: { \"Content-Type\": \"application/json\" },\n    status: 200\n  });\n}",
    "status": "active",
    "environmentVariables": {
      "GREETING": "Hello"
    },
    "executionConfig": {
      "timeout": 30000,
      "memory_limit": 128
    },
    "createdAt": "2025-01-28T10:00:00Z",
    "updatedAt": "2025-01-28T10:00:00Z"
  }
}
```

#### 4. Update Function

Update an existing edge function.

**Endpoint:** `PUT /projects/{id}/functions/{name}`

**Curl Example:**
```bash
curl -X PUT http://localhost:3001/projects/3ff8390f-f24e-454a-8f84-55ed4f021364/functions/sample-json-function \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Updated sample function with user context",
    "sourceCode": "async function handler(req, context) {\n  const { user, project } = context;\n  \n  const responseData = {\n    message: \"Hello from Updated Function!\",\n    project: project.id,\n    user: user?.email || \"anonymous\",\n    timestamp: new Date().toISOString(),\n    method: req.method,\n    version: process.env.VERSION || \"1.0\"\n  };\n  \n  return new Response(JSON.stringify(responseData), {\n    status: 200,\n    headers: { \"Content-Type\": \"application/json\" }\n  });\n}",
    "environmentVariables": {
      "NODE_ENV": "production",
      "VERSION": "2.0"
    }
  }'
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440005",
    "name": "sample-json-function",
    "description": "Updated sample function with user context",
    "status": "active",
    "createdAt": "2025-01-28T10:00:00Z",
    "updatedAt": "2025-01-28T10:15:00Z"
  }
}
```

#### 5. Delete Function

Delete an edge function.

**Endpoint:** `DELETE /projects/{id}/functions/{name}`

**Curl Example:**
```bash
curl -X DELETE http://localhost:3001/projects/550e8400-e29b-41d4-a716-446655440002/functions/hello-world \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### 6. Get Function Logs

Get execution logs for a function.

**Endpoint:** `GET /projects/{id}/functions/{name}/logs`

**Curl Example:**
```bash
curl -X GET "http://localhost:3001/projects/550e8400-e29b-41d4-a716-446655440002/functions/hello-world/logs?limit=100" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "logs": [
      {
        "id": "log-001",
        "executionId": "exec-001",
        "status": "success",
        "durationMs": 45,
        "requestMethod": "POST",
        "responseStatus": 200,
        "errorMessage": null,
        "userId": "550e8400-e29b-41d4-a716-446655440004",
        "createdAt": "2025-01-28T10:00:00Z"
      }
    ],
    "total": 1
  }
}
```

### Function Invocation Endpoints (Public/Authenticated)

These endpoints are Supabase-compatible and can be called from client applications using project slugs.

#### 7. Invoke Function (POST)

Invoke a function via POST request with JSON data.

**Endpoint:** `POST /projects/{slug}/functions/v1/{functionName}`

**Headers:**
```
Authorization: Bearer {anon_key_or_user_token} (optional)
Content-Type: application/json
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/loopwise/functions/v1/sample-json-function \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "action": "create_user"
  }'
```

**Response (200):**
```json
{
  "message": "Hello from OrbitNest Edge Function!",
  "project": "3ff8390f-f24e-454a-8f84-55ed4f021364",
  "timestamp": "2025-01-28T10:30:00.000Z",
  "method": "POST",
  "url": "/projects/loopwise/functions/v1/sample-json-function",
  "headers": {
    "content-type": "application/json",
    "host": "localhost:3001"
  }
}
```

#### 8. Invoke Function (GET)

Invoke a function via GET request with query parameters.

**Endpoint:** `GET /projects/{slug}/functions/v1/{functionName}`

**Curl Example:**
```bash
curl -X GET "http://localhost:3001/projects/loopwise/functions/v1/sample-json-function?name=John&action=get_user"
```

**Response (200):**
```json
{
  "message": "Hello from OrbitNest Edge Function!",
  "project": "3ff8390f-f24e-454a-8f84-55ed4f021364",
  "timestamp": "2025-01-28T10:30:00.000Z",
  "method": "GET",
  "url": "/projects/loopwise/functions/v1/sample-json-function?name=John&action=get_user"
}
```

#### 9. Invoke Function (PUT)

Invoke a function via PUT request for updates.

**Endpoint:** `PUT /projects/{slug}/functions/v1/{functionName}`

**Curl Example:**
```bash
curl -X PUT http://localhost:3001/projects/loopwise/functions/v1/sample-json-function \
  -H "Content-Type: application/json" \
  -d '{
    "id": "123",
    "action": "update_user",
    "data": {"name": "Jane Doe", "email": "jane@example.com"}
  }'
```

#### 10. Invoke Function (DELETE)

Invoke a function via DELETE request.

**Endpoint:** `DELETE /projects/{slug}/functions/v1/{functionName}`

**Curl Example:**
```bash
curl -X DELETE "http://localhost:3001/projects/loopwise/functions/v1/sample-json-function?id=123&action=delete_user"
```

### JavaScript Integration Example

Here's how to integrate edge function calls in your frontend JavaScript:

```javascript
// Edge Function Client
class EdgeFunctionClient {
  constructor(projectSlug, baseUrl = 'http://localhost:3001') {
    this.projectSlug = projectSlug;
    this.baseUrl = baseUrl;
    this.apiUrl = `${baseUrl}/projects/${projectSlug}/functions/v1`;
  }

  async invoke(functionName, options = {}) {
    const {
      method = 'POST',
      body = null,
      headers = {},
      token = null
    } = options;

    const requestHeaders = {
      'Content-Type': 'application/json',
      ...headers
    };

    if (token) {
      requestHeaders['Authorization'] = `Bearer ${token}`;
    }

    const config = {
      method,
      headers: requestHeaders
    };

    if (body && (method === 'POST' || method === 'PUT')) {
      config.body = JSON.stringify(body);
    }

    const response = await fetch(`${this.apiUrl}/${functionName}`, config);
    
    if (!response.ok) {
      throw new Error(`Function invocation failed: ${response.statusText}`);
    }

    return response.json();
  }
}

// Usage examples
const client = new EdgeFunctionClient('loopwise');

// POST request
const createResult = await client.invoke('sample-json-function', {
  method: 'POST',
  body: { name: 'John Doe', action: 'create_user' }
});

// GET request
const getResult = await client.invoke('sample-json-function', {
  method: 'GET'
});

// With authentication
const authResult = await client.invoke('sample-json-function', {
  method: 'POST',
  body: { action: 'protected_action' },
  token: 'your-jwt-token'
});
```

### Error Handling

Edge functions return standard HTTP status codes:

- **200**: Success
- **400**: Bad Request (invalid function parameters)
- **401**: Unauthorized (invalid or missing authentication)
- **404**: Function not found
- **500**: Internal server error (function execution failed)

**Error Response Format:**
```json
{
  "error": "Function execution failed: ReferenceError: undefined variable",
  "timestamp": "2025-01-28T10:30:00.000Z"
}
```

---

## Environment Variables

The Environment Variables API allows you to securely manage encrypted environment variables that can be accessed by all edge functions within a project. Environment variables are encrypted at rest and only decrypted during function execution.

### Security Features

- **Encrypted Storage**: All environment variable values are encrypted using AES-256-CBC encryption
- **Runtime Decryption**: Values are only decrypted when edge functions execute
- **Secret Masking**: Secret variables are masked in API responses and dashboard
- **Global Access**: All functions in a project can access the same environment variables
- **Secure Transmission**: All API endpoints require admin authentication

### Accessing Environment Variables in Functions

Use the `ENV()` function to access environment variables in your edge functions:

```javascript
export default async function handler(req, context) {
  // Access environment variables using ENV() function
  const databaseUrl = ENV('DATABASE_URL');
  const apiKey = ENV('API_SECRET_KEY');
  const debugMode = ENV('DEBUG_MODE');
  
  // Environment variables return null if not found
  if (!databaseUrl) {
    return new Response(JSON.stringify({ error: 'Database URL not configured' }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
  
  return new Response(JSON.stringify({ 
    message: 'Environment variables loaded',
    debug: debugMode === 'true'
  }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  });
}
```

### Environment Variable Management Endpoints (Admin Protected)

#### 1. Create Environment Variable

Create a new environment variable for a project.

**Endpoint:** `POST /projects/{id}/environment-variables`

**Headers:**
```
Authorization: Bearer {admin_access_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "DATABASE_URL",
  "value": "postgresql://user:pass@localhost:5432/mydb",
  "description": "Main database connection URL",
  "is_secret": true
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/3ff8390f-f24e-454a-8f84-55ed4f021364/environment-variables \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "API_SECRET_KEY",
    "value": "sk-1234567890abcdef",
    "description": "Secret API key for external service",
    "is_secret": true
  }'
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "API_SECRET_KEY",
    "value": "***HIDDEN***",
    "description": "Secret API key for external service",
    "is_secret": true,
    "created_at": "2025-01-28T10:00:00Z",
    "updated_at": "2025-01-28T10:00:00Z"
  },
  "message": "Environment variable created successfully"
}
```

#### 2. Bulk Create Environment Variables

Create multiple environment variables at once.

**Endpoint:** `POST /projects/{id}/environment-variables/bulk`

**Request Body:**
```json
{
  "variables": {
    "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb",
    "REDIS_URL": "redis://localhost:6379",
    "API_KEY": "sk-1234567890abcdef",
    "DEBUG_MODE": "true"
  },
  "all_secrets": false
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/projects/3ff8390f-f24e-454a-8f84-55ed4f021364/environment-variables/bulk \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "variables": {
      "DATABASE_URL": "postgresql://user:pass@localhost:5432/mydb",
      "REDIS_URL": "redis://localhost:6379/0",
      "DEBUG_MODE": "development"
    },
    "all_secrets": true
  }'
```

**Response (201):**
```json
{
  "success": true,
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "name": "DATABASE_URL",
      "value": "***HIDDEN***",
      "is_secret": true,
      "created_at": "2025-01-28T10:00:00Z",
      "updated_at": "2025-01-28T10:00:00Z"
    }
  ],
  "total": 3,
  "message": "3 environment variables created successfully"
}
```

#### 3. List Environment Variables

Get all environment variables for a project (values masked for secrets).

**Endpoint:** `GET /projects/{id}/environment-variables`

**Curl Example:**
```bash
curl -X GET http://localhost:3001/projects/3ff8390f-f24e-454a-8f84-55ed4f021364/environment-variables \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "DATABASE_URL",
      "value": "***HIDDEN***",
      "description": "Main database connection URL",
      "is_secret": true,
      "created_at": "2025-01-28T10:00:00Z",
      "updated_at": "2025-01-28T10:00:00Z"
    },
    {
      "id": "550e8400-e29b-41d4-a716-446655440001",
      "name": "DEBUG_MODE",
      "value": "***ENCRYPTED***",
      "description": null,
      "is_secret": false,
      "created_at": "2025-01-28T10:00:00Z",
      "updated_at": "2025-01-28T10:00:00Z"
    }
  ],
  "total": 2
}
```

#### 4. Get Environment Variable

Get a specific environment variable by name.

**Endpoint:** `GET /projects/{id}/environment-variables/{name}`

**Curl Example:**
```bash
curl -X GET http://localhost:3001/projects/3ff8390f-f24e-454a-8f84-55ed4f021364/environment-variables/DATABASE_URL \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "DATABASE_URL",
    "value": "***HIDDEN***",
    "description": "Main database connection URL",
    "is_secret": true,
    "created_at": "2025-01-28T10:00:00Z",
    "updated_at": "2025-01-28T10:00:00Z"
  },
  "message": "Environment variable retrieved successfully"
}
```

#### 5. Update Environment Variable

Update an existing environment variable.

**Endpoint:** `PUT /projects/{id}/environment-variables/{name}`

**Request Body:**
```json
{
  "value": "postgresql://newuser:newpass@localhost:5432/newdb",
  "description": "Updated database connection URL",
  "is_secret": true
}
```

**Curl Example:**
```bash
curl -X PUT http://localhost:3001/projects/3ff8390f-f24e-454a-8f84-55ed4f021364/environment-variables/DATABASE_URL \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "value": "postgresql://newuser:newpass@localhost:5432/newdb",
    "description": "Updated database connection URL"
  }'
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "DATABASE_URL",
    "value": "***HIDDEN***",
    "description": "Updated database connection URL",
    "is_secret": true,
    "created_at": "2025-01-28T10:00:00Z",
    "updated_at": "2025-01-28T10:01:00Z"
  },
  "message": "Environment variable updated successfully"
}
```

#### 6. Delete Environment Variable

Delete an environment variable.

**Endpoint:** `DELETE /projects/{id}/environment-variables/{name}`

**Curl Example:**
```bash
curl -X DELETE http://localhost:3001/projects/3ff8390f-f24e-454a-8f84-55ed4f021364/environment-variables/DATABASE_URL \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "message": "Environment variable deleted successfully"
}
```

### Environment Variable Error Responses

#### Variable Already Exists (409)
```json
{
  "success": false,
  "error": "Environment variable 'DATABASE_URL' already exists"
}
```

#### Variable Not Found (404)
```json
{
  "success": false,
  "error": "Environment variable 'MISSING_VAR' not found"
}
```

#### Variable Limit Exceeded (400)
```json
{
  "success": false,
  "error": "Maximum of 100 environment variables per project exceeded"
}
```

#### Invalid Variable Name (400)
```json
{
  "success": false,
  "error": "Variable name must contain only uppercase letters, numbers, and underscores"
}
```

---

## Database Operations

OrbitNest Studio provides comprehensive database management capabilities for project databases. This includes SQL execution, table operations, row CRUD operations, bulk operations, and Row Level Security (RLS) management.

### 🔒 Security Model

**Project Isolation:**
- Each project operates in its own isolated PostgreSQL database
- Projects cannot access data from other projects
- Admin database is completely separate and protected

**Authentication Table Protection:**
- All auth tables (`auth_users`, `auth_sessions`, `auth_refresh_tokens`, etc.) have Row-Level Security (RLS) enabled by default
- Auth tables cannot be deleted or have RLS disabled
- Default security policies ensure users can only access their own data
- Service role has controlled access for management operations
- Direct SQL access to auth tables is restricted - use authentication APIs instead

**SQL Security:**
- SQL injection prevention through query validation and sanitization
- Admin table protection (blocks access to `admin_users`, `admin_api_keys`, etc.)
- System-level operation protection (prevents database/user creation, file access)
- Auth table deletion and RLS bypass protection
- Legitimate project operations fully supported (extensions, schemas, RLS on user tables, etc.)

**Allowed Operations:**
- ✅ `CREATE EXTENSION` - PostgreSQL extensions like uuid-ossp
- ✅ `CREATE SCHEMA` - Custom schemas within project database  
- ✅ `CREATE/ALTER/DROP TABLE` - Full table management (except auth tables)
- ✅ `CREATE TYPE` - Custom data types and ENUMs
- ✅ `CREATE FUNCTION/TRIGGER` - Stored procedures and triggers
- ✅ `GRANT/REVOKE` - Permission management within project
- ✅ `CREATE/DROP POLICY` - RLS policy management (user tables only)
- ✅ `ALTER TABLE ... ENABLE/DISABLE ROW LEVEL SECURITY` - RLS control (user tables only)

**Restricted Operations:**
- ❌ `DROP TABLE auth_*` - Authentication tables cannot be deleted
- ❌ `ALTER TABLE auth_* DISABLE ROW LEVEL SECURITY` - Auth table RLS cannot be disabled
- ❌ `DROP POLICY ... ON auth_*` - Auth table policies cannot be deleted
- ❌ `CREATE POLICY ... ON auth_*` - Additional auth table policies cannot be created
- ❌ Direct data manipulation on auth tables (use authentication APIs)
- ❌ System database access or modifications
- ❌ User/role management operations
- ❌ File system operations
- ✅ `CREATE POLICY` - Row Level Security policies
- ✅ `VACUUM/ANALYZE` - Database maintenance
- ✅ Information schema queries for metadata

**Blocked Operations:**
- ❌ `CREATE/DROP DATABASE` - Database-level operations
- ❌ `CREATE/DROP USER` - Server-level user management
- ❌ `COPY FROM/TO` - File system access
- ❌ Access to admin tables (`admin_users`, `admin_api_keys`)
- ❌ Access to sensitive system catalogs (`pg_authid`, `pg_user`)

### 1. Execute SQL Query

Execute custom SQL queries within a project database with full PostgreSQL feature support.

**Endpoint:** `POST /api/projects/{projectId}/database/sql`

**Headers:**
```
Authorization: Bearer {admin_access_token}
Content-Type: application/json
```

**Body:**
```json
{
  "sql": "CREATE TABLE customers (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), name TEXT NOT NULL, email TEXT UNIQUE NOT NULL);"
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002/database/sql \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "sql": "CREATE TABLE customers (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), name TEXT NOT NULL, email TEXT UNIQUE NOT NULL);"
  }'
```

**Response (200):**
```json
{
  "success": true,
  "execution_time_ms": 45,
  "rows_affected": 0,
  "columns": [],
  "data": [],
  "message": "Table created successfully."
}
```

**Complex Schema Example:**
```bash
curl -X POST http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002/database/sql \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "sql": "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"; CREATE TYPE subscription_status AS ENUM (\"active\", \"cancelled\", \"expired\"); CREATE TABLE subscriptions (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), status subscription_status NOT NULL DEFAULT \"active\", metadata JSONB DEFAULT \"{}\");"
  }'
```

**Response (200):**
```json
{
  "success": true,
  "execution_time_ms": 78,
  "rows_affected": 0,
  "columns": [],
  "data": [],
  "message": "Extension and table created successfully."
}
```

---

### 2. List Tables

Get a list of all tables in the project database.

**Endpoint:** `GET /api/projects/{projectId}/database/tables/list`

**Headers:**
```
Authorization: Bearer {admin_access_token}
```

**Curl Example:**
```bash
curl -X GET http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/list \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "tables": [
    "auth_users",
    "auth_sessions", 
    "customers",
    "subscriptions",
    "orders"
  ],
  "total": 5
}
```

---

### 3. Get Table Metadata

Retrieve detailed metadata for tables including column information and constraints.

**Endpoint:** `GET /api/projects/{projectId}/database/tables`

**Query Parameters:**
- `table` (optional): Specific table name to get metadata for

**Curl Example:**
```bash
curl -X GET "http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables?table=customers" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
[
  {
    "table_name": "customers",
    "columns": [
      {
        "column_name": "id",
        "data_type": "uuid",
        "is_nullable": false,
        "column_default": "gen_random_uuid()",
        "ordinal_position": 1,
        "constraint_type": "PRIMARY KEY"
      },
      {
        "column_name": "name",
        "data_type": "text",
        "is_nullable": false,
        "column_default": null,
        "ordinal_position": 2,
        "constraint_type": null
      }
    ]
  }
]
```

---

### 4. Get Table Data

Retrieve data from a specific table with pagination and column information.

**Endpoint:** `GET /api/projects/{projectId}/database/tables/{tableName}/data`

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Rows per page (default: 20, max: 100)
- `orderBy` (optional): Column to sort by
- `orderDirection` (optional): Sort direction ('ASC' or 'DESC')

**Curl Example:**
```bash
curl -X GET "http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/data?page=1&limit=10" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "table_name": "customers",
  "total_rows": 150,
  "returned_rows": 10,
  "page": 1,
  "limit": 10,
  "columns": [
    { "name": "id", "type": "uuid" },
    { "name": "name", "type": "text" },
    { "name": "email", "type": "text" }
  ],
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "John Doe",
      "email": "john@example.com"
    }
  ]
}
```

---

## Row Operations

### 5. Insert Single Row

Insert a single row into a table with automatic data type handling.

**Endpoint:** `POST /api/projects/{projectId}/database/tables/{tableName}/rows`

**Body:**
```json
{
  "data": {
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30,
    "metadata": {"preferences": {"theme": "dark"}}
  }
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/rows \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "name": "John Doe",
      "email": "john@example.com",
      "age": 30
    }
  }'
```

**Response (200):**
```json
{
  "success": true,
  "rows_affected": 1,
  "message": "Row inserted successfully",
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "John Doe",
      "email": "john@example.com",
      "age": 30,
      "created_at": "2025-08-01T10:00:00Z"
    }
  ]
}
```

---

### 6. Update Row

Update a single row by its primary key.

**Endpoint:** `PUT /api/projects/{projectId}/database/tables/{tableName}/rows/{rowId}`

**Body:**
```json
{
  "data": {
    "name": "John Smith",
    "age": 31
  }
}
```

**Curl Example:**
```bash
curl -X PUT http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/rows/123e4567-e89b-12d3-a456-426614174000 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "name": "John Smith",
      "age": 31
    }
  }'
```

**Response (200):**
```json
{
  "success": true,
  "rows_affected": 1,
  "message": "Row updated successfully",
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "John Smith",
      "email": "john@example.com",
      "age": 31,
      "created_at": "2025-08-01T10:00:00Z"
    }
  ]
}
```

---

### 7. Delete Row

Delete a single row by its primary key.

**Endpoint:** `DELETE /api/projects/{projectId}/database/tables/{tableName}/rows/{rowId}`

**Curl Example:**
```bash
curl -X DELETE http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/rows/123e4567-e89b-12d3-a456-426614174000 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "rows_affected": 1,
  "message": "Row deleted successfully",
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "John Smith",
      "email": "john@example.com",
      "age": 31
    }
  ]
}
```

---

## Bulk Operations

All bulk operations use database transactions to ensure atomicity.

### 8. Bulk Insert

Insert multiple rows at once in a single transaction.

**Endpoint:** `POST /api/projects/{projectId}/database/tables/{tableName}/bulk-insert`

**Body:**
```json
{
  "data": [
    {
      "name": "Jane Smith",
      "email": "jane@example.com",
      "age": 25
    },
    {
      "name": "Bob Johnson", 
      "email": "bob@example.com",
      "age": 35
    }
  ]
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/bulk-insert \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "data": [
      {"name": "Jane Smith", "email": "jane@example.com", "age": 25},
      {"name": "Bob Johnson", "email": "bob@example.com", "age": 35}
    ]
  }'
```

**Response (200):**
```json
{
  "success": true,
  "rows_affected": 2,
  "message": "2 rows inserted successfully",
  "data": [
    {
      "id": "987fcdeb-51a2-43d1-9f4b-123456789abc",
      "name": "Jane Smith",
      "email": "jane@example.com",
      "age": 25,
      "created_at": "2025-08-01T10:00:00Z"
    },
    {
      "id": "456789ab-cdef-1234-5678-9abcdef01234", 
      "name": "Bob Johnson",
      "email": "bob@example.com",
      "age": 35,
      "created_at": "2025-08-01T10:00:00Z"
    }
  ]
}
```

---

### 9. Bulk Update

Update multiple rows based on conditions in a single transaction.

**Endpoint:** `PUT /api/projects/{projectId}/database/tables/{tableName}/bulk-update`

**Body:**
```json
{
  "updates": [
    {
      "where": {"id": "123e4567-e89b-12d3-a456-426614174000"},
      "data": {"age": 32}
    },
    {
      "where": {"email": "jane@example.com"},
      "data": {"name": "Jane Doe", "age": 26}
    }
  ]
}
```

**Response (200):**
```json
{
  "success": true,
  "rows_affected": 2,
  "message": "2 rows updated successfully"
}
```

---

### 10. Bulk Delete

Delete multiple rows based on conditions in a single transaction.

**Endpoint:** `DELETE /api/projects/{projectId}/database/tables/{tableName}/bulk-delete`

**Body:**
```json
{
  "conditions": [
    {"id": "123e4567-e89b-12d3-a456-426614174000"},
    {"email": "old@example.com"},
    {"age": {"$gt": 65}}
  ]
}
```

**Response (200):**
```json
{
  "success": true,
  "rows_affected": 2,
  "message": "2 rows deleted successf
  ully"
}
```

---

## Row Level Security (RLS) Management

OrbitNest Studio provides full support for PostgreSQL Row Level Security, allowing you to create sophisticated access control policies.

### 11. Enable RLS

Enable Row Level Security on a table to enforce access policies.

**Endpoint:** `POST /api/projects/{projectId}/database/tables/{tableName}/rls/enable`

**Response (200):**
```json
{
  "success": true,
  "table_name": "customers",
  "rls_enabled": true,
  "message": "RLS enabled successfully"
}
```

---

### 12. Disable RLS

Disable Row Level Security on a table.

**Endpoint:** `POST /api/projects/{projectId}/database/tables/{tableName}/rls/disable`

**Response (200):**
```json
{
  "success": true,
  "table_name": "customers", 
  "rls_enabled": false,
  "message": "RLS disabled successfully"
}
```

---

### 13. Create RLS Policy

Create a Row Level Security policy with fine-grained access control.

**Endpoint:** `POST /api/projects/{projectId}/database/tables/{tableName}/policies`

**Body:**
```json
{
  "name": "user_access_policy",
  "command": "SELECT",
  "role": "authenticated",
  "using": "auth.uid() = user_id",
  "with_check": "auth.uid() = user_id"
}
```

**Policy Commands:**
- `SELECT` - Control read access
- `INSERT` - Control row creation  
- `UPDATE` - Control row modification
- `DELETE` - Control row deletion
- `ALL` - Apply to all operations

**Response (200):**
```json
{
  "success": true,
  "table_name": "customers",
  "policy_name": "user_access_policy",
  "message": "Policy created successfully"
}
```

---

### 14. List RLS Policies

Get all Row Level Security policies for a table.

**Endpoint:** `GET /api/projects/{projectId}/database/tables/{tableName}/policies`

**Response (200):**
```json
{
  "success": true,
  "table_name": "customers",
  "policies": [
    {
      "name": "user_access_policy",
      "command": "SELECT",
      "role": "{authenticated}",
      "using": "auth.uid() = user_id",
      "with_check": "auth.uid() = user_id",
      "is_permissive": "PERMISSIVE"
    }
  ],
  "total": 1
}
```

---

### 15. Delete RLS Policy

Delete a specific Row Level Security policy from a table.

**Endpoint:** `DELETE /api/projects/{projectId}/database/tables/{tableName}/policies/{policyName}`

**Response (200):**
```json
{
  "success": true,
  "table_name": "customers",
  "policy_name": "user_access_policy", 
  "message": "Policy deleted successfully"
}
```

---

## Advanced Features

### PostgreSQL Extensions Support

Create PostgreSQL extensions for enhanced functionality:

```bash
curl -X POST http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002/database/sql \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "sql": "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\"; CREATE EXTENSION IF NOT EXISTS \"pgcrypto\";"
  }'
```

### Custom Data Types and ENUMs

Create custom PostgreSQL data types:

```bash
curl -X POST http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002/database/sql \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "sql": "CREATE TYPE user_status AS ENUM (\"active\", \"inactive\", \"suspended\"); CREATE TABLE users (id UUID PRIMARY KEY, status user_status DEFAULT \"active\");"
  }'
```

### JSONB Data Storage

Store and query JSON data with full PostgreSQL JSONB support:

```bash
curl -X POST http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/rows \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "name": "John Doe",
      "preferences": {
        "theme": "dark",
        "notifications": {
          "email": true,
          "push": false
        }
      }
    }
  }'
```

### Functions and Triggers

Create stored procedures and database triggers:

```bash
curl -X POST http://localhost:3002/api/projects/550e8400-e29b-41d4-a716-446655440002/database/sql \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "sql": "CREATE OR REPLACE FUNCTION update_modified_time() RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$ language plpgsql; CREATE TRIGGER update_customer_modtime BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION update_modified_time();"
  }'
```

---

## Error Handling

### Common Error Responses

**Table Not Found (404):**
```json
{
  "success": false,
  "error": "Table 'nonexistent_table' not found",
  "timestamp": "2025-08-01T10:00:00Z"
}
```

**Validation Error (400):**
```json
{
  "success": false,
  "error": "Validation failed: data should not be empty",
  "timestamp": "2025-08-01T10:00:00Z"
}
```

**SQL Security Error (403):**
```json
{
  "success": false,
  "error": "SQL contains forbidden keyword: CREATE DATABASE",
  "timestamp": "2025-08-01T10:00:00Z"
}
```

**Database Constraint Error (500):**
```json
{
  "success": false,
  "error": "Database constraint violation: duplicate key value violates unique constraint \"customers_email_key\"",
  "timestamp": "2025-08-01T10:00:00Z"
}
```

**SQL Syntax Error (400):**
```json
{
  "success": false,
  "error": "SQL syntax error: syntax error at or near \"CREATEE\"",
  "timestamp": "2025-08-01T10:00:00Z"
}
```

---

## Best Practices

### 1. Schema Design
- Use UUIDs for primary keys with `gen_random_uuid()` default
- Include `created_at` and `updated_at` timestamps  
- Use JSONB for flexible metadata storage
- Implement proper foreign key constraints

### 2. Security Implementation
- Always enable RLS on user-facing tables
- Create specific policies for different user roles
- Use `auth.uid()` for user-scoped access
- Validate permissions in application layer

### 3. Performance Optimization
- Create indexes on frequently queried columns
- Use bulk operations for multiple row changes
- Implement pagination for large result sets
- Monitor query execution times

### 4. Data Types
- Use appropriate PostgreSQL data types
- Leverage ENUMs for controlled vocabularies
- Store JSON data in JSONB columns
- Use arrays for list data

### 5. Monitoring
- Track execution times in API responses
- Monitor database growth and performance
- Implement proper error handling and logging
- Use database maintenance operations (VACUUM, ANALYZE)

Execute custom SQL queries within a project database.

**Endpoint:** `POST /api/projects/{id}/database/sql`

**Headers:**
```
Authorization: Bearer {admin_access_token}
Content-Type: application/json
```

**Body:**
```json
{
  "sql": "CREATE TABLE customers (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), name TEXT NOT NULL, email TEXT UNIQUE NOT NULL);"
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/sql \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "sql": "CREATE TABLE customers (id UUID PRIMARY KEY DEFAULT gen_random_uuid(), name TEXT NOT NULL, email TEXT UNIQUE NOT NULL);"
  }'
```

**Response (200):**
```json
{
  "success": true,
  "execution_time_ms": 45,
  "rows_affected": 0,
  "columns": [],
  "data": [],
  "message": "Table created successfully."
}
```

### Insert Data Example

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/sql \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "sql": "INSERT INTO customers (name, email) VALUES ('\''John Doe'\'', '\''john@example.com'\'');"
  }'
```

**Response (200):**
```json
{
  "success": true,
  "execution_time_ms": 12,
  "rows_affected": 1,
  "columns": [],
  "data": [],
  "message": "Insert executed successfully. 1 row(s) inserted."
}
```

### Query Data Example

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/sql \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "sql": "SELECT * FROM customers;"
  }'
```

**Response (200):**
```json
{
  "success": true,
  "execution_time_ms": 8,
  "rows_affected": 1,
  "columns": [
    { "name": "id", "type": "uuid" },
    { "name": "name", "type": "text" },
    { "name": "email", "type": "text" }
  ],
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440010",
      "name": "John Doe",
      "email": "john@example.com"
    }
  ],
  "message": "Query executed successfully. 1 row(s) returned."
}
```

### Get Table Metadata

Retrieve metadata for all tables or a specific table in the project database.

**Endpoint:** `GET /api/projects/{id}/database/tables`

**Query Parameters:**
- `table` (optional): Specific table name to get metadata for

**Curl Example:**
```bash
curl -X GET http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
[
  {
    "table_name": "customers",
    "columns": [
      {
        "column_name": "id",
        "data_type": "uuid",
        "is_nullable": false,
        "column_default": "gen_random_uuid()",
        "ordinal_position": 1,
        "constraint_type": "PRIMARY KEY"
      },
      {
        "column_name": "name",
        "data_type": "text",
        "is_nullable": false,
        "column_default": null,
        "ordinal_position": 2,
        "constraint_type": null
      },
      {
        "column_name": "email",
        "data_type": "text",
        "is_nullable": false,
        "column_default": null,
        "ordinal_position": 3,
        "constraint_type": "UNIQUE"
      }
    ]
  }
]
```

### Get Table Data

Retrieve data from a specific table with pagination, sorting, and column information.

**Endpoint:** `GET /api/projects/{id}/database/tables/{tableName}/data`

**Path Parameters:**
- `id`: Project UUID
- `tableName`: Name of the table to get data from

**Query Parameters:**
- `page` (optional): Page number (1-based, default: 1)
- `limit` (optional): Number of rows per page (1-100, default: 20)
- `orderBy` (optional): Column name to sort by
- `orderDirection` (optional): Sort direction ('ASC' or 'DESC', default: 'ASC')

**Security:**
- Prevents access to system tables (pg_*, information_schema)
- Blocks direct access to authentication tables (auth_users, auth_sessions, etc.)
- Validates table and column names to prevent SQL injection

**Curl Example:**
```bash
curl -X GET "http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/data?page=1&limit=10&orderBy=created_at&orderDirection=DESC" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "table_name": "customers",
  "total_rows": 150,
  "returned_rows": 10,
  "page": 1,
  "limit": 10,
  "columns": [
    { "name": "id", "type": "uuid" },
    { "name": "name", "type": "text" },
    { "name": "email", "type": "text" },
    { "name": "created_at", "type": "timestamp with time zone" }
  ],
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "John Doe",
      "email": "john@example.com",
      "created_at": "2025-07-28T15:30:00Z"
    },
    {
      "id": "987fcdeb-51a2-43d1-9f4b-123456789abc",
      "name": "Jane Smith",
      "email": "jane@example.com",
      "created_at": "2025-07-28T15:25:00Z"
    }
  ]
}
```

**Response Fields:**
- `success`: Whether the operation was successful
- `table_name`: Name of the queried table
- `total_rows`: Total number of rows in the table
- `returned_rows`: Number of rows returned in this response
- `page`: Current page number (1-based)
- `limit`: Number of rows per page
- `columns`: Array of column information with name and type
- `data`: Array of table rows

**Error Response (403 - Forbidden Table):**
```json
{
  "success": false,
  "error": "Direct access to auth table 'auth_users' is not allowed. Use project authentication APIs instead.",
  "timestamp": "2025-07-28T15:30:00Z"
}
```

**Error Response (400 - Invalid Parameters):**
```json
{
  "success": false,
  "error": "Invalid order by column name",
  "timestamp": "2025-07-28T15:30:00Z"
}
```

### Allowed SQL Operations

The following SQL operations are supported:

#### Table Management
```sql
-- Create table
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  price DECIMAL(10,2),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Alter table
ALTER TABLE products ADD COLUMN description TEXT;
ALTER TABLE products DROP COLUMN description;

-- Drop table
DROP TABLE products;
```

#### Data Operations
```sql
-- Insert data
INSERT INTO customers (name, email) VALUES ('Jane Doe', 'jane@example.com');

-- Update data
UPDATE customers SET name = 'Jane Smith' WHERE email = 'jane@example.com';

-- Delete data
DELETE FROM customers WHERE email = 'jane@example.com';

-- Query data
SELECT * FROM customers WHERE name LIKE '%John%';
```

#### Index Management
```sql
-- Create index
CREATE INDEX idx_customers_email ON customers(email);

-- Drop index
DROP INDEX idx_customers_email;
```

#### Advanced Features
```sql
-- Create function
CREATE OR REPLACE FUNCTION get_customer_count() 
RETURNS INTEGER AS $$
BEGIN
  RETURN (SELECT COUNT(*) FROM customers);
END;
$$ LANGUAGE plpgsql;

-- Create trigger
CREATE TRIGGER update_timestamp 
  BEFORE UPDATE ON customers 
  FOR EACH ROW 
  EXECUTE FUNCTION trigger_set_timestamp();
```

### Restricted Operations

The following operations are **NOT ALLOWED** for security reasons:

#### System-Level Operations
- `CREATE DATABASE`, `DROP DATABASE`, `ALTER DATABASE`
- `CREATE USER`, `ALTER USER`, `DROP USER`
- `CREATE ROLE`, `ALTER ROLE`, `DROP ROLE`
- `GRANT`, `REVOKE`

#### System Table Access
- Access to `pg_*` tables
- Direct manipulation of `information_schema`
- Access to `pg_catalog` tables

#### Administrative Commands
- `VACUUM`, `ANALYZE`, `REINDEX`
- `SET SESSION`, `SET GLOBAL`
- File system operations (`COPY FROM/TO`)

### Error Responses

#### SQL Syntax Error (400)
```json
{
  "success": false,
  "error": "SQL syntax error: syntax error at or near \"CREATEE\"",
  "timestamp": "2025-07-28T10:00:00Z"
}
```

#### Forbidden Operation (403)
```json
{
  "success": false,
  "error": "SQL contains forbidden keyword: DROP DATABASE",
  "timestamp": "2025-07-28T10:00:00Z"
}
```

#### Table Not Found (400)
```json
{
  "success": false,
  "error": "Resource not found: relation \"nonexistent_table\" does not exist",
  "timestamp": "2025-07-28T10:00:00Z"
}
```

---

## Database Operations - Advanced Features

The Database Operations API provides comprehensive database management capabilities including table operations, row CRUD operations, bulk operations, and Row Level Security (RLS) management. All operations are project-scoped and secure.

### Security Features

- **Project Isolation**: Each project operates in its own database
- **SQL Injection Prevention**: All queries are validated and sanitized
- **System Table Protection**: Access to PostgreSQL system tables is blocked
- **Authentication Required**: All endpoints require admin authentication

### 1. List Tables

Get a list of all tables in the project database.

**Endpoint:** `GET /api/projects/{projectId}/database/tables/list`

**Headers:**
```
Authorization: Bearer {admin_access_token}
```

**Curl Example:**
```bash
curl -X GET http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/list \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "tables": ["customers", "orders", "products"],
  "total": 3
}
```

### 2. Insert Single Row

Insert a single row into a table.

**Endpoint:** `POST /api/projects/{projectId}/database/tables/{tableName}/rows`

**Headers:**
```
Authorization: Bearer {admin_access_token}
Content-Type: application/json
```

**Body:**
```json
{
  "data": {
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30
  }
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/rows \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "name": "John Doe",
      "email": "john@example.com",
      "age": 30
    }
  }'
```

**Response (200):**
```json
{
  "success": true,
  "rows_affected": 1,
  "message": "Row inserted successfully",
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "John Doe",
      "email": "john@example.com",
      "age": 30,
      "created_at": "2025-08-01T10:00:00Z"
    }
  ]
}
```

### 3. Update Single Row

Update a single row by its ID.

**Endpoint:** `PUT /api/projects/{projectId}/database/tables/{tableName}/rows/{rowId}`

**Headers:**
```
Authorization: Bearer {admin_access_token}
Content-Type: application/json
```

**Body:**
```json
{
  "data": {
    "name": "John Smith",
    "age": 31
  }
}
```

**Curl Example:**
```bash
curl -X PUT http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/rows/123e4567-e89b-12d3-a456-426614174000 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "name": "John Smith",
      "age": 31
    }
  }'
```

**Response (200):**
```json
{
  "success": true,
  "rows_affected": 1,
  "message": "Row updated successfully",
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "John Smith",
      "email": "john@example.com",
      "age": 31,
      "created_at": "2025-08-01T10:00:00Z"
    }
  ]
}
```

### 4. Delete Single Row

Delete a single row by its ID.

**Endpoint:** `DELETE /api/projects/{projectId}/database/tables/{tableName}/rows/{rowId}`

**Headers:**
```
Authorization: Bearer {admin_access_token}
```

**Curl Example:**
```bash
curl -X DELETE http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/rows/123e4567-e89b-12d3-a456-426614174000 \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "rows_affected": 1,
  "message": "Row deleted successfully",
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "name": "John Smith",
      "email": "john@example.com",
      "age": 31,
      "created_at": "2025-08-01T10:00:00Z"
    }
  ]
}
```

### 5. Bulk Insert Rows

Insert multiple rows at once using a transaction for atomicity.

**Endpoint:** `POST /api/projects/{projectId}/database/tables/{tableName}/bulk-insert`

**Headers:**
```
Authorization: Bearer {admin_access_token}
Content-Type: application/json
```

**Body:**
```json
{
  "data": [
    {
      "name": "Jane Smith",
      "email": "jane@example.com",
      "age": 25
    },
    {
      "name": "Bob Johnson",
      "email": "bob@example.com",
      "age": 35
    }
  ]
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/bulk-insert \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "data": [
      {
        "name": "Jane Smith",
        "email": "jane@example.com",
        "age": 25
      },
      {
        "name": "Bob Johnson",
        "email": "bob@example.com",
        "age": 35
      }
    ]
  }'
```

**Response (200):**
```json
{
  "success": true,
  "rows_affected": 2,
  "message": "2 rows inserted successfully",
  "data": [
    {
      "id": "987fcdeb-51a2-43d1-9f4b-123456789abc",
      "name": "Jane Smith",
      "email": "jane@example.com",
      "age": 25,
      "created_at": "2025-08-01T10:00:00Z"
    },
    {
      "id": "456789ab-cdef-1234-5678-9abcdef01234",
      "name": "Bob Johnson",
      "email": "bob@example.com",
      "age": 35,
      "created_at": "2025-08-01T10:00:00Z"
    }
  ]
}
```

### 6. Bulk Update Rows

Update multiple rows at once using conditions.

**Endpoint:** `PUT /api/projects/{projectId}/database/tables/{tableName}/bulk-update`

**Headers:**
```
Authorization: Bearer {admin_access_token}
Content-Type: application/json
```

**Body:**
```json
{
  "updates": [
    {
      "where": { "id": "123e4567-e89b-12d3-a456-426614174000" },
      "data": { "age": 32 }
    },
    {
      "where": { "email": "jane@example.com" },
      "data": { "name": "Jane Doe", "age": 26 }
    }
  ]
}
```

**Curl Example:**
```bash
curl -X PUT http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/bulk-update \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "updates": [
      {
        "where": { "id": "123e4567-e89b-12d3-a456-426614174000" },
        "data": { "age": 32 }
      },
      {
        "where": { "email": "jane@example.com" },
        "data": { "name": "Jane Doe", "age": 26 }
      }
    ]
  }'
```

**Response (200):**
```json
{
  "success": true,
  "rows_affected": 2,
  "message": "2 rows updated successfully"
}
```

### 7. Bulk Delete Rows

Delete multiple rows at once using conditions.

**Endpoint:** `DELETE /api/projects/{projectId}/database/tables/{tableName}/bulk-delete`

**Headers:**
```
Authorization: Bearer {admin_access_token}
Content-Type: application/json
```

**Body:**
```json
{
  "conditions": [
    { "id": "123e4567-e89b-12d3-a456-426614174000" },
    { "email": "old@example.com" }
  ]
}
```

**Curl Example:**
```bash
curl -X DELETE http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/bulk-delete \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "conditions": [
      { "id": "123e4567-e89b-12d3-a456-426614174000" },
      { "email": "old@example.com" }
    ]
  }'
```

**Response (200):**
```json
{
  "success": true,
  "rows_affected": 2,
  "message": "2 rows deleted successfully"
}
```

### 8. Enable Row Level Security (RLS)

Enable Row Level Security on a table to enforce access policies.

**Endpoint:** `POST /api/projects/{projectId}/database/tables/{tableName}/rls/enable`

**Headers:**
```
Authorization: Bearer {admin_access_token}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/rls/enable \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "table_name": "customers",
  "rls_enabled": true,
  "message": "RLS enabled successfully"
}
```

### 9. Disable Row Level Security (RLS)

Disable Row Level Security on a table.

**Endpoint:** `POST /api/projects/{projectId}/database/tables/{tableName}/rls/disable`

**Headers:**
```
Authorization: Bearer {admin_access_token}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/rls/disable \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "table_name": "customers",
  "rls_enabled": false,
  "message": "RLS disabled successfully"
}
```

### 10. Create RLS Policy

Create a Row Level Security policy for a table.

**Endpoint:** `POST /api/projects/{projectId}/database/tables/{tableName}/policies`

**Headers:**
```
Authorization: Bearer {admin_access_token}
Content-Type: application/json
```

**Body:**
```json
{
  "name": "user_access_policy",
  "command": "SELECT",
  "role": "authenticated",
  "using": "auth.uid() = user_id",
  "with_check": "auth.uid() = user_id"
}
```

**Curl Example:**
```bash
curl -X POST http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/policies \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json" \
  -d '{
    "name": "user_access_policy",
    "command": "SELECT",
    "role": "authenticated",
    "using": "auth.uid() = user_id",
    "with_check": "auth.uid() = user_id"
  }'
```

**Response (200):**
```json
{
  "success": true,
  "table_name": "customers",
  "policy_name": "user_access_policy",
  "message": "Policy created successfully"
}
```

### 11. List RLS Policies

Get all Row Level Security policies for a table.

**Endpoint:** `GET /api/projects/{projectId}/database/tables/{tableName}/policies`

**Headers:**
```
Authorization: Bearer {admin_access_token}
```

**Curl Example:**
```bash
curl -X GET http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/policies \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "table_name": "customers",
  "policies": [
    {
      "name": "user_access_policy",
      "command": "SELECT",
      "role": "{authenticated}",
      "using": "auth.uid() = user_id",
      "with_check": "auth.uid() = user_id",
      "is_permissive": "PERMISSIVE"
    }
  ],
  "total": 1
}
```

### 12. Delete RLS Policy

Delete a specific Row Level Security policy from a table.

**Endpoint:** `DELETE /api/projects/{projectId}/database/tables/{tableName}/policies/{policyName}`

**Headers:**
```
Authorization: Bearer {admin_access_token}
```

**Curl Example:**
```bash
curl -X DELETE http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440002/database/tables/customers/policies/user_access_policy \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Response (200):**
```json
{
  "success": true,
  "table_name": "customers",
  "policy_name": "user_access_policy",
  "message": "Policy deleted successfully"
}
```

### Policy Commands

The following commands are supported for RLS policies:

- `SELECT`: Control which rows can be selected/read
- `INSERT`: Control which rows can be inserted
- `UPDATE`: Control which rows can be updated
- `DELETE`: Control which rows can be deleted
- `ALL`: Apply to all operations (SELECT, INSERT, UPDATE, DELETE)

### Policy Roles

Common roles for RLS policies:

- `public`: Applies to all users (including anonymous)
- `authenticated`: Applies only to authenticated users
- `anon`: Applies only to anonymous users
- Custom roles: You can create and assign custom roles

### Error Responses

**Invalid Table (404):**
```json
{
  "success": false,
  "error": "Table 'nonexistent_table' not found",
  "timestamp": "2025-08-01T10:00:00Z"
}
```

**Validation Error (400):**
```json
{
  "success": false,
  "error": "Validation failed: data should not be empty",
  "timestamp": "2025-08-01T10:00:00Z"
}
```

**Database Error (500):**
```json
{
  "success": false,
  "error": "Database constraint violation: duplicate key value violates unique constraint",
  "timestamp": "2025-08-01T10:00:00Z"
}
```

---

## Health Checks

### 1. Database Health Check

Check the health of the central database connection.

**Endpoint:** `GET /api/database/health`

**Curl Example:**
```bash
curl -X GET http://localhost:3001/api/database/health
```

**Response (200):**
```json
{
  "status": "healthy",
  "timestamp": "2025-01-28T10:00:00Z",
  "database": "postgresql"
}
```

---

## Error Responses

All endpoints return consistent error responses:

### 400 Bad Request
```json
{
  "success": false,
  "error": "Validation failed",
  "details": [
    {
      "field": "email",
      "message": "Invalid email format"
    }
  ],
  "timestamp": "2025-01-28T10:00:00Z"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "error": "Unauthorized",
  "message": "Invalid or expired token",
  "timestamp": "2025-01-28T10:00:00Z"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "error": "Forbidden",
  "message": "Insufficient permissions",
  "timestamp": "2025-01-28T10:00:00Z"
}
```

### 404 Not Found
```json
{
  "success": false,
  "error": "Not Found",
  "message": "Resource not found",
  "timestamp": "2025-01-28T10:00:00Z"
}
```

### 409 Conflict
```json
{
  "success": false,
  "error": "Conflict",
  "message": "Resource already exists",
  "timestamp": "2025-01-28T10:00:00Z"
}
```

### 429 Too Many Requests
```json
{
  "success": false,
  "error": "Too Many Requests",
  "message": "Rate limit exceeded",
  "timestamp": "2025-01-28T10:00:00Z"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "error": "Internal Server Error",
  "message": "An unexpected error occurred",
  "timestamp": "2025-01-28T10:00:00Z"
}
```

---

## Authentication Headers

### Admin Authentication
```
Authorization: Bearer {admin_access_token}
```

### Project User Authentication
```
Authorization: Bearer {project_user_token}
```

### Project Service Role
```
Authorization: Bearer {service_role_key}
```

### Project Anonymous Key
```
Authorization: Bearer {anon_key}
```

---

## Rate Limits

- **Authentication endpoints**: 5 requests per minute
- **General API endpoints**: 60 requests per minute
- **Anonymous key**: 100 requests per minute
- **Service role key**: 1000 requests per minute

---

## Frontend Integration Examples

### JavaScript/TypeScript (React/Next.js)

```javascript
// Admin Authentication
const adminAuth = {
  baseUrl: 'http://localhost:3001',
  
  async signIn(email, password) {
    const response = await fetch(`${this.baseUrl}/api/auth/signin`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    return response.json();
  },
  
  async createProject(name, accessToken) {
    const response = await fetch(`${this.baseUrl}/api/projects`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`
      },
      body: JSON.stringify({ name })
    });
    return response.json();
  }
};

// Database Operations
const databaseOps = {
  baseUrl: 'http://localhost:3001',
  
  async executeSql(projectId, sql, accessToken) {
    const response = await fetch(`${this.baseUrl}/api/projects/${projectId}/database/sql`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`
      },
      body: JSON.stringify({ sql })
    });
    return response.json();
  },
  
  async getTableMetadata(projectId, tableName, accessToken) {
    const url = tableName 
      ? `${this.baseUrl}/api/projects/${projectId}/database/tables?table=${tableName}`
      : `${this.baseUrl}/api/projects/${projectId}/database/tables`;
    
    const response = await fetch(url, {
      headers: {
        'Authorization': `Bearer ${accessToken}`
      }
    });
    return response.json();
  },
  
  async createTable(projectId, tableName, columns, accessToken) {
    const columnDefs = columns.map(col => 
      `${col.name} ${col.type}${col.constraints ? ` ${col.constraints}` : ''}`
    ).join(', ');
    
    const sql = `CREATE TABLE ${tableName} (${columnDefs});`;
    
    return this.executeSql(projectId, sql, accessToken);
  },
  
  async insertData(projectId, tableName, data, accessToken) {
    const columns = Object.keys(data).join(', ');
    const values = Object.values(data).map(v => 
      typeof v === 'string' ? `'${v.replace(/'/g, "''")}'` : v
    ).join(', ');
    
    const sql = `INSERT INTO ${tableName} (${columns}) VALUES (${values});`;
    
    return this.executeSql(projectId, sql, accessToken);
  },
  
  async queryData(projectId, tableName, where, accessToken) {
    const sql = where 
      ? `SELECT * FROM ${tableName} WHERE ${where};`
      : `SELECT * FROM ${tableName};`;
    
    return this.executeSql(projectId, sql, accessToken);
  },
  
  async getTableData(projectId, tableName, options = {}, accessToken) {
    const {
      page = 1,
      limit = 20,
      orderBy,
      orderDirection = 'ASC'
    } = options;
    
    const params = new URLSearchParams({
      page: page.toString(),
      limit: limit.toString()
    });
    
    if (orderBy) {
      params.append('orderBy', orderBy);
      params.append('orderDirection', orderDirection);
    }
    
    const response = await fetch(`${this.baseUrl}/api/projects/${projectId}/database/tables/${tableName}/data?${params}`, {
      headers: { 'Authorization': `Bearer ${accessToken}` }
    });
    
    return response.json();
  },
  
  async getTableMetadata(projectId, tableName, accessToken) {
    const url = tableName 
      ? `${this.baseUrl}/api/projects/${projectId}/database/tables?table=${tableName}`
      : `${this.baseUrl}/api/projects/${projectId}/database/tables`;
      
    const response = await fetch(url, {
      headers: { 'Authorization': `Bearer ${accessToken}` }
    });
    
    return response.json();
  }
};

// Project User Authentication (Supabase-style)
const projectAuth = {
  projectUrl: 'http://localhost:3001/projects/my_awesome_project',
  anonKey: 'your-anon-key',
  
  async signUp(email, password) {
    const response = await fetch(`${this.projectUrl}/auth/signup`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    return response.json();
  },
  
  async callFunction(functionName, data, userToken) {
    const response = await fetch(`${this.projectUrl}/functions/v1/${functionName}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${userToken || this.anonKey}`
      },
      body: JSON.stringify(data)
    });
    return response.json();
  }
};

// Usage Examples
const examples = {
  async setupTableAndViewData() {
    const accessToken = 'your-admin-access-token';
    const projectId = 'your-project-id';
    
    // 1. Create a table
    await database.executeSql(projectId, `
      CREATE TABLE products (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        name TEXT NOT NULL,
        price DECIMAL(10,2) NOT NULL,
        category TEXT,
        created_at TIMESTAMPTZ DEFAULT NOW()
      );
    `, accessToken);
    
    // 2. Insert sample data
    await database.executeSql(projectId, `
      INSERT INTO products (name, price, category) VALUES 
      ('Laptop', 999.99, 'Electronics'),
      ('Book', 19.99, 'Education'),
      ('Coffee Mug', 12.50, 'Kitchen');
    `, accessToken);
    
    // 3. Get table data with pagination and sorting
    const tableData = await database.getTableData(projectId, 'products', {
      page: 1,
      limit: 10,
      orderBy: 'created_at',
      orderDirection: 'DESC'
    }, accessToken);
    
    console.log('Table Data:', tableData);
    // Returns: { success: true, table_name: 'products', total_rows: 3, data: [...] }
    
    // 4. Get table structure/metadata
    const metadata = await database.getTableMetadata(projectId, 'products', accessToken);
    console.log('Table Metadata:', metadata);
    
    // 5. Get paginated data (page 2)
    const nextPage = await database.getTableData(projectId, 'products', {
      page: 2,
      limit: 2
    }, accessToken);
    
    return { tableData, metadata, nextPage };
  }
};
```

---

## Logging & Monitoring

The logging system provides comprehensive tracking of database operations, authentication events, edge function executions, and console outputs. All logs are automatically captured and stored for monitoring, debugging, and audit purposes.

### 1. Get All Logs

Retrieve unified logs across all system components with filtering and pagination.

**Endpoint:** `GET /api/projects/{projectId}/logs`

**Headers:**
```
Authorization: Bearer {admin_access_token}
Content-Type: application/json
```

**Query Parameters:**
- `level[]` (optional): Filter by log levels (info, warn, error, debug)
- `start_time` (optional): Start date (ISO 8601 format)
- `end_time` (optional): End date (ISO 8601 format)
- `limit` (optional): Number of logs to return (1-1000, default: 100)
- `offset` (optional): Number of logs to skip (default: 0)
- `user_id` (optional): Filter by specific user ID
- `search` (optional): Full-text search in log messages
- `event_type` (optional): Filter by event type (database, auth, edge_function, system)
- `order` (optional): Sort order (asc, desc, default: desc)

**Example Request:**
```bash
curl -X GET "http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440000/logs?level[]=error&level[]=warn&limit=50&event_type=database" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json"
```

**Example Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "log-123",
      "project_id": "550e8400-e29b-41d4-a716-446655440000",
      "log_level": "error",
      "event_type": "database",
      "event_subtype": "query_failed",
      "user_id": "user-456",
      "source_table": "users",
      "operation_type": "SELECT",
      "duration_ms": 1500,
      "ip_address": "192.168.1.100",
      "error_message": "Syntax error in SQL query",
      "metadata": {
        "sql_query": "SELECT * FROM users WHERE email = ***masked***",
        "rows_affected": 0
      },
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 1,
  "limit": 50,
  "offset": 0,
  "filters": {
    "level": ["error", "warn"],
    "event_type": "database"
  }
}
```

### 2. Get Database Operation Logs

Retrieve logs specific to database operations including SQL queries, table operations, and performance metrics.

**Endpoint:** `GET /api/projects/{projectId}/logs/database`

**Headers:**
```
Authorization: Bearer {admin_access_token}
Content-Type: application/json
```

**Query Parameters:**
- All common query parameters from Get All Logs
- `table_name` (optional): Filter by specific table name
- `operation_type` (optional): Filter by operation type (SELECT, INSERT, UPDATE, DELETE, etc.)
- `success` (optional): Filter by success status (true/false)

**Example Request:**
```bash
curl -X GET "http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440000/logs/database?table_name=users&operation_type=SELECT&success=false" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json"
```

**Example Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "db-log-123",
      "project_id": "550e8400-e29b-41d4-a716-446655440000",
      "operation_id": "op-456",
      "sql_query": "SELECT * FROM users WHERE id = $1",
      "table_name": "users",
      "operation_type": "SELECT",
      "rows_affected": 0,
      "execution_time_ms": 45,
      "success": false,
      "error_message": "Permission denied for table users",
      "user_id": "user-789",
      "query_hash": "abc123def456",
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 1,
  "limit": 100,
  "offset": 0
}
```

### 3. Get Slow Database Queries

Retrieve database operations that took longer than 1000ms to execute.

**Endpoint:** `GET /api/projects/{projectId}/logs/database/slow`

**Headers:**
```
Authorization: Bearer {admin_access_token}
```

**Example Request:**
```bash
curl -X GET "http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440000/logs/database/slow?limit=20" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 4. Get Database Error Logs

Retrieve only failed database operations for debugging purposes.

**Endpoint:** `GET /api/projects/{projectId}/logs/database/errors`

**Headers:**
```
Authorization: Bearer {admin_access_token}
```

**Example Request:**
```bash
curl -X GET "http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440000/logs/database/errors" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 5. Get Authentication Logs

Retrieve logs for authentication events including signups, signins, failures, and security events.

**Endpoint:** `GET /api/projects/{projectId}/logs/auth`

**Headers:**
```
Authorization: Bearer {admin_access_token}
Content-Type: application/json
```

**Query Parameters:**
- All common query parameters from Get All Logs
- `auth_method` (optional): Filter by authentication method (email_otp, password, oauth)
- `ip_address` (optional): Filter by specific IP address

**Example Request:**
```bash
curl -X GET "http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440000/logs/auth?auth_method=email_otp&success=false" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json"
```

**Example Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "auth-log-123",
      "project_id": "550e8400-e29b-41d4-a716-446655440000",
      "event_id": "event-456",
      "user_id": "user-789",
      "event_type": "signin_failed",
      "auth_method": "email_otp",
      "success": false,
      "failure_reason": "invalid_code",
      "ip_address": "192.168.1.100",
      "user_agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
      "session_id": null,
      "metadata": {
        "email": "user@example.com",
        "attempt_count": 3
      },
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 1,
  "limit": 100,
  "offset": 0
}
```

### 6. Get Authentication Failure Logs

Retrieve only failed authentication attempts for security monitoring.

**Endpoint:** `GET /api/projects/{projectId}/logs/auth/failures`

**Headers:**
```
Authorization: Bearer {admin_access_token}
```

**Example Request:**
```bash
curl -X GET "http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440000/logs/auth/failures?limit=50" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 7. Get Security-Related Logs

Retrieve logs related to security events such as account bans, lockouts, and suspicious activities.

**Endpoint:** `GET /api/projects/{projectId}/logs/auth/security`

**Headers:**
```
Authorization: Bearer {admin_access_token}
```

**Example Request:**
```bash
curl -X GET "http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440000/logs/auth/security" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 8. Get Edge Function Execution Logs

Retrieve logs for edge function executions including performance metrics and error details.

**Endpoint:** `GET /api/projects/{projectId}/logs/edge-functions`

**Headers:**
```
Authorization: Bearer {admin_access_token}
Content-Type: application/json
```

**Query Parameters:**
- All common query parameters from Get All Logs
- `status` (optional): Filter by execution status (success, error, timeout)
- `function_name` (optional): Filter by specific function name

**Example Request:**
```bash
curl -X GET "http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440000/logs/edge-functions?status=error" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -H "Content-Type: application/json"
```

**Example Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "func-log-123",
      "project_id": "550e8400-e29b-41d4-a716-446655440000",
      "function_id": "func-456",
      "execution_id": "exec-789",
      "status": "error",
      "duration_ms": 5000,
      "memory_used_mb": 128,
      "request_method": "POST",
      "request_path": "/api/webhook",
      "response_status": null,
      "error_message": "Function execution timed out",
      "error_stack": "Error: Timeout\n    at executeFunction...",
      "user_id": "user-123",
      "ip_address": "192.168.1.100",
      "cold_start": true,
      "created_at": "2024-01-15T10:30:00Z"
    }
  ],
  "total": 1,
  "limit": 100,
  "offset": 0
}
```

### 9. Get Edge Function Console Logs

Retrieve console output (console.log, console.error, etc.) from edge function executions.

**Endpoint:** `GET /api/projects/{projectId}/logs/edge-functions/{functionName}/console`

**Headers:**
```
Authorization: Bearer {admin_access_token}
```

**Query Parameters:**
- `execution_id` (required): Specific execution ID to get console logs for
- `console_level` (optional): Filter by console level (log, error, warn, info)

**Example Request:**
```bash
curl -X GET "http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440000/logs/edge-functions/my-function/console?execution_id=exec-789" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**Example Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "console-log-1",
      "execution_id": "exec-789",
      "log_level": "log",
      "message": "Processing user request",
      "args": ["user_id: 123", "action: create"],
      "timestamp": "2024-01-15T10:30:00.123Z",
      "sequence_number": 1
    },
    {
      "id": "console-log-2",
      "execution_id": "exec-789",
      "log_level": "error",
      "message": "Validation failed",
      "args": ["Invalid email format"],
      "timestamp": "2024-01-15T10:30:00.456Z",
      "sequence_number": 2
    }
  ],
  "total": 2,
  "limit": 2,
  "offset": 0
}
```

### 10. Get Edge Function Error Logs

Retrieve only failed edge function executions for a specific function.

**Endpoint:** `GET /api/projects/{projectId}/logs/edge-functions/{functionName}/errors`

**Headers:**
```
Authorization: Bearer {admin_access_token}
```

**Example Request:**
```bash
curl -X GET "http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440000/logs/edge-functions/my-function/errors" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### 11. Export Logs

Export logs in JSON or CSV format for external analysis or backup purposes.

**Endpoint:** `GET /api/projects/{projectId}/logs/export`

**Headers:**
```
Authorization: Bearer {admin_access_token}
```

**Query Parameters:**
- `format` (optional): Export format (json, csv, default: json)
- `start_time` (optional): Start date (ISO 8601 format)
- `end_time` (optional): End date (ISO 8601 format)
- `event_type` (optional): Filter by event type

**Example Request (JSON):**
```bash
curl -X GET "http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440000/logs/export?format=json&start_time=2024-01-01T00:00:00Z&end_time=2024-01-02T00:00:00Z" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -o logs-export.json
```

**Example Request (CSV):**
```bash
curl -X GET "http://localhost:3001/api/projects/550e8400-e29b-41d4-a716-446655440000/logs/export?format=csv&event_type=auth" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -o auth-logs.csv
```

### Frontend Integration Example

```typescript
class LoggingClient {
  constructor(private baseUrl: string, private accessToken: string) {}

  async getLogs(projectId: string, filters: LogFilters = {}) {
    const queryParams = new URLSearchParams();
    
    if (filters.level?.length) {
      filters.level.forEach(level => queryParams.append('level[]', level));
    }
    if (filters.startTime) queryParams.set('start_time', filters.startTime);
    if (filters.endTime) queryParams.set('end_time', filters.endTime);
    if (filters.limit) queryParams.set('limit', filters.limit.toString());
    if (filters.offset) queryParams.set('offset', filters.offset.toString());
    if (filters.search) queryParams.set('search', filters.search);
    if (filters.eventType) queryParams.set('event_type', filters.eventType);

    const response = await fetch(
      `${this.baseUrl}/api/projects/${projectId}/logs?${queryParams}`,
      {
        headers: {
          'Authorization': `Bearer ${this.accessToken}`,
          'Content-Type': 'application/json',
        },
      }
    );

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    return response.json();
  }

  async getDatabaseLogs(projectId: string, filters: DatabaseLogFilters = {}) {
    const queryParams = new URLSearchParams();
    
    if (filters.tableName) queryParams.set('table_name', filters.tableName);
    if (filters.operationType) queryParams.set('operation_type', filters.operationType);
    if (filters.success !== undefined) queryParams.set('success', filters.success.toString());

    const response = await fetch(
      `${this.baseUrl}/api/projects/${projectId}/logs/database?${queryParams}`,
      {
        headers: {
          'Authorization': `Bearer ${this.accessToken}`,
          'Content-Type': 'application/json',
        },
      }
    );

    return response.json();
  }

  async getSlowQueries(projectId: string) {
    const response = await fetch(
      `${this.baseUrl}/api/projects/${projectId}/logs/database/slow`,
      {
        headers: {
          'Authorization': `Bearer ${this.accessToken}`,
        },
      }
    );

    return response.json();
  }

  async getAuthFailures(projectId: string, filters: AuthLogFilters = {}) {
    const queryParams = new URLSearchParams();
    
    if (filters.startTime) queryParams.set('start_time', filters.startTime);
    if (filters.endTime) queryParams.set('end_time', filters.endTime);
    if (filters.ipAddress) queryParams.set('ip_address', filters.ipAddress);

    const response = await fetch(
      `${this.baseUrl}/api/projects/${projectId}/logs/auth/failures?${queryParams}`,
      {
        headers: {
          'Authorization': `Bearer ${this.accessToken}`,
        },
      }
    );

    return response.json();
  }

  async getEdgeFunctionConsoleLogs(projectId: string, functionName: string, executionId: string) {
    const response = await fetch(
      `${this.baseUrl}/api/projects/${projectId}/logs/edge-functions/${functionName}/console?execution_id=${executionId}`,
      {
        headers: {
          'Authorization': `Bearer ${this.accessToken}`,
        },
      }
    );

    return response.json();
  }

  async exportLogs(projectId: string, format: 'json' | 'csv' = 'json', filters: ExportFilters = {}) {
    const queryParams = new URLSearchParams();
    
    queryParams.set('format', format);
    if (filters.startTime) queryParams.set('start_time', filters.startTime);
    if (filters.endTime) queryParams.set('end_time', filters.endTime);
    if (filters.eventType) queryParams.set('event_type', filters.eventType);

    const response = await fetch(
      `${this.baseUrl}/api/projects/${projectId}/logs/export?${queryParams}`,
      {
        headers: {
          'Authorization': `Bearer ${this.accessToken}`,
        },
      }
    );

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    // Return blob for file download
    return response.blob();
  }
}

// Usage example
const loggingClient = new LoggingClient('http://localhost:3001', 'your-access-token');

// Get recent errors across all systems
const recentErrors = await loggingClient.getLogs('project-123', {
  level: ['error'],
  limit: 50,
  startTime: '2024-01-15T00:00:00Z'
});

// Monitor failed authentication attempts
const authFailures = await loggingClient.getAuthFailures('project-123', {
  startTime: '2024-01-15T00:00:00Z',
  endTime: '2024-01-15T23:59:59Z'
});

// Check slow database queries
const slowQueries = await loggingClient.getSlowQueries('project-123');

// Export logs for analysis
const logBlob = await loggingClient.exportLogs('project-123', 'csv', {
  eventType: 'database',
  startTime: '2024-01-01T00:00:00Z',
  endTime: '2024-01-31T23:59:59Z'
});

// Download the exported file
const url = URL.createObjectURL(logBlob);
const a = document.createElement('a');
a.href = url;
a.download = 'database-logs.csv';
a.click();
```

### Log Event Types

The logging system captures the following event types:

**Database Events:**
- `query_executed` - SQL query execution
- `schema_change` - Table/schema modifications
- `rls_operation` - Row-Level Security operations
- `bulk_operation` - Bulk insert/update/delete operations

**Authentication Events:**
- `signup_requested` - User registration initiated
- `signup_completed` - User registration completed
- `signin_requested` - Sign-in process initiated
- `signin_completed` - Successful sign-in
- `signin_failed` - Failed sign-in attempt
- `signout_completed` - User sign-out
- `password_changed` - Password change
- `account_banned` - Account banned/suspended

**Edge Function Events:**
- `function_executed` - Function execution
- `function_deployed` - Function deployment
- `console_log` - Console output from function

**System Events:**
- `api_request` - API endpoint access
- `system_error` - System-level errors
- `security_violation` - Security-related events

### Monitoring Best Practices

1. **Regular Monitoring**: Check logs daily for errors and security events
2. **Performance Tracking**: Monitor slow queries and function execution times
3. **Security Alerts**: Set up monitoring for failed authentication attempts
4. **Log Retention**: Export important logs before they expire
5. **Filtering**: Use specific filters to reduce noise and focus on relevant events
6. **Correlation**: Use request_id and execution_id to correlate related log entries

---

## Health Checks

---

This documentation covers all the currently implemented API endpoints in the OrbitNest Studio backend. Use these curl examples and patterns to integrate with your frontend application. The system is designed to be Supabase-compatible, so existing Supabase client libraries should work with minimal modifications.
