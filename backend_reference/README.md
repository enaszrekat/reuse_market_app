# Backend Message API Requirements

## Problem
Messages are not being inserted into the database. The frontend sends all required data, but the backend INSERT operation is failing silently.

## Frontend Sends
The Flutter app sends the following POST data to `send_message.php`:
- `conversation_id` (INT, required)
- `sender_id` (INT, required)
- `receiver_id` (INT, required) ⚠️ **CRITICAL: Must be included in INSERT**
- `message` (TEXT, required)

## Required Backend Implementation

### 1. Validation
- Validate all fields are present and > 0
- Return HTTP 400 with JSON error if validation fails
- Do NOT return HTTP 200 if validation fails

### 2. Database INSERT
The INSERT query MUST include `receiver_id`:

```sql
INSERT INTO messages (
    conversation_id,
    sender_id,
    receiver_id,  -- ⚠️ THIS IS CRITICAL
    message,
    created_at,
    is_read
) VALUES (
    :conversation_id,
    :sender_id,
    :receiver_id,  -- ⚠️ MUST BE INCLUDED
    :message,
    NOW(),
    0
)
```

### 3. Error Handling
- Catch PDO exceptions
- Log SQL errors to error log
- Return HTTP 500 with error message if INSERT fails
- Do NOT return success if INSERT fails

### 4. Response Format
**On Success (HTTP 200):**
```json
{
    "status": "success",
    "message_id": 123,
    "message": "Message sent successfully"
}
```

**On Error (HTTP 400/500):**
```json
{
    "status": "error",
    "message": "Error description here"
}
```

### 5. Verification
- After INSERT, verify message exists in database
- Only return success if message is confirmed in database
- Log all operations for debugging

## Reference Implementation
See `send_message.php` in this directory for a complete working implementation.

## Common Issues

1. **Missing receiver_id in INSERT**: This is the most common issue. The INSERT query must include receiver_id.

2. **Silent failures**: Backend returns HTTP 200 even when INSERT fails. Must check INSERT result.

3. **Invalid JSON response**: Backend returns HTML error page or plain text instead of JSON. Must catch PHP errors.

4. **No error logging**: SQL errors are not logged. Must use error_log() to debug.

## Testing Checklist

- [ ] All fields validated before INSERT
- [ ] receiver_id included in INSERT query
- [ ] INSERT result checked (affected rows > 0)
- [ ] Message verified in database after INSERT
- [ ] SQL errors logged to error log
- [ ] Returns proper JSON (not HTML/plain text)
- [ ] HTTP status codes correct (200 for success, 400/500 for errors)
- [ ] Error messages are clear and helpful

