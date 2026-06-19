# SERVER-SCHEMA.md

This document defines the complete multi-tenant database schema architecture for Civic Hearth. It establishes a strict mapping between the self-hosted MongoDB Community Edition server and the local offline-first Isar client database.

---

## 1. Global Architecture Constraints

### Tenant Isolation
Every document on the MongoDB server **must** contain a `tenantId` field linking it to a specific building/compound partition. The mobile client application must strictly validate this identifier to ensure data isolation.

### Offline ID Allocation
To prevent primary key collisions and maintain offline functional independence, all collection identifiers (`_id` or `serverId`) **must** be assigned on the client device upon instantiation using a cryptographically secure UUIDv4 or standard 12-byte BSON ObjectId hex string representation.

### Hard Delete Restraints
No delete operations are to execute as hard SQL/NoSQL deletions locally on the client while offline. Deletions use a soft state flag (`isDeleted` / `deletedAt`) to act as data mutation markers during synchronization iterations.


## 2. Server-Side Schemas (MongoDB / Mongoose)

### Tenants Collection (`tenants`)
Tracks separate administrative building partitions.
```json
{
  "_id": "ObjectId",
  "name": "String",
  "slug": "String",
  "createdAt": "Date"
}
```

### Expenses Collection (`expenses`)
```json
{
  "_id": "String",
  "tenantId": "ObjectId",
  "title": "String",
  "category": "String",
  "amount": "Number",
  "date": "Date",
  "createdAt": "Date",
  "updatedAt": "Date",
  "deletedAt": "Date"
}
```

### Tickets Collection (`tickets`)
```json
{
  "_id": "String",
  "tenantId": "ObjectId",
  "residentId": "String",
  "title": "String",
  "description": "String",
  "category": "String",
  "status": "Number",
  "date": "Date",
  "createdAt": "Date",
  "updatedAt": "Date",
  "deletedAt": "Date"
}
```

### Members Collection (`members`)
```json
{
  "_id": "String",
  "tenantId": "ObjectId",
  "name": "String",
  "unit": "String",
  "balance": "Number",
  "status": "Number",
  "imageUrl": "String",
  "phoneNumber": "String",
  "createdAt": "Date",
  "updatedAt": "Date",
  "deletedAt": "Date"
}
```

### Amenities Collection (`amenities`)
```json
{
  "_id": "String",
  "tenantId": "ObjectId",
  "title": "String",
  "imageUrl": "String",
  "policy": "String",
  "createdAt": "Date",
  "updatedAt": "Date",
  "deletedAt": "Date"
}
```

### Bookings Collection (`bookings`)
```json
{
  "_id": "String",
  "tenantId": "ObjectId",
  "amenityId": "String",
  "residentId": "String",
  "date": "Date",
  "timeSlot": "String",
  "createdAt": "Date",
  "updatedAt": "Date",
  "deletedAt": "Date"
}
```

### Announcements Collection (`announcements`)
Handles official announcements and community events.
```json
{
  "_id": "String",
  "tenantId": "ObjectId",
  "title": "String",
  "content": "String",
  "author": "String",
  "isPinned": "Boolean",
  "category": "String",
  "imageUrl": "String",
  "date": "Date",
  "createdAt": "Date",
  "updatedAt": "Date",
  "deletedAt": "Date"
}
```

### Messages Collection (`messages`) 
```json
{
"_id": "String",
"tenantId": "ObjectId",
"conversationId": "String",    
"senderId": "String",         
"content": "String",
"type": "String",              
"readBy": ["String"],          
"createdAt": "Date",
"updatedAt": "Date",
"deletedAt": "Date"
}
```
### Transaction
```json
{
"_id": "String",
"tenantId": "ObjectId",
"memberId": "String",         
"amount": "Number",
"type": "String",              
"description": "String",
"date": "Date",               
"createdAt": "Date",
"updatedAt": "Date",
"deletedAt": "Date"
}
```


## 3. Server Index Management Commands
To keep the multi-tenant system performant under heavy usage, apply these compound and unique indices directly to your MongoDB collections via the Mongo Shell:

```javascript
db.expenses.createIndex({ "tenantId": 1, "updatedAt": 1 });
db.tickets.createIndex({ "tenantId": 1, "status": 1 });
db.bookings.createIndex({ "tenantId": 1, "date": 1, "amenityId": 1 });
db.members.createIndex({ "tenantId": 1, "phoneNumber": 1 }, { unique: true });
db.announcements.createIndex({ "tenantId": 1, "isPinned": -1, "date": -1 });
```
