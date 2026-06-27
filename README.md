# AI Study Buddy 🎓

An AI-powered Android study assistant app built with Flutter and Spring Boot.

## Features
- 🤖 AI doubt solver powered by Groq (Llama 3.3)
- 📝 Automatic quiz and flashcard generator
- ⏱️ Pomodoro timer with session tracking
- 📊 Analytics dashboard and study streaks
- 📅 Daily study planner
- 🔐 JWT authentication with Spring Security

## Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Spring Boot (Java)
- **Database:** PostgreSQL (Neon Cloud)
- **AI:** Groq API (Llama 3.3 70B)
- **Auth:** JWT + Spring Security + BCrypt

## Project Structure
- `/frontend` - Flutter Android app
- `/backend` - Spring Boot REST API

## Setup
### Backend
1. Clone the repo
2. Add your credentials to `application.properties`
3. Run with IntelliJ IDEA

### Frontend
1. Run `flutter pub get`
2. Update API URL in each screen
3. Run with `flutter run`