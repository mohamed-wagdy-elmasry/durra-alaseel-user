---
name: flutter-design-workflow
description: Describe what this custom agent does and when to use it.
argument-hint: The inputs this agent expects, e.g., "a task to implement" or "a question to answer".
tools: ['flutter-vision-agent', 'flutter-ui-agent', 'flutter-design-agent', 'flutter-refactor-agent'] # specify the tools this agent can use. If not set, all enabled tools are allowed.
---
# Flutter Workflow Agent

STEPS:

1. Use vision-agent to extract layout
2. Use flutter-ui-agent to generate UI
3. Use design-agent to apply styling
4. Use refactor-agent to optimize code

GOAL:
Production-ready Flutter UI.
