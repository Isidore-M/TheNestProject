
![image alt](https://github.com/Isidore-M/TheNestProject/blob/6f11cc797ac4b8b00da35714fab3f78288f3d42d/Read-me-banner.jpg)

<p align="center">
  <img src="https://img.shields.io/badge/SwiftUI-F05138?style=flat-square&logo=swift&logoColor=white" alt="SwiftUI" />
  
  <img src="https://img.shields.io/badge/Firebase-f5b041?style=flat-square&logo=firebase&logoColor=white" alt="Firebase" />
  
  <img src="https://img.shields.io/badge/iOS-18.5%2B-000000?style=flat-square&logo=apple&logoColor=white" alt="iOS 18.5+" />
  
  <img src="https://img.shields.io/badge/visionOS-2.5-000000?style=flat-square&logo=apple&logoColor=white" alt="visionOS 2.5" />
</p>





---------------------------------------------------------------------------------------------------------
**The Nest**

Where ideas find their colony.
The Nest is a minimal, collaborative hub built for the modern creator. 
It’s designed to bridge the gap between "I have an idea" and "We built a team." 
No noise, just high-signal collaboration for designers and developers.

---------------------------------------------------------------------------------------------------------
**Design Philosophy**
---------------------------------------------------------------------------------------------------------

**Typography:**

We chose Poppins for its geometric clarity and friendly character. It provides a modern, approachable feel that remains legible across mobile and spatial interfaces.

**The Palette:**

A breathable off-white canvas (#F5F5F5) paired with high-contrast blacks (#121212) and a signature purple accent (#735D9D). This creates a "premium" feel without the clutter of heavy gradients or shadows.

Tactile Feedback: Every interaction is optimized for iOS 18.5 haptics. Buttons feel "pressable," and transitions guide the eye through the project's logical flow.
---------------------------------------------------------------------------------------------------------
** Built With**
---------------------------------------------------------------------------------------------------------

SwiftUI: Declarative UI for a fluid, reactive experience.
Firebase: Real-time data sync for a "zero-latency" feel.
Atomic Sync: Custom batch logic to handle team admissions and notifications in a single heartbeat.

---------------------------------------------------------------------------------------------------------
**Installation & Setup**
---------------------------------------------------------------------------------------------------------

-Clone the repository: **git clone https://github.com/Isidore-M/TheNestProject.git**

-Open TheNest.xcodeproj in Xcode 16.0+.

-Add your GoogleService-Info.plist to the project root.

-Build and run on an iOS 18.5 or visionOS 2.5 simulator.
---------------------------------------------------------------------------------------------------------
**The Experience**
---------------------------------------------------------------------------------------------------------

01. Discovery
---------------------------------------------------------------------------------------------------------
Browse a curated feed of project cards. See who's leading, what they're building, and who’s already in the colony.
---------------------------------------------------------------------------------------------------------
02. Collaborative Profiles
---------------------------------------------------------------------------------------------------------

Traditional resumes are boring. The Nest uses skill-based profiles that highlight your interests and portfolio links, 
making it easy to find your perfect creative match.

![image alt](https://github.com/Isidore-M/TheNestProject/blob/c72ec42867ccb3be17ffbd2efc7f1fdcde5aee6c/profile1.jpg)

---------------------------------------------------------------------------------------------------------
03. Seamless Onboarding
---------------------------------------------------------------------------------------------------------
A frictionless, multi-step flow that gets you from "Sign Up" to "Exploring" in under 60 seconds.

![image alt](https://github.com/Isidore-M/TheNestProject/blob/c72ec42867ccb3be17ffbd2efc7f1fdcde5aee6c/onboarding-frames.jpg)

---------------------------------------------------------------------------------------------------------
04. Post creation
---------------------------------------------------------------------------------------------------------
In The Nest, every project begins with a focused entry point. The Post Creation flow is designed to be frictionless, 
allowing creators to define their vision with a title, detailed description, and specific role requirements.
Upon submission, the project is instantly pushed to the Discovery Feed via a Firestore real-time sync. 
It is initialized with a timestamp, authorId, and a memberNames map that automatically includes the creator as the first member of the colony.

![image alt](https://github.com/Isidore-M/TheNestProject/blob/c72ec42867ccb3be17ffbd2efc7f1fdcde5aee6c/post-creation.jpg)

---------------------------------------------------------------------------------------------------------
05. Notification management
---------------------------------------------------------------------------------------------------------

Notification management in The Nest is more than just a list of alerts; it’s a gatekeeper for high-signal collaboration. 

When a user requests to join a project, the leader receives a Collaboration Request notification.

**-The Experience:**

Leaders can tap a notification to open a Profile Preview, viewing the candidate's bio, skills, and portfolio without leaving the activity center.

**The Logic:**

We utilize Atomic Batching for the acceptance flow.the user is added to the project roster, their name is mapped , 
and the notification is deleted to maintain a "Zero-Inbox" workspace.

![image alt](https://github.com/Isidore-M/TheNestProject/blob/c72ec42867ccb3be17ffbd2efc7f1fdcde5aee6c/notification.jpg)

---------------------------------------------------------------------------------------------------------
06. Teams management
---------------------------------------------------------------------------------------------------------

Once a team is formed, the Teams Management module provides a bird’s-eye view of the project's current collaborators. 
This is the "Engine Room" of the project where the leader manages his team.

**The Experience:**

A minimal list view displaying every member currently "In the Nest." 
project's Leaders have the power to remove collaborators or add new ones on the fly via the Team Selection Sheet.

**The Logic:**

To ensure the UI remains  smooth, we rely on a dual-data structure: an members array for fast queries and a memberNames dictionary for name display. 
This avoids expensive "N+1" network calls to fetch every individual profile, keeping the app lightweight even as the colony grows.

![image alt](https://github.com/Isidore-M/TheNestProject/blob/c72ec42867ccb3be17ffbd2efc7f1fdcde5aee6c/team-management.jpg)


**The Logic**

The app is engineered for data integrity. The TeamManager ensures that when you accept a collaborator,
the database updates are atomic—meaning your project list and notification center stay perfectly in sync, every time.

---------------------------------------------------------------------------------------------------------
**Growth Plan**
---------------------------------------------------------------------------------------------------------

**Phase 1: Foundation (Current)**


Real-time Auth: Firebase-backed secure entry.
Profile Intelligence: Dynamic onboarding and skill-tagging.
Atomic Management: Batch-processed team admissions.

**Phase 2: Communication (Upcoming)**

Nest Chat: End-to-end encrypted messaging for project teams.
Live Presence: See who's currently "In the Nest" working on your project.
Push 2.0: Interactive notifications allowing leaders to accept members directly from the Lock Screen.

**Phase 3: Ecosystem (Future)**

Spatial Nest (visionOS): A dedicated environment for immersive project planning.
Portfolio API: One-click sync with Behance, GitHub, and Dribbble.
Colony Analytics: Track your project's growth and engagement trends.
Stripe Integration: Handle freelance milestone payments directly within the project team.

---------------------------------------------------------------------------------------------------------
**Contact**
---------------------------------------------------------------------------------------------------------
[Isidore Manga] – Freelance UI/UX Designer & iOS Developer Portfolio: [www.isidoremanga.com] | 
