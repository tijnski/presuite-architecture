# Session Token Validation - TODO

## Issue

When a user signs in on presuite.eu, the session token is shared with other apps (PreMail, PreDrive, etc.). However, there's no periodic validation of this token on the client apps.

### Problem Scenario (Web3)

1. User signs in with Web3 wallet on presuite.eu
2. Session token is stored and shared with PreMail, PreDrive, etc.
3. User's wallet gets locked or session expires on the auth server
4. PreMail/PreDrive still show the user as "logged in" (stale state)
5. API calls fail but UI doesn't reflect the logged-out state
6. User has to manually refresh or navigate to realize they're signed out

### Expected Behavior

- Apps should periodically validate the session token against presuite.eu
- If token is invalid/expired, automatically sign out the user
- Show appropriate message prompting re-authentication

## Proposed Solution

### 1. Add Periodic Token Validation

Each app should check token validity at regular intervals:

```javascript
// In authService.js or a new sessionService.js
const SESSION_CHECK_INTERVAL = 5 * 60 * 1000; // 5 minutes

export function startSessionValidator(onSessionInvalid) {
  const checkSession = async () => {
    const token = getToken();
    if (!token) return;

    try {
      const response = await fetch(`${AUTH_API_URL}/verify`, {
        headers: { Authorization: `Bearer ${token}` }
      });

      if (!response.ok) {
        onSessionInvalid();
      }
    } catch (error) {
      console.error('Session validation failed:', error);
      // Optionally sign out on network errors after multiple failures
    }
  };

  // Check immediately, then periodically
  checkSession();
  return setInterval(checkSession, SESSION_CHECK_INTERVAL);
}

export function stopSessionValidator(intervalId) {
  clearInterval(intervalId);
}
```

### 2. Integration in Apps

#### PreSuite Hub (presuite.eu)

```javascript
// In PreSuiteLaunchpad.jsx or App.jsx
useEffect(() => {
  if (user) {
    const intervalId = startSessionValidator(() => {
      logout();
      setUser(null);
      // Show "Session expired" message
    });
    return () => stopSessionValidator(intervalId);
  }
}, [user]);
```

#### PreMail (premail.site)

```javascript
// In App.tsx or main layout
useEffect(() => {
  const intervalId = startSessionValidator(() => {
    // Clear local state
    // Redirect to presuite.eu/login
    window.location.href = 'https://presuite.eu/login?redirect=premail';
  });
  return () => stopSessionValidator(intervalId);
}, []);
```

#### PreDrive (predrive.eu)

Same pattern as PreMail.

### 3. Additional Improvements

#### Visibility-based checking
Only check when tab is visible to save resources:

```javascript
document.addEventListener('visibilitychange', () => {
  if (document.visibilityState === 'visible') {
    checkSession();
  }
});
```

#### Check on user activity
Validate before important actions:

```javascript
// Before file upload, email send, etc.
async function validateBeforeAction(action) {
  const isValid = await checkSession();
  if (isValid) {
    return action();
  } else {
    handleSessionExpired();
  }
}
```

#### Broadcast logout across tabs
Use BroadcastChannel to sync logout across tabs:

```javascript
const authChannel = new BroadcastChannel('presuite-auth');

// On logout
authChannel.postMessage({ type: 'logout' });

// Listen for logout
authChannel.onmessage = (event) => {
  if (event.data.type === 'logout') {
    clearLocalAuth();
    redirectToLogin();
  }
};
```

## Files to Modify

| Service | Files |
|---------|-------|
| PreSuite Hub | `src/services/authService.js`, `src/components/PreSuiteLaunchpad.jsx` |
| PreMail | `apps/web/src/services/authService.ts`, `apps/web/src/App.tsx` |
| PreDrive | `apps/web/src/services/authService.ts`, `apps/web/src/App.tsx` |

## API Endpoint

The `/api/auth/verify` endpoint on presuite.eu should:
- Accept: `Authorization: Bearer <token>` header
- Return: `200 OK` with `{ valid: true, user: {...} }` if valid
- Return: `401 Unauthorized` if token is invalid/expired

## Priority

**Medium-High** - Affects user experience, especially for Web3 users whose wallet state can change independently.

## Related

- Web3 wallet connection state monitoring
- Token refresh mechanism (if implementing refresh tokens)
- Cross-tab session synchronization
