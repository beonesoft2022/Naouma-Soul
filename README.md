1. Business Document for the Gift Task

Feature: In-Room Gifting

Purpose:

Enhance user engagement within chat rooms.
Foster a sense of community and interaction.
Provide an avenue for users to express appreciation or celebration.
Potentially create an additional revenue stream through the sale of gifts.
Description:

Gift Shop/Selection: Users access a dedicated gift screen with a variety of visually appealing gift options (likely animated GIFs).
Purchase: Users can purchase gifts using in-app currency or real-world transactions.
Sending: Users select a recipient within the chat room and send the chosen gift.
Real-time Display: The gift animation displays prominently within the room chat interface for all users present in the room.
Backend Record: Gift transactions are recorded on the backend for tracking, analytics, and potentially preventing abuse.
Technical Dependencies:

Backend API: Handles gift purchase transactions and stores gift data.
Firebase Realtime Database: Facilitates real-time updates for gift display.
Flutter UI: Gift shop screen, sending mechanism, and gift animation display.
2. Project Summary

The core task involves enabling real-time display of gifts within a room-based chat application. This includes:

Backend Integration: An API endpoint handles gift purchase transactions.
Firebase Event Triggering (Flutter): After a successful purchase, the Flutter app triggers an event in the Firebase Realtime Database, including gift details and room ID.
Firebase Subscription (Flutter): The Flutter app subscribes to the relevant Firebase event for the specific room.
Gift Retrieval & Display (Flutter): Upon event trigger, Flutter retrieves the gift data and displays an animation within the chat room UI.
