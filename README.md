### Summary:
This iOS app fetches and displays a list of recipes from an API, allowing users to explore different dishes. The app is built using Domain-Driven Design (DDD) and Clean Architecture to ensure maintainability and scalability.

![Video](/screenshots/video.gif)
![Recipes](/screenshots/recipes.jpeg)
![Recipes Dark](/screenshots/recipes_dark.jpeg)
![Sorting](/screenshots/sorting.jpeg)
![Empty Recipes](/screenshots/empty_recipes.jpeg)
![No Internet Connection](/screenshots/no_internet_connection.jpeg)
![Error](/screenshots/error.jpeg)

### Focus Areas:
I prioritized the following areas in the project:
- Architecture (DDD & Clean Architecture) – Ensuring a modular and scalable codebase.
- Unit Testing – Writing tests for core business logic to improve reliability.
- Separation of Concerns – Keeping UI, business logic, and data layers independent for better maintainability.

The focus on architecture and testing was crucial to create a robust and maintainable application that can be extended in the future without significant refactoring.

### Time Spent:
I spent approximately 8 hours on this project.

### Trade-offs and Decisions: Did you make any significant trade-offs in your approach?
- Chose Clean Architecture over a simpler approach to improve long-term maintainability, even though it required additional setup.
- Limited UI enhancements in favor of focusing on architecture and testing.
- Set iOS 16 as the minimum supported version to align with company policy, trading broader compatibility for access to modern APIs.

### Weakest Part of the Project: What do you think is the weakest part of your project?
- The UI is currently minimal and could be improved with more engaging visuals and interactions.
- Caching is functional but basic; ideally, it should be replaced with a more robust solution.
- Lack of persistent storage – Storing recipe data locally would improve offline usability.