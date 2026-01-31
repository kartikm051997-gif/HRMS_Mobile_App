# Backend API Requirements: Inactive Users List with Pagination

## Overview
The mobile app needs an API endpoint for inactive users that supports **server-side pagination** to handle ~12,000 records efficiently. Currently, the app is trying to load all records at once, causing performance issues.

## Required API Endpoint

**Endpoint:** `GET /api/get_inactive_users` (or similar)

**Base URL:** Same as active users API

## Required Query Parameters

The API should accept the following query parameters (same as `get_active_users`):

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `cmpid` | string | No | Company ID filter |
| `zone_id` | string | No | Zone ID filter (comma-separated for multiple) |
| `locations_id` | string | No | Location IDs (comma-separated) |
| `designations_id` | string | No | Designation IDs (comma-separated) |
| `ctc_range` | string | No | CTC range filter (1-6) |
| `punch` | string | No | Punch status filter |
| `dolp_fromdate` | string | No | Date of last punch - from date |
| `dolp_todate` | string | No | Date of last punch - to date |
| `fromdate` | string | No | Date of joining - from date |
| `todate` | string | No | Date of joining - to date |
| `page` | int | **YES** | Page number (default: 1) |
| `per_page` | int | **YES** | Records per page (default: 10) |
| `search` | string | No | Search query (name, ID, etc.) |

## Required Response Format

The API should return a JSON response in the following format:

```json
{
  "status": "success",
  "message": "Inactive users retrieved successfully",
  "data": {
    "users": [
      {
        "user_id": "123",
        "employment_id": "ECI001",
        "username": "12745",
        "fullname": "John Doe",
        "mobile": "9876543210",
        "email": "john@example.com",
        "avatar": "/uploads/avatars/123.jpg",
        "location_name": "Chennai",
        "zone_id": "1",
        "designation": "Software Engineer",
        "department": "IT",
        "joining_date": "01/01/2020",
        "relieving_date": "31/12/2023",
        "role": "Employee",
        "status": "Inactive"
      }
    ],
    "pagination": {
      "total": 12000,
      "per_page": 10,
      "current_page": 1,
      "last_page": 1200,
      "from": 1,
      "to": 10
    }
  }
}
```

## Key Requirements

### 1. **Pagination is MANDATORY**
   - The API **MUST** implement server-side pagination
   - Default: `page=1`, `per_page=10`
   - Return only the requested page of records (e.g., if `page=1` and `per_page=10`, return only 10 records)
   - Include pagination metadata in response

### 2. **Filter Logic**
   - Filter inactive users: `tbl_users.activated = 0` (or `activated != 1`)
   - Apply all filters BEFORE pagination
   - Count total records AFTER filters but BEFORE pagination

### 3. **SQL Query Structure** (Reference from `get_active_users`)

```php
// Example structure (adapt for inactive users)
$this->db->select('...');
$this->db->from('tbl_users');
$this->db->join('tbl_account_details', '...', 'left');
$this->db->join('tbl_designations', '...', 'left');
$this->db->join('tbl_departments', '...', 'left');
$this->db->join('tbl_locations', '...', 'left');

// ✅ CRITICAL: Filter inactive users
$this->db->where('tbl_users.activated', 0); // or activated != 1

// Apply filters (zone, location, designation, etc.)
// ... filter logic ...

// ✅ CRITICAL: Get total count BEFORE pagination
$total_query = clone $this->db;
$total_count = $total_query->count_all_results();

// ✅ CRITICAL: Apply pagination
$page = $this->input->get_post('page') ?: 1;
$per_page = $this->input->get_post('per_page') ?: 10;
$offset = ($page - 1) * $per_page;

$this->db->limit($per_page, $offset);
$this->db->order_by('tbl_account_details.employment_id', 'ASC');

$query = $this->db->get();
$users_data = $query->result();

// Calculate pagination metadata
$total_pages = ceil($total_count / $per_page);
```

### 4. **Response Pagination Object**

```php
'pagination' => [
    'total' => (int)$total_count,           // Total records after filters
    'per_page' => (int)$per_page,           // Records per page
    'current_page' => (int)$page,           // Current page number
    'last_page' => (int)$total_pages,       // Total pages
    'from' => $offset + 1,                  // First record number on this page
    'to' => min($offset + $per_page, $total_count) // Last record number on this page
]
```

## Example Implementation

Based on your `get_active_users()` function, here's the structure for inactive users:

```php
public function get_inactive_users() {
    // Step 1: Verify Token
    $user = $this->api_auth->verify_token();
    if (!$user) {
        $this->send_response([
            'status' => 'error',
            'message' => 'Unauthorized - Invalid or expired token'
        ], 401);
        return;
    }
    
    // Step 2: Load model
    $this->load->model('user_model');
    
    // Step 3: Get filter parameters
    $cmpid = $this->input->get_post('cmpid') ?: '';
    $designations_id = $this->input->get_post('designations_id') ?: '';
    $locations_id = $this->input->get_post('locations_id') ?: '';
    $zone_id = $this->input->get_post('zone_id') ?: '';
    $fromdate = $this->input->get_post('fromdate') ?: '';
    $todate = $this->input->get_post('todate') ?: '';
    $ctcRange = $this->input->get_post('ctc_range') ?: '';
    $punch = $this->input->get_post('punch') ?: '';
    $dolp_fromdate = $this->input->get_post('dolp_fromdate') ?: '';
    $dolp_todate = $this->input->get_post('dolp_todate') ?: '';
    
    // ✅ CRITICAL: Pagination parameters
    $page = $this->input->get_post('page') ?: 1;
    $per_page = $this->input->get_post('per_page') ?: 10;
    $offset = ($page - 1) * $per_page;
    
    // Step 4: Build query
    $this->db->select('
        tbl_users.username,
        tbl_users.user_id,
        tbl_users.activated,
        tbl_users.relieving_date,
        tbl_account_details.*,
        tbl_locations.name as location_name,
        tbl_locations.zone_id,
        tbl_designations.designations,
        tbl_departments.deptname
    ');
    
    $this->db->from('tbl_users');
    $this->db->join('tbl_account_details', 'tbl_users.user_id = tbl_account_details.user_id', 'left');
    $this->db->join('tbl_designations', 'tbl_designations.designations_id = tbl_account_details.designations_id', 'left');
    $this->db->join('tbl_departments', 'tbl_departments.departments_id = tbl_designations.departments_id', 'left');
    $this->db->join('tbl_locations', 'tbl_locations.id = tbl_account_details.location', 'left');
    
    // ✅ CRITICAL: Filter inactive users
    $this->db->where('tbl_users.activated', 0); // Inactive users
    
    // Apply filters (same as active users)
    if (!empty($cmpid)) {
        $this->db->where('tbl_users.cmpid', $cmpid);
    }
    
    if (!empty($zone_id)) {
        $zoneArr = explode(',', $zone_id);
        $this->db->where_in('tbl_locations.zone_id', $zoneArr);
    }
    
    if (!empty($locations_id)) {
        $locationArr = explode(',', $locations_id);
        $this->db->where_in('tbl_account_details.location', $locationArr);
    }
    
    if (!empty($designations_id)) {
        $designationsArr = explode(',', $designations_id);
        $this->db->where_in('tbl_account_details.designations_id', $designationsArr);
    }
    
    // DOJ Filter
    if (!empty($fromdate) && !empty($todate)) {
        $from_formatted = date('Y-m-d', strtotime($fromdate));
        $to_formatted = date('Y-m-d', strtotime($todate));
        $this->db->where('tbl_account_details.joining_date >=', $from_formatted);
        $this->db->where('tbl_account_details.joining_date <=', $to_formatted);
    }
    
    // Search filter
    if (!empty($search)) {
        $this->db->group_start();
        $this->db->like('tbl_account_details.fullname', $search);
        $this->db->or_like('tbl_account_details.employment_id', $search);
        $this->db->or_like('tbl_account_details.mobile', $search);
        $this->db->group_end();
    }
    
    // ✅ CRITICAL: Get total count BEFORE pagination
    $total_query = clone $this->db;
    $total_count = $total_query->count_all_results();
    
    // ✅ CRITICAL: Apply pagination
    $this->db->order_by('tbl_account_details.employment_id', 'ASC');
    $this->db->limit($per_page, $offset);
    
    // Execute query
    $query = $this->db->get();
    $users_data = $query->result();
    
    // Step 5: Format data
    $users = [];
    foreach ($users_data as $user) {
        // Get recruiter and creator info (if needed)
        $recruiter = $this->getRecruiterDetail($user->mobile);
        $creater = $this->getCreaterDetail($user->employment_id);
        
        // Determine role
        $role = '-';
        if ($user->employee_category_type == "employee") {
            $role = "Employee";
        } elseif ($user->employee_category_type == "professional") {
            $role = "Professional";
        } elseif ($user->employee_category_type == "student") {
            $role = "Student";
        } elseif ($user->employee_category_type == "employeef11") {
            $role = "Employee F11";
        }
        
        $users[] = [
            'user_id' => $user->user_id,
            'employment_id' => $user->employment_id ?? '',
            'username' => $user->username,
            'fullname' => $user->fullname ?? '',
            'mobile' => $user->mobile ?? '',
            'email' => $user->email ?? '',
            'avatar' => !empty($user->avatar) ? base_url() . $user->avatar : '',
            'location_name' => $user->location_name ?? '',
            'zone_id' => $user->zone_id ?? '',
            'designation' => $user->designations ?? '',
            'department' => $user->deptname ?? '',
            'joining_date' => !empty($user->joining_date) ? date('d/m/Y', strtotime($user->joining_date)) : '',
            'relieving_date' => !empty($user->relieving_date) ? date('d/m/Y', strtotime($user->relieving_date)) : '',
            'role' => $role,
            'status' => 'Inactive',
            'recruiter' => $recruiter ? [
                'user_id' => $recruiter->user_id,
                'fullname' => $recruiter->fullname ?? '',
                'avatar' => !empty($recruiter->avatar) ? base_url() . $recruiter->avatar : ''
            ] : null,
            'created_by' => $creater ? [
                'user_id' => $creater->user_id,
                'fullname' => $creater->fullname ?? '',
                'avatar' => !empty($creater->avatar) ? base_url() . $creater->avatar : ''
            ] : null,
        ];
    }
    
    // ✅ CRITICAL: Calculate pagination metadata
    $total_pages = ceil($total_count / $per_page);
    
    // Step 6: Send response
    $this->send_response([
        'status' => 'success',
        'message' => 'Inactive users retrieved successfully',
        'data' => [
            'users' => $users,
            'pagination' => [
                'total' => (int)$total_count,
                'per_page' => (int)$per_page,
                'current_page' => (int)$page,
                'last_page' => (int)$total_pages,
                'from' => $offset + 1,
                'to' => min($offset + $per_page, $total_count)
            ]
        ]
    ], 200);
}
```

## Testing Checklist

- [ ] API returns only 10 records when `page=1&per_page=10`
- [ ] API returns correct pagination metadata
- [ ] API handles filters correctly (zone, location, designation, etc.)
- [ ] API handles search query correctly
- [ ] API returns empty array when no results found
- [ ] API handles invalid page numbers gracefully
- [ ] API performance is acceptable (should be fast with pagination)

## Notes

1. **Performance**: With pagination, the API should return results quickly even with 12,000+ inactive users
2. **Default Behavior**: If `page` or `per_page` not provided, default to `page=1, per_page=10`
3. **Error Handling**: Return appropriate error messages for invalid requests
4. **Token Validation**: Ensure token validation is implemented (same as active users API)

## Mobile App Changes Made

The mobile app has been updated to:
- Request only 10 records per page by default
- Use server-side pagination instead of client-side
- Fetch new page data when user navigates pages
- Display pagination controls based on server response

**The mobile app is ready - it just needs the backend API to be implemented with pagination support.**
