

### 1. Supervisor
```json
{
  "success": true,
  "message": "Profile fetched successfully.",
  "data": {
    "id": "5b1c8e2d-6f4a-4c3b-9e1d-7a2b3c4d5e01",
    "name": "Karim Supervisor",
    "email": "supervisor@example.com",
    "role": "Supervisor",
    "permissions": ["history:all", "history:own", "incident:report", "item:bulk_lookup", "item:lookup", "retail_user:add"],
    "organisation": "Ziska Pharma",
    "support": { "email": "help@ziska.example", "phone": "+91 80 0000 0000" },
    "must_change_password": false
  }
}
```
**Check:** the Retail users tile; History offers **everyone's checks** with officials' names.

### 2. Field inspector (the original mock profile)
```json
{
  "success": true,
  "message": "Profile fetched successfully.",
  "data": {
    "id": "5b1c8e2d-6f4a-4c3b-9e1d-7a2b3c4d5e6f",
    "name": "Asha Rao",
    "email": "official@example.com",
    "role": "Field inspector",
    "permissions": ["history:own", "incident:report", "item:bulk_lookup", "item:lookup"],
    "organisation": "Ziska Pharma",
    "support": { "email": "help@ziska.example", "phone": "+91 80 0000 0000" },
    "must_change_password": false
  }
}
```
**Check:** no Retail users tile; History shows **own checks only**.

### 3. Head office auditor
```json
{
  "success": true,
  "message": "Profile fetched successfully.",
  "data": {
    "id": "5b1c8e2d-6f4a-4c3b-9e1d-7a2b3c4d5e03",
    "name": "Nusrat Auditor",
    "email": "auditor@example.com",
    "role": "Head office auditor",
    "permissions": ["history:all", "history:own", "item:lookup"],
    "organisation": "Ziska Pharma",
    "support": { "email": "help@ziska.example", "phone": "+91 80 0000 0000" },
    "must_change_password": false
  }
}
```
**Check:** no MORE tiles; History has **everyone's checks**; no **Report** button on a lookup result.

### 4. Senior seller
```json
{
  "success": true,
  "message": "Profile fetched successfully.",
  "data": {
    "id": "5b1c8e2d-6f4a-4c3b-9e1d-7a2b3c4d5e04",
    "name": "Hasan Pharmacy",
    "email": "hasan.pharmacy@example.com",
    "role": "Senior seller",
    "permissions": ["history:own", "item:bulk_lookup", "item:lookup"],
    "organisation": "Ziska Pharma",
    "support": { "email": "help@ziska.example", "phone": "+91 80 0000 0000" },
    "must_change_password": false
  }
}
```
**Check:** only the **Bulk lookup** tile; a **History tab with own checks only** (no "Everyone's checks" in Filters, no officials' names on the rows).

### 5. Retail seller
```json
{
  "success": true,
  "message": "Profile fetched successfully.",
  "data": {
    "id": "5b1c8e2d-6f4a-4c3b-9e1d-7a2b3c4d5e05",
    "name": "Rahim Store",
    "email": "rahim.store@example.com",
    "role": "Retail seller",
    "permissions": ["history:own", "item:lookup"],
    "organisation": "Ziska Pharma",
    "support": { "email": "help@ziska.example", "phone": "+91 80 0000 0000" },
    "must_change_password": false
  }
}
```
**Check:** lookup form and Scan QR only; **no MORE section**; a **History tab with own checks only** (no "Everyone's checks", no officials' names). `history:own` is what the portal ticks by default for a retail role (backend D53).

### 6. Incident reporter (edge case: can report but not look up)
```json
{
  "success": true,
  "message": "Profile fetched successfully.",
  "data": {
    "id": "5b1c8e2d-6f4a-4c3b-9e1d-7a2b3c4d5e06",
    "name": "Field Reporter",
    "email": "reporter@example.com",
    "role": "Incident reporter",
    "permissions": ["incident:report"],
    "organisation": "Ziska Pharma",
    "support": { "email": "help@ziska.example", "phone": "+91 80 0000 0000" },
    "must_change_password": false
  }
}
```
**Check:** **no lookup form** (this role can't look items up), but **Report incident** and **My reports** are available, and the retail-user picker works inside a report. This is unusual, so see whether the screen still makes sense.

### 7. Trainee
```json
{
  "success": true,
  "message": "Profile fetched successfully.",
  "data": {
    "id": "5b1c8e2d-6f4a-4c3b-9e1d-7a2b3c4d5e07",
    "name": "New Trainee",
    "email": "trainee@example.com",
    "role": "Trainee",
    "permissions": [],
    "organisation": "Ziska Pharma",
    "support": { "email": "help@ziska.example", "phone": "+91 80 0000 0000" },
    "must_change_password": false
  }
}
```
**Check:** tabs Verify and Profile only; "No features yet" on the Verify tab.

### 8. Retail seller, history turned off (edge case)
The client's admin may untick `history:own` for a retail role.
```json
{
  "success": true,
  "message": "Profile fetched successfully.",
  "data": {
    "id": "5b1c8e2d-6f4a-4c3b-9e1d-7a2b3c4d5e09",
    "name": "Karim Store",
    "email": "karim.store@example.com",
    "role": "Retail seller (no history)",
    "permissions": ["item:lookup"],
    "organisation": "Ziska Pharma",
    "support": { "email": "help@ziska.example", "phone": "+91 80 0000 0000" },
    "must_change_password": false
  }
}
```
**Check:** lookup form and Scan QR only; **no History tab**. Nothing is kept on the phone either.
