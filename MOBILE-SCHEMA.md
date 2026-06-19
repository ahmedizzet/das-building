# MOBILE-SCHEMA.md

This document defines the complete multi-tenant database schema architecture for Civic Hearth. It establishes a strict mapping between the self-hosted MongoDB Community Edition server and the local offline-first Isar client database.

---

## 1. Global Architecture Constraints

### Tenant Isolation
Every document on the MongoDB server **must** contain a `tenantId` field linking it to a specific building/compound partition. The mobile client application must strictly validate this identifier to ensure data isolation.

### Offline ID Allocation
To prevent primary key collisions and maintain offline functional independence, all collection identifiers (`_id` or `serverId`) **must** be assigned on the client device upon instantiation using a cryptographically secure UUIDv4 or standard 12-byte BSON ObjectId hex string representation.

### Hard Delete Restraints
No delete operations are to execute as hard SQL/NoSQL deletions locally on the client while offline. Deletions use a soft state flag (`isDeleted` / `deletedAt`) to act as data mutation markers during synchronization iterations.


---

## 2. Local Client-Side Database Schemas (Isar)

Every Dart class features tracking indexes (`isSynced`, `isDeleted`, `updatedAt`) to coordinate delta cycles with the remote synchronization API layer.

### Expense Schema (`expense.dart`)
```dart
import 'package:isar/isar.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String tenantId;

  late String title;
  late double amount;
  
  @Index()
  late DateTime date;
  late String category;

  @Index()
  late DateTime updatedAt;
  @Index()
  late bool isSynced;
  late bool isDeleted;
}
```

### Ticket Schema (`ticket.dart`)
```dart
import 'package:isar/isar.dart';

part 'ticket.g.dart';

@collection
class Ticket {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String tenantId;

  late String title;
  late String description;
  late DateTime date;
  late String category;
  
  @Index()
  late int status; // 0: Pending, 1: In Progress, 2: Resolved
  
  String? residentId;

  @Index()
  late DateTime updatedAt;
  @Index()
  late bool isSynced;
  late bool isDeleted;
}
```

### Member Schema (`member.dart`)
```dart
import 'package:isar/isar.dart';

part 'member.g.dart';

@collection
class Member {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String tenantId;

  late String name;
  late String unit;
  late double balance;
  late int status; // 0: Paid, 1: Unpaid, 2: Late
  late String imageUrl;

  @Index()
  late String phoneNumber;

  @Index()
  late DateTime updatedAt;
  @Index()
  late bool isSynced;
  late bool isDeleted;
}
```

### Amenity Schema (`amenity.dart`)
```dart
import 'package:isar/isar.dart';

part 'amenity.g.dart';

@collection
class Amenity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String tenantId;

  late String title;
  late String imageUrl;
  String? policy;

  @Index()
  late DateTime updatedAt;
  @Index()
  late bool isSynced;
  late bool isDeleted;
}
```

### Booking Schema (`booking.dart`)
```dart
import 'package:isar/isar.dart';

part 'booking.g.dart';

@collection
class Booking {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String tenantId;

  late String amenityId;
  late String residentId;
  
  late DateTime date;
  late String timeSlot;

  @Index()
  late DateTime updatedAt;
  @Index()
  late bool isSynced;
  late bool isDeleted;
}
```

### Announcement Schema (`announcement.dart`)
```dart
import 'package:isar/isar.dart';

part 'announcement.g.dart';

@collection
class Announcement {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String serverId;

  @Index()
  late String tenantId;

  late String title;
  late String content;
  late String author;
  late DateTime date;

  @Index()
  late bool isPinned;
  
  String? category; 
  String? imageUrl;

  @Index()
  late DateTime updatedAt;
  @Index()
  late bool isSynced;
  late bool isDeleted;
}
```

---


