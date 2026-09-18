# Architecture Rules

- Keep Flutter UI separate from ViewModels, repositories, data sources, and
  domain calculations.
- Keep Drift APIs in the data layer; expose domain models through repository
  interfaces.
- Keep astronomical and astrophotography calculations independent from Flutter
  widgets.
- Keep platform-specific code behind interfaces/adapters.
- Use Provider/ViewModels unless a documented architectural decision approves a
  different approach.
