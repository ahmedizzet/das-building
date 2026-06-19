# NoSQL Database Schema (Isar)

This document outlines the database schema for the Civic Hearth application using the [Isar](https://isar.dev/) database.

## Collections

### 1. Expense
Stores building financial expenditures.
- `Id id`: Isar auto-increment ID.
- `String? remoteId`: Unique identifier from the backend.
- `String title`: Description of the expense (e.g., "Elevator Repair").
- `DateTime date`: Date the expense was recorded.
- `String category`: Category tag (e.g., "Maintenance", "Utilities").
- `double amount`: Negative value representing the cost.

### 2. Ticket
Stores maintenance service requests.
- `Id id`: Isar auto-increment ID.
- `String title`: Brief summary of the issue.
- `String description`: Detailed explanation.
- `DateTime date`: When the ticket was created.
- `String category`: (e.g., "Plumbing", "Electrical").
- `byte status`: Enum value (0: Pending, 1: In Progress, 2: Resolved).
- `String? residentId`: Reference to the member who created it.

### 3. Member
Stores resident information and financial status.
- `Id id`: Isar auto-increment ID.
- `String name`: Resident's full name.
- `String unit`: Apartment number/address (e.g., "Apt 402").
- `double balance`: Current outstanding dues.
- `byte status`: Enum value (0: Paid, 1: Unpaid, 2: Late).
- `String imageUrl`: URL to the profile picture.
- `String phoneNumber`: Resident's contact number (unique index).

### 4. Amenity
Stores bookable facilities in the building.
- `Id id`: Isar auto-increment ID.
- `String title`: Name of the amenity (e.g., "Gym", "Pool").
- `String imageUrl`: Display image URL.
- `String? policy`: Specific rules for this amenity.

### 5. Booking
Stores reservations made by residents.
- `Id id`: Isar auto-increment ID.
- `int amenityId`: Reference to the Amenity collection.
- `DateTime date`: The day reserved.
- `String timeSlot`: The specific time range (e.g., "12:00 PM - 01:00 PM").
- `String? residentId`: Reference to the member who booked.

### 6. Announcement
Stores official notices from property management.
- `Id id`: Isar auto-increment ID.
- `String title`: Headline of the notice.
- `String content`: Full body text.
- `String author`: Name of the manager or entity (e.g., "Property Management").
- `DateTime date`: Publication date.
- `bool isPinned`: Whether it stays at the top of the feed.

### 7. Event
Stores community-led or official social gatherings.
- `Id id`: Isar auto-increment ID.
- `String title`: Name of the event.
- `String category`: (e.g., "Social", "Lifestyle").
- `DateTime time`: When the event takes place.
- `String imageUrl`: Promotional image URL.

### 8. GroupMember
Stores residents specifically added to the building group for billing and management.
- `Id id`: Isar auto-increment ID.
- `String serverId`: Unique identifier for sync.
- `String memberId`: Reference to the core Member record.
- `double monthlyFee`: Amount assigned for recurring payments.
- `DateTime updatedAt`: Track changes for sync.

## Enums Mapping

### TicketStatus
- `0`: `pending`
- `1`: `inProgress`
- `2`: `resolved`

### PaymentStatus
- `0`: `paid`
- `1`: `unpaid`
- `2`: `late`

## Relationships & Indices
- **Member.phoneNumber**: Unique index for login lookups.
- **Booking.amenityId**: Linked via Isar `Link<Amenity>` or simple `int` ID.
- **Expense.date**: Indexed for chronological sorting in Dashboard.
- **Announcement.isPinned**: Indexed to quickly fetch pinned items.
